import 'package:explorador_contenido_remoto/core/errors/api_result.dart';
import 'package:explorador_contenido_remoto/features/location/data/datasources/remote/location_remote_datasource.dart';
import 'package:explorador_contenido_remoto/features/location/data/models/location_model.dart';
import 'package:explorador_contenido_remoto/features/location/data/models/location_page_model.dart';
import 'package:explorador_contenido_remoto/features/location/data/repositories/location_repository_impl.dart';
import 'package:explorador_contenido_remoto/features/location/domain/entities/location.dart';
import 'package:explorador_contenido_remoto/features/location/domain/entities/location_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockLocationRemoteDataSource extends Mock
    implements LocationRemoteDataSource {
  @override
  Future<LocationPageModel> getLocations({int? page = 1, String? name}) =>
      (super.noSuchMethod(
        Invocation.method(#getLocations, [], {#page: page, #name: name}),
        returnValue: Future.value(
          LocationPageModel(locations: const [], currentPage: 0, totalPages: 0),
        ),
      ) as Future<LocationPageModel>);
}

void main() {
  late LocationRepositoryImpl repository;
  late MockLocationRemoteDataSource mockDataSource;

  final tLocationPageModel = LocationPageModel(
    locations: [
      const LocationModel(
        id: 1,
        name: 'Earth (C-137)',
        type: 'Planet',
        dimension: 'Dimension C-137',
        residentCount: 27,
      ),
    ],
    currentPage: 1,
    totalPages: 7,
  );

  setUp(() {
    mockDataSource = MockLocationRemoteDataSource();
    repository = LocationRepositoryImpl(mockDataSource);
  });

  group('LocationRepositoryImpl', () {
    group('getLocations', () {
      test('returns ApiSuccess with LocationPage on success', () async {
        when(
          mockDataSource.getLocations(
            page: anyNamed('page'),
            name: anyNamed('name'),
          ),
        ).thenAnswer((_) async => tLocationPageModel);

        final result = await repository.getLocations();

        expect(result, isA<ApiSuccess<LocationPage>>());
        final data = (result as ApiSuccess<LocationPage>).data;
        expect(data.locations.length, 1);
        expect(data.currentPage, 1);
        expect(data.totalPages, 7);
      });

      test('returns ApiSuccess with converted Location entities', () async {
        when(
          mockDataSource.getLocations(
            page: anyNamed('page'),
            name: anyNamed('name'),
          ),
        ).thenAnswer((_) async => tLocationPageModel);

        final result = await repository.getLocations();

        final data = (result as ApiSuccess<LocationPage>).data;
        expect(data.locations.first, isA<Location>());
        expect(data.locations.first.name, 'Earth (C-137)');
        expect(data.locations.first.type, 'Planet');
      });

      test('returns ApiError when datasource throws', () async {
        when(
          mockDataSource.getLocations(
            page: anyNamed('page'),
            name: anyNamed('name'),
          ),
        ).thenThrow(Exception('Network error'));

        final result = await repository.getLocations();

        expect(result, isA<ApiError<LocationPage>>());
      });

      test('passes name param to datasource', () async {
        when(
          mockDataSource.getLocations(
            page: anyNamed('page'),
            name: anyNamed('name'),
          ),
        ).thenAnswer((_) async => tLocationPageModel);

        await repository.getLocations(page: 2, name: 'Earth');

        verify(mockDataSource.getLocations(page: 2, name: 'Earth')).called(1);
      });
    });
  });
}
