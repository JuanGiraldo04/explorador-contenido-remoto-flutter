import 'package:explorador_contenido_remoto/core/errors/failure.dart';
import 'package:explorador_contenido_remoto/features/location/domain/entities/location.dart';
import 'package:explorador_contenido_remoto/features/location/presentation/providers/location_list_notifier.dart';
import 'package:explorador_contenido_remoto/features/location/presentation/screens/location_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const tLocation = Location(
    id: 1,
    name: 'Earth (C-137)',
    type: 'Planet',
    dimension: 'Dimension C-137',
    residentCount: 27,
  );

  const tState = LocationsState(
    locations: [tLocation],
    currentPage: 1,
    totalPages: 7,
  );

  Widget buildSubject({required AsyncValue<LocationsState> state}) {
    return ProviderScope(
      overrides: [
        locationListProvider.overrideWith(
          () => _FakeLocationListNotifier(state),
        ),
      ],
      child: const MaterialApp(home: LocationListScreen()),
    );
  }

  group('LocationListScreen', () {
    testWidgets('shows loading indicator when state is AsyncLoading',
        (tester) async {
      await tester.pumpWidget(buildSubject(state: const AsyncLoading()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows location list when state is AsyncData', (tester) async {
      await tester.pumpWidget(buildSubject(state: const AsyncData(tState)));
      await tester.pump();

      expect(find.text('Earth (C-137)'), findsOneWidget);
    });

    testWidgets('shows type and dimension in subtitle', (tester) async {
      await tester.pumpWidget(buildSubject(state: const AsyncData(tState)));
      await tester.pump();

      expect(find.textContaining('Planet'), findsOneWidget);
    });

    testWidgets('shows error view with retry when state is AsyncError',
        (tester) async {
      await tester.pumpWidget(
        buildSubject(
          state: AsyncError(const ServerErrorFailure(), StackTrace.empty),
        ),
      );

      expect(find.text('Error del servidor. Intenta de nuevo más tarde.'),
          findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
    });

    testWidgets('shows not-found view when error is NotFoundFailure',
        (tester) async {
      await tester.pumpWidget(
        buildSubject(
          state: AsyncError(const NotFoundFailure(), StackTrace.empty),
        ),
      );

      expect(find.text('No se encontraron lugares'), findsOneWidget);
      expect(find.text('Limpiar búsqueda'), findsOneWidget);
    });

    testWidgets('shows search TextField', (tester) async {
      await tester.pumpWidget(buildSubject(state: const AsyncData(tState)));

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows AppBar with title "Lugares"', (tester) async {
      await tester.pumpWidget(buildSubject(state: const AsyncData(tState)));

      expect(find.text('Lugares'), findsOneWidget);
    });
  });
}

class _FakeLocationListNotifier extends LocationListNotifier {
  final AsyncValue<LocationsState> _state;
  _FakeLocationListNotifier(this._state);

  @override
  Future<LocationsState> build() async {
    state = _state;
    return _state.value ??
        const LocationsState(locations: [], currentPage: 1, totalPages: 1);
  }

  @override
  Future<void> search(String name) async {}

  @override
  Future<void> loadNextPage() async {}
}
