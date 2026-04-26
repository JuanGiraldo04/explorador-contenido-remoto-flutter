import 'package:dio/dio.dart';
import 'package:explorador_contenido_remoto/core/api/api_endpoints.dart';
import 'package:explorador_contenido_remoto/core/errors/api_result.dart';
import 'package:explorador_contenido_remoto/core/errors/failure.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('executeApiCall', () {
    test('Given a successful call, returns ApiSuccess with the value',
        () async {
      final result = await executeApiCall(() async => 42);

      expect(result, isA<ApiSuccess<int>>());
      expect((result as ApiSuccess<int>).data, 42);
    });

    test('Given a 401 DioException, returns ApiError with UnauthorizedFailure',
        () async {
      final result = await executeApiCall<int>(
        () async => throw DioException(
          requestOptions: RequestOptions(path: ApiEndpoints.characters),
          response: Response(
            statusCode: 401,
            requestOptions: RequestOptions(path: ApiEndpoints.characters),
          ),
        ),
      );

      expect(result, isA<ApiError<int>>());
      expect((result as ApiError<int>).failure, isA<UnauthorizedFailure>());
    });

    test('Given a 404 DioException, returns ApiError with NotFoundFailure',
        () async {
      final result = await executeApiCall<int>(
        () async => throw DioException(
          requestOptions: RequestOptions(path: ApiEndpoints.characters),
          response: Response(
            statusCode: 404,
            requestOptions: RequestOptions(path: ApiEndpoints.characters),
          ),
        ),
      );

      expect(result, isA<ApiError<int>>());
      expect((result as ApiError<int>).failure, isA<NotFoundFailure>());
    });

    test('Given a 500 DioException, returns ApiError with ServerErrorFailure',
        () async {
      final result = await executeApiCall<int>(
        () async => throw DioException(
          requestOptions: RequestOptions(path: ApiEndpoints.characters),
          response: Response(
            statusCode: 500,
            requestOptions: RequestOptions(path: ApiEndpoints.characters),
          ),
        ),
      );

      expect(result, isA<ApiError<int>>());
      expect((result as ApiError<int>).failure, isA<ServerErrorFailure>());
    });

    test(
        'Given a DioException without status code, returns ApiError with NetworkFailure',
        () async {
      final result = await executeApiCall<int>(
        () async => throw DioException(
          requestOptions: RequestOptions(path: ApiEndpoints.characters),
        ),
      );

      expect(result, isA<ApiError<int>>());
      expect((result as ApiError<int>).failure, isA<NetworkFailure>());
    });

    test('Given a generic exception, returns ApiError with UnknownFailure',
        () async {
      final result = await executeApiCall<int>(
        () async => throw Exception('Error inesperado'),
      );

      expect(result, isA<ApiError<int>>());
      expect((result as ApiError<int>).failure, isA<UnknownFailure>());
    });
  });

  group('ApiResult', () {
    test('ApiSuccess holds the correct data', () {
      const result = ApiSuccess('hello');
      expect(result.data, 'hello');
    });

    test('ApiError holds the correct failure', () {
      const result = ApiError<String>(NetworkFailure());
      expect(result.failure, isA<NetworkFailure>());
    });
  });
}
