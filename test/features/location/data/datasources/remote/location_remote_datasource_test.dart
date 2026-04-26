import 'package:dio/dio.dart';
import 'package:explorador_contenido_remoto/core/api/api_endpoints.dart';
import 'package:explorador_contenido_remoto/features/location/data/datasources/remote/location_remote_datasource.dart';
import 'package:explorador_contenido_remoto/features/location/data/models/location_page_model.dart';
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
  late LocationRemoteDataSource dataSource;
  late MockDio mockDio;

  final tResponseData = {
    'info': {'count': 126, 'pages': 7, 'next': 'url', 'prev': null},
    'results': [
      {
        'id': 1,
        'name': 'Earth (C-137)',
        'type': 'Planet',
        'dimension': 'Dimension C-137',
        'residents': ['url1', 'url2'],
      },
    ],
  };

  setUp(() {
    mockDio = MockDio();
    dataSource = LocationRemoteDataSource(mockDio);
  });

  group('LocationRemoteDataSource', () {
    test('getLocations returns LocationPageModel on success', () async {
      when(
        mockDio.get(
          ApiEndpoints.locations,
          queryParameters: anyNamed('queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          statusCode: 200,
          requestOptions: RequestOptions(path: ApiEndpoints.locations),
          data: tResponseData,
        ),
      );

      final result = await dataSource.getLocations();

      expect(result, isA<LocationPageModel>());
      expect(result.currentPage, 1);
      expect(result.totalPages, 7);
      expect(result.locations.length, 1);
      expect(result.locations.first.name, 'Earth (C-137)');
    });

    test('getLocations with name sends name query param', () async {
      when(
        mockDio.get(
          ApiEndpoints.locations,
          queryParameters: anyNamed('queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          statusCode: 200,
          requestOptions: RequestOptions(path: ApiEndpoints.locations),
          data: tResponseData,
        ),
      );

      await dataSource.getLocations(name: 'Earth');

      final captured =
          verify(
                mockDio.get(
                  ApiEndpoints.locations,
                  queryParameters: captureAnyNamed('queryParameters'),
                ),
              ).captured.first
              as Map<String, dynamic>;

      expect(captured['name'], 'Earth');
    });

    test('getLocations without name does not send name param', () async {
      when(
        mockDio.get(
          ApiEndpoints.locations,
          queryParameters: anyNamed('queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          statusCode: 200,
          requestOptions: RequestOptions(path: ApiEndpoints.locations),
          data: tResponseData,
        ),
      );

      await dataSource.getLocations();

      final captured =
          verify(
                mockDio.get(
                  ApiEndpoints.locations,
                  queryParameters: captureAnyNamed('queryParameters'),
                ),
              ).captured.first
              as Map<String, dynamic>;

      expect(captured.containsKey('name'), isFalse);
    });

    test('getLocations propagates DioException on network error', () {
      when(
        mockDio.get(
          ApiEndpoints.locations,
          queryParameters: anyNamed('queryParameters'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ApiEndpoints.locations),
        ),
      );

      expect(() => dataSource.getLocations(), throwsA(isA<DioException>()));
    });
  });
}
