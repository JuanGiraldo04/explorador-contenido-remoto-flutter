import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/api_result.dart';
import '../../domain/entities/entities.dart';
import 'location_providers.dart';

class LocationsState {
  const LocationsState({
    required this.locations,
    required this.currentPage,
    required this.totalPages,
    this.isLoadingMore = false,
    this.name = '',
  });

  final List<Location> locations;
  final int currentPage;
  final int totalPages;
  final bool isLoadingMore;
  final String name;

  bool get hasNextPage => currentPage < totalPages;

  LocationsState copyWith({
    List<Location>? locations,
    int? currentPage,
    int? totalPages,
    bool? isLoadingMore,
    String? name,
  }) => LocationsState(
    locations: locations ?? this.locations,
    currentPage: currentPage ?? this.currentPage,
    totalPages: totalPages ?? this.totalPages,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    name: name ?? this.name,
  );
}

class LocationListNotifier extends AsyncNotifier<LocationsState> {
  @override
  Future<LocationsState> build() async {
    final result = await ref.read(getLocationsProvider).call(page: 1);
    return switch (result) {
      ApiSuccess(:final data) => LocationsState(
        locations: data.locations,
        currentPage: data.currentPage,
        totalPages: data.totalPages,
      ),
      ApiError(:final failure) => throw failure,
    };
  }

  Future<void> search(String name) async {
    state = const AsyncLoading();
    final result = await ref
        .read(getLocationsProvider)
        .call(page: 1, name: name.isEmpty ? null : name);
    state = switch (result) {
      ApiSuccess(:final data) => AsyncData(
        LocationsState(
          locations: data.locations,
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
        .read(getLocationsProvider)
        .call(
          page: current.currentPage + 1,
          name: current.name.isEmpty ? null : current.name,
        );

    state = switch (result) {
      ApiSuccess(:final data) => AsyncData(
        LocationsState(
          locations: [...current.locations, ...data.locations],
          currentPage: data.currentPage,
          totalPages: data.totalPages,
          name: current.name,
        ),
      ),
      ApiError(:final failure) => AsyncError(failure, StackTrace.current),
    };
  }
}

final locationListProvider =
    AsyncNotifierProvider<LocationListNotifier, LocationsState>(
      LocationListNotifier.new,
    );
