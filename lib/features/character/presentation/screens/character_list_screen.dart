import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/character.dart';
import '../../domain/entities/character_filter.dart';
import '../providers/character_list_notifier.dart';
import '../widgets/character_card.dart';

class CharacterListScreen extends ConsumerStatefulWidget {
  const CharacterListScreen({super.key});

  @override
  ConsumerState<CharacterListScreen> createState() =>
      _CharacterListScreenState();
}

class _CharacterListScreenState extends ConsumerState<CharacterListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  CharacterStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      ref.read(characterListProvider.notifier).loadNextPage();
    }
  }

  void _applyFilter() {
    ref.read(characterListProvider.notifier).search(
          CharacterFilter(
            name: _searchController.text.trim(),
            status: _selectedStatus,
          ),
        );
  }

  void _clearFilter() {
    _searchController.clear();
    setState(() => _selectedStatus = null);
    ref.read(characterListProvider.notifier).search(const CharacterFilter());
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(characterListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Rick & Morty'), centerTitle: true),
      body: Column(
        children: [
          _SearchBar(
            controller: _searchController,
            onSubmitted: (_) => _applyFilter(),
            onClear: _clearFilter,
          ),
          _StatusFilterRow(
            selected: _selectedStatus,
            onSelected: (status) {
              setState(() => _selectedStatus = status);
              _applyFilter();
            },
          ),
          Expanded(
            child: asyncState.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (error, _) {
                if (error is NotFoundFailure) {
                  return _NoResultsView(onClear: _clearFilter);
                }
                return _ErrorView(
                  message: error is Failure
                      ? error.userMessage
                      : 'Error inesperado',
                  onRetry: () => ref.invalidate(characterListProvider),
                );
              },
              data: (state) => ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount:
                    state.characters.length + (state.isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == state.characters.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return CharacterCard(character: state.characters[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onSubmitted,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.search,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          hintText: 'Buscar personaje...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: onClear,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }
}

class _StatusFilterRow extends StatelessWidget {
  const _StatusFilterRow({required this.selected, required this.onSelected});

  final CharacterStatus? selected;
  final ValueChanged<CharacterStatus?> onSelected;

  static const _options = [
    (label: 'Todos', value: null),
    (label: 'Vivo', value: CharacterStatus.alive),
    (label: 'Muerto', value: CharacterStatus.dead),
    (label: 'Desconocido', value: CharacterStatus.unknown),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: _options
            .map(
              (opt) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(opt.label),
                  selected: selected == opt.value,
                  onSelected: (_) => onSelected(opt.value),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _NoResultsView extends StatelessWidget {
  const _NoResultsView({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No se encontraron personajes'),
          const SizedBox(height: 12),
          TextButton(onPressed: onClear, child: const Text('Limpiar búsqueda')),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
