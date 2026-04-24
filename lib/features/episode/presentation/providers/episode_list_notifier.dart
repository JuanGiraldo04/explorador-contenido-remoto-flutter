import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/api_result.dart';
import '../../domain/entities/episode.dart';
import 'episode_providers.dart';

class EpisodesState {
  const EpisodesState({
    required this.episodes,
    required this.currentPage,
    required this.totalPages,
    this.isLoadingMore = false,
    this.name = '',
  });

  final List<Episode> episodes;
  final int currentPage;
  final int totalPages;
  final bool isLoadingMore;
  final String name;

  bool get hasNextPage => currentPage < totalPages;

  EpisodesState copyWith({
    List<Episode>? episodes,
    int? currentPage,
    int? totalPages,
    bool? isLoadingMore,
    String? name,
  }) => EpisodesState(
        episodes: episodes ?? this.episodes,
        currentPage: currentPage ?? this.currentPage,
        totalPages: totalPages ?? this.totalPages,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        name: name ?? this.name,
      );
}

class EpisodeListNotifier extends AsyncNotifier<EpisodesState> {
  @override
  Future<EpisodesState> build() async {
    final result = await ref.read(getEpisodesProvider).call(page: 1);
    return switch (result) {
      ApiSuccess(:final data) => EpisodesState(
          episodes: data.episodes,
          currentPage: data.currentPage,
          totalPages: data.totalPages,
        ),
      ApiError(:final failure) => throw failure,
    };
  }

  Future<void> search(String name) async {
    state = const AsyncLoading();
    final result = await ref
        .read(getEpisodesProvider)
        .call(page: 1, name: name.isEmpty ? null : name);
    state = switch (result) {
      ApiSuccess(:final data) => AsyncData(
          EpisodesState(
            episodes: data.episodes,
            currentPage: data.currentPage,
            totalPages: data.totalPages,
            name: name,
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
        .read(getEpisodesProvider)
        .call(
          page: current.currentPage + 1,
          name: current.name.isEmpty ? null : current.name,
        );

    state = switch (result) {
      ApiSuccess(:final data) => AsyncData(
          EpisodesState(
            episodes: [...current.episodes, ...data.episodes],
            currentPage: data.currentPage,
            totalPages: data.totalPages,
            name: current.name,
          ),
        ),
      ApiError(:final failure) => AsyncError(failure, StackTrace.current),
    };
  }
}

final episodeListProvider =
    AsyncNotifierProvider<EpisodeListNotifier, EpisodesState>(
  EpisodeListNotifier.new,
);
