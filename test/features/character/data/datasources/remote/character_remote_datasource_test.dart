import 'package:dio/dio.dart';
import 'package:explorador_contenido_remoto/core/api/api_endpoints.dart';
import 'package:explorador_contenido_remoto/features/character/data/datasources/remote/character_remote_datasource.dart';
import 'package:explorador_contenido_remoto/features/character/data/models/character_page_model.dart';
import 'package:explorador_contenido_remoto/features/character/domain/entities/character_filter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockDio extends Mock implements Dio {
  @override
  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #get,
              [path],
              {
                #data: data,
                #queryParameters: queryParameters,
                #options: options,
                #cancelToken: cancelToken,
                #onReceiveProgress: onReceiveProgress,
              },
            ),
            returnValue: Future.value(
              Response<T>(requestOptions: RequestOptions(path: path)),
            ),
            returnValueForMissingStub: Future.value(
              Response<T>(requestOptions: RequestOptions(path: path)),
            ),
          )
          as Future<Response<T>>);
}

void main() {
  late CharacterRemoteDataSource dataSource;
  late MockDio mockDio;

  final tResponseData = {
    'info': {'count': 826, 'pages': 42, 'next': 'url', 'prev': null},
    'results': [
      {
        'id': 1,
        'name': 'Rick Sanchez',
        'status': 'Alive',
        'species': 'Human',
        'type': '',
        'gender': 'Male',
        'image': 'https://rickandmortyapi.com/api/character/avatar/1.jpeg',
        'origin': {'name': 'Earth (C-137)', 'url': ''},
        'location': {'name': 'Citadel of Ricks', 'url': ''},
      },
    ],
  };

  setUp(() {
    mockDio = MockDio();
    dataSource = CharacterRemoteDataSource(mockDio);
  });

  group('CharacterRemoteDataSource', () {
    test('getCharacters returns CharacterPageModel on success', () async {
      when(
        mockDio.get(
          ApiEndpoints.characters,
          queryParameters: anyNamed('queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          statusCode: 200,
          requestOptions: RequestOptions(path: ApiEndpoints.characters),
          data: tResponseData,
        ),
      );

      final result = await dataSource.getCharacters();

      expect(result, isA<CharacterPageModel>());
      expect(result.currentPage, 1);
      expect(result.totalPages, 42);
      expect(result.characters.length, 1);
      expect(result.characters.first.name, 'Rick Sanchez');
    });

    test('getCharacters with page parameter sends correct page', () async {
      when(
        mockDio.get(
          ApiEndpoints.characters,
          queryParameters: anyNamed('queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          statusCode: 200,
          requestOptions: RequestOptions(path: ApiEndpoints.characters),
          data: tResponseData,
        ),
      );

      final result = await dataSource.getCharacters(page: 3);

      expect(result.currentPage, 3);
    });

    test('getCharacters with name filter sends name query param', () async {
      when(
        mockDio.get(
          ApiEndpoints.characters,
          queryParameters: anyNamed('queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          statusCode: 200,
          requestOptions: RequestOptions(path: ApiEndpoints.characters),
          data: tResponseData,
        ),
      );

      await dataSource.getCharacters(
        filter: const CharacterFilter(name: 'Rick'),
      );

      final captured =
          verify(
                mockDio.get(
                  ApiEndpoints.characters,
                  queryParameters: captureAnyNamed('queryParameters'),
                ),
              ).captured.first
              as Map<String, dynamic>;

      expect(captured['name'], 'Rick');
    });

    test('getCharacters propagates DioException on network error', () async {
      when(
        mockDio.get(
          ApiEndpoints.characters,
          queryParameters: anyNamed('queryParameters'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ApiEndpoints.characters),
        ),
      );

      expect(() => dataSource.getCharacters(), throwsA(isA<DioException>()));
    });
  });
}
