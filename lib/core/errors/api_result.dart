import 'package:dio/dio.dart';
import 'failure.dart';

sealed class ApiResult<T> {
  const ApiResult();
}

class ApiSuccess<T> extends ApiResult<T> {
  const ApiSuccess(this.data);
  final T data;
}

class ApiError<T> extends ApiResult<T> {
  const ApiError(this.failure);
  final Failure failure;
}

typedef Result<T> = Future<ApiResult<T>>;

Result<T> executeApiCall<T>(Future<T> Function() call) async {
  try {
    return ApiSuccess(await call());
  } on DioException catch (e) {
    final int? status = e.response?.statusCode;
    final failure = switch (status) {
      401 => const UnauthorizedFailure(),
      404 => const NotFoundFailure(),
      final int s when s >= 500 => const ServerErrorFailure(),
      _ => const NetworkFailure(),
    };
    return ApiError(failure);
  } catch (e) {
    return ApiError(UnknownFailure(e.toString()));
  }
}
