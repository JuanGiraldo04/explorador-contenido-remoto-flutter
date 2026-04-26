import 'package:dio/dio.dart';
import 'package:explorador_contenido_remoto/core/api/api_endpoints.dart';
import 'package:explorador_contenido_remoto/features/episode/data/datasources/remote/episode_remote_datasource.dart';
import 'package:explorador_contenido_remoto/features/episode/data/models/episode_page_model.dart';
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
  late EpisodeRemoteDataSource dataSource;
  late MockDio mockDio;

  final tResponseData = {
    'info': {'count': 51, 'pages': 3, 'next': 'url', 'prev': null},
    'results': [
      {
        'id': 1,
        'name': 'Pilot',
        'air_date': 'December 2, 2013',
        'episode': 'S01E01',
        'characters': ['url1', 'url2', 'url3'],
      },
    ],
  };

  setUp(() {
    mockDio = MockDio();
    dataSource = EpisodeRemoteDataSource(mockDio);
  });

  group('EpisodeRemoteDataSource', () {
    test('getEpisodes returns EpisodePageModel on success', () async {
      when(
        mockDio.get(
          ApiEndpoints.episodes,
          queryParameters: anyNamed('queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          statusCode: 200,
          requestOptions: RequestOptions(path: ApiEndpoints.episodes),
          data: tResponseData,
        ),
      );

      final result = await dataSource.getEpisodes();

      expect(result, isA<EpisodePageModel>());
      expect(result.currentPage, 1);
      expect(result.totalPages, 3);
      expect(result.episodes.length, 1);
      expect(result.episodes.first.name, 'Pilot');
    });

    test('getEpisodes with name sends name query param', () async {
      when(
        mockDio.get(
          ApiEndpoints.episodes,
          queryParameters: anyNamed('queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          statusCode: 200,
          requestOptions: RequestOptions(path: ApiEndpoints.episodes),
          data: tResponseData,
        ),
      );

      await dataSource.getEpisodes(name: 'Pilot');

      final captured =
          verify(
                mockDio.get(
                  ApiEndpoints.episodes,
                  queryParameters: captureAnyNamed('queryParameters'),
                ),
              ).captured.first
              as Map<String, dynamic>;

      expect(captured['name'], 'Pilot');
    });

    test('getEpisodes without name does not send name param', () async {
      when(
        mockDio.get(
          ApiEndpoints.episodes,
          queryParameters: anyNamed('queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          statusCode: 200,
          requestOptions: RequestOptions(path: ApiEndpoints.episodes),
          data: tResponseData,
        ),
      );

      await dataSource.getEpisodes();

      final captured =
          verify(
                mockDio.get(
                  ApiEndpoints.episodes,
                  queryParameters: captureAnyNamed('queryParameters'),
                ),
              ).captured.first
              as Map<String, dynamic>;

      expect(captured.containsKey('name'), isFalse);
    });

    test('getEpisodes propagates DioException on network error', () {
      when(
        mockDio.get(
          ApiEndpoints.episodes,
          queryParameters: anyNamed('queryParameters'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ApiEndpoints.episodes),
        ),
      );

      expect(() => dataSource.getEpisodes(), throwsA(isA<DioException>()));
    });
  });
}
