sealed class Failure {
  const Failure();

  String get userMessage => switch (this) {
    NetworkFailure() => 'Sin conexión a internet',
    UnauthorizedFailure() => 'Sesión expirada',
    NotFoundFailure() => 'Recurso no encontrado',
    ServerErrorFailure() => 'Error del servidor. Intenta de nuevo más tarde.',
    UnknownFailure(:final message) => message ?? 'Error inesperado',
  };
}

class NetworkFailure extends Failure {
  const NetworkFailure();
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure();
}

class NotFoundFailure extends Failure {
  const NotFoundFailure();
}

class ServerErrorFailure extends Failure {
  const ServerErrorFailure();
}

class UnknownFailure extends Failure {
  const UnknownFailure([this.message]);
  final String? message;
}
