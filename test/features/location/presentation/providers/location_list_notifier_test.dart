import 'package:explorador_contenido_remoto/core/errors/api_result.dart';
import 'package:explorador_contenido_remoto/features/location/domain/entities/location.dart';
import 'package:explorador_contenido_remoto/features/location/domain/entities/location_page.dart';
import 'package:explorador_contenido_remoto/features/location/domain/usecases/get_locations.dart';
import 'package:explorador_contenido_remoto/features/location/presentation/providers/location_list_notifier.dart';
import 'package:explorador_contenido_remoto/features/location/presentation/providers/location_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockGetLocations extends Mock implements GetLocations {
  @override
  Result<LocationPage> call({int? page = 1, String? name}) =>
      (super.noSuchMethod(
            Invocation.method(#call, [], {#page: page, #name: name}),
            returnValue: Future.value(
              const ApiSuccess(
                LocationPage(locations: [], currentPage: 0, totalPages: 0),
              ),
            ),
          )
          as Result<LocationPage>);
}

void main() {
  const tLocation = Location(
    id: 1,
    name: 'Earth (C-137)',
    type: 'Planet',
    dimension: 'Dimension C-137',
    residentCount: 27,
  );

  const tLocation2 = Location(
    id: 2,
    name: 'Abadango',
    type: 'Cluster',
    dimension: 'unknown',
    residentCount: 1,
  );

  const tPage1 = LocationPage(
    locations: [tLocation],
    currentPage: 1,
    totalPages: 7,
  );

  const tPage2 = LocationPage(
    locations: [tLocation2],
    currentPage: 2,
    totalPages: 7,
  );

  late MockGetLocations mockGetLocations;

  setUp(() {
    mockGetLocations = MockGetLocations();
  });

  ProviderContainer buildContainer() {
    return ProviderContainer(
      overrides: [getLocationsProvider.overrideWithValue(mockGetLocations)],
    );
  }

  group('LocationListNotifier', () {
    test('build loads first page of locations', () async {
      when(
        mockGetLocations.call(page: anyNamed('page')),
      ).thenAnswer((_) async => const ApiSuccess(tPage1));

      final container = buildContainer();
      addTearDown(container.dispose);

      final result = await container.read(locationListProvider.future);

      expect(result.locations, [tLocation]);
      expect(result.currentPage, 1);
      expect(result.totalPages, 7);
    });

    test('search with empty string resets name in state', () async {
      when(
        mockGetLocations.call(page: anyNamed('page')),
      ).thenAnswer((_) async => const ApiSuccess(tPage1));
      when(
        mockGetLocations.call(page: anyNamed('page'), name: anyNamed('name')),
      ).thenAnswer((_) async => const ApiSuccess(tPage1));

      final container = buildContainer();
      addTearDown(container.dispose);

      await container.read(locationListProvider.future);
      await container.read(locationListProvider.notifier).search('Earth');
      await container.read(locationListProvider.notifier).search('');

      final state = container.read(locationListProvider).value!;
      expect(state.name, '');
    });

    test('loadNextPage appends locations and preserves name', () async {
      when(
        mockGetLocations.call(page: anyNamed('page')),
      ).thenAnswer((_) async => const ApiSuccess(tPage1));
      when(
        mockGetLocations.call(page: anyNamed('page'), name: anyNamed('name')),
      ).thenAnswer((inv) async {
        final page = inv.namedArguments[#page] as int;
        return page == 2 ? const ApiSuccess(tPage2) : const ApiSuccess(tPage1);
      });

      final container = buildContainer();
      addTearDown(container.dispose);

      await container.read(locationListProvider.future);
      await container.read(locationListProvider.notifier).loadNextPage();

      final state = container.read(locationListProvider).value!;
      expect(state.locations.length, 2);
      expect(state.currentPage, 2);
    });
  });
}
