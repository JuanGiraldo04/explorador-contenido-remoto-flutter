import 'package:explorador_contenido_remoto/core/errors/api_result.dart';
import 'package:explorador_contenido_remoto/core/errors/failure.dart';
import 'package:explorador_contenido_remoto/features/location/domain/entities/location.dart';
import 'package:explorador_contenido_remoto/features/location/domain/entities/location_page.dart';
import 'package:explorador_contenido_remoto/features/location/domain/repositories/location_repository.dart';
import 'package:explorador_contenido_remoto/features/location/domain/usecases/get_locations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockLocationRepository extends Mock implements LocationRepository {
  @override
  Result<LocationPage> getLocations({int? page = 1, String? name}) =>
      (super.noSuchMethod(
        Invocation.method(#getLocations, [], {#page: page, #name: name}),
        returnValue: Future.value(
          const ApiSuccess(
            LocationPage(locations: [], currentPage: 0, totalPages: 0),
          ),
        ),
      ) as Result<LocationPage>);
}

void main() {
  late MockLocationRepository mockRepository;
  late GetLocations useCase;

  const tLocation = Location(
    id: 1,
    name: 'Earth (C-137)',
    type: 'Planet',
    dimension: 'Dimension C-137',
    residentCount: 27,
  );

  const tLocationPage = LocationPage(
    locations: [tLocation],
    currentPage: 1,
    totalPages: 7,
  );

  setUp(() {
    mockRepository = MockLocationRepository();
    useCase = GetLocations(mockRepository);
  });

  group('GetLocations', () {
    test(
      'Given a successful repository call, returns ApiSuccess with LocationPage',
      () async {
        when(
          mockRepository.getLocations(
            page: anyNamed('page'),
            name: anyNamed('name'),
          ),
        ).thenAnswer((_) async => const ApiSuccess(tLocationPage));

        final result = await useCase();

        expect(result, isA<ApiSuccess<LocationPage>>());
        final data = (result as ApiSuccess<LocationPage>).data;
        expect(data.locations, [tLocation]);
        verify(mockRepository.getLocations(page: 1)).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test(
      'Given an empty page, returns ApiSuccess with empty locations list',
      () async {
        const emptyPage =
            LocationPage(locations: [], currentPage: 1, totalPages: 1);
        when(
          mockRepository.getLocations(
            page: anyNamed('page'),
            name: anyNamed('name'),
          ),
        ).thenAnswer((_) async => const ApiSuccess(emptyPage));

        final result = await useCase();

        final data = (result as ApiSuccess<LocationPage>).data;
        expect(data.locations, isEmpty);
      },
    );

    test(
      'Given a network failure, returns ApiError with NetworkFailure',
      () async {
        when(
          mockRepository.getLocations(
            page: anyNamed('page'),
            name: anyNamed('name'),
          ),
        ).thenAnswer((_) async => const ApiError(NetworkFailure()));

        final result = await useCase();

        expect(result, isA<ApiError<LocationPage>>());
        expect(
          (result as ApiError<LocationPage>).failure,
          isA<NetworkFailure>(),
        );
      },
    );

    test(
      'Given a name, passes it correctly to the repository',
      () async {
        when(
          mockRepository.getLocations(
            page: anyNamed('page'),
            name: anyNamed('name'),
          ),
        ).thenAnswer((_) async => const ApiSuccess(tLocationPage));

        await useCase(page: 3, name: 'Earth');

        verify(mockRepository.getLocations(page: 3, name: 'Earth')).called(1);
      },
    );

    test(
      'Given a not found failure, returns ApiError with NotFoundFailure',
      () async {
        when(
          mockRepository.getLocations(
            page: anyNamed('page'),
            name: anyNamed('name'),
          ),
        ).thenAnswer((_) async => const ApiError(NotFoundFailure()));

        final result = await useCase(name: 'XYZ');

        expect(
          (result as ApiError<LocationPage>).failure,
          isA<NotFoundFailure>(),
        );
      },
    );
  });
}
