import 'package:explorador_contenido_remoto/core/errors/failure.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Failure', () {
    group('userMessage', () {
      test('NetworkFailure returns correct message', () {
        const failure = NetworkFailure();
        expect(failure.userMessage, 'Sin conexión a internet');
      });

      test('UnauthorizedFailure returns correct message', () {
        const failure = UnauthorizedFailure();
        expect(failure.userMessage, 'Sesión expirada');
      });

      test('NotFoundFailure returns correct message', () {
        const failure = NotFoundFailure();
        expect(failure.userMessage, 'Recurso no encontrado');
      });

      test('ServerErrorFailure returns correct message', () {
        const failure = ServerErrorFailure();
        expect(
          failure.userMessage,
          'Error del servidor. Intenta de nuevo más tarde.',
        );
      });

      test('UnknownFailure with message returns that message', () {
        const failure = UnknownFailure('Mensaje personalizado');
        expect(failure.userMessage, 'Mensaje personalizado');
      });

      test('UnknownFailure without message returns fallback', () {
        const failure = UnknownFailure();
        expect(failure.userMessage, 'Error inesperado');
      });
    });

    group('type checks', () {
      test('NetworkFailure is a Failure', () {
        expect(const NetworkFailure(), isA<Failure>());
      });

      test('UnauthorizedFailure is a Failure', () {
        expect(const UnauthorizedFailure(), isA<Failure>());
      });

      test('NotFoundFailure is a Failure', () {
        expect(const NotFoundFailure(), isA<Failure>());
      });

      test('ServerErrorFailure is a Failure', () {
        expect(const ServerErrorFailure(), isA<Failure>());
      });

      test('UnknownFailure is a Failure', () {
        expect(const UnknownFailure(), isA<Failure>());
      });
    });
  });
}
