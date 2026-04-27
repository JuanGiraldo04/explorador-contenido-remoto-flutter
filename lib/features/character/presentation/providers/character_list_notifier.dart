import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/api_result.dart';
import '../../domain/entities/character.dart';
import '../../domain/entities/character_filter.dart';
import 'character_providers.dart';

class CharactersState {
  const CharactersState({
    required this.characters,
    required this.currentPage,
    required this.totalPages,
    this.isLoadingMore = false,
    this.filter = const CharacterFilter(),
  });

  final List<Character> characters;
  final int currentPage;
  final int totalPages;
  final bool isLoadingMore;
  final CharacterFilter filter;

  bool get hasNextPage => currentPage < totalPages;

  CharactersState copyWith({
    List<Character>? characters,
    int? currentPage,
    int? totalPages,
    bool? isLoadingMore,
    CharacterFilter? filter,
  }) => CharactersState(
    characters: characters ?? this.characters,
    currentPage: currentPage ?? this.currentPage,
    totalPages: totalPages ?? this.totalPages,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    filter: filter ?? this.filter,
  );
}

class CharacterListNotifier extends AsyncNotifier<CharactersState> {
  @override
  Future<CharactersState> build() async {
    state = const AsyncLoading();
    final result = await ref.read(getCharactersProvider).call(page: 1);
    return switch (result) {
      ApiSuccess(:final data) => CharactersState(
        characters: data.characters,
        currentPage: data.currentPage,
        totalPages: data.totalPages,
      ),
      ApiError(:final failure) => throw failure,
    };
  }

  Future<void> search(CharacterFilter filter) async {
    state = const AsyncLoading();
    final result = await ref
        .read(getCharactersProvider)
        .call(page: 1, filter: filter);
    state = switch (result) {
      ApiSuccess(:final data) => AsyncData(
        CharactersState(
          characters: data.characters,
          currentPage: data.currentPage,
          totalPages: data.totalPages,
          filter: filter,
        ),
      ),
      ApiError(:final failure) => AsyncError(failure, StackTrace.current),
    };
  }

  Future<void> loadNextPage() async {
    final current = state.value;
    if (current == null || !current.hasNextPage || current.isLoadingMore) {
      return;
    }

    state = AsyncData(current.copyWith(isLoadingMore: true));

    final result = await ref
        .read(getCharactersProvider)
        .call(page: current.currentPage + 1, filter: current.filter);

    state = switch (result) {
      ApiSuccess(:final data) => AsyncData(
        CharactersState(
          characters: [...current.characters, ...data.characters],
          currentPage: data.currentPage,
          totalPages: data.totalPages,
          filter: current.filter,
        ),
      ),
      ApiError(:final failure) => AsyncError(failure, StackTrace.current),
    };
  }
}

final characterListProvider =
    AsyncNotifierProvider<CharacterListNotifier, CharactersState>(
      CharacterListNotifier.new,
    );
