import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/widgets/error_view.dart';
import '../providers/episode_list_notifier.dart';
import '../widgets/widgets.dart';
import 'episode_detail_screen.dart';

class EpisodeListScreen extends ConsumerStatefulWidget {
  const EpisodeListScreen({super.key});

  @override
  ConsumerState<EpisodeListScreen> createState() => _EpisodeListScreenState();
}

class _EpisodeListScreenState extends ConsumerState<EpisodeListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

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
      ref.read(episodeListProvider.notifier).loadNextPage();
    }
  }

  void _applySearch() {
    ref
        .read(episodeListProvider.notifier)
        .search(_searchController.text.trim());
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(episodeListProvider.notifier).search('');
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(episodeListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Episodios'), centerTitle: true),
      body: Column(
        children: [
          _SearchBar(
            controller: _searchController,
            onSubmitted: (_) => _applySearch(),
            onClear: _clearSearch,
          ),
          Expanded(
            child: asyncState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) {
                if (error is NotFoundFailure) {
                  return _NoResultsView(onClear: _clearSearch);
                }
                return ErrorView(
                  message: error is Failure
                      ? error.userMessage
                      : 'Error inesperado',
                  onRetry: () => ref.invalidate(episodeListProvider),
                );
              },
              data: (state) => ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount:
                    state.episodes.length + (state.isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == state.episodes.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final episode = state.episodes[index];
                  return EpisodeCard(
                    episode: episode,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            EpisodeDetailScreen(episode: episode),
                      ),
                    ),
                  );
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
          hintText: 'Buscar episodio...',
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
          const Text('No se encontraron episodios'),
          const SizedBox(height: 12),
          TextButton(onPressed: onClear, child: const Text('Limpiar búsqueda')),
        ],
      ),
    );
  }
}
