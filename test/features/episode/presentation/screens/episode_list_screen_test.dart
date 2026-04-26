import 'package:explorador_contenido_remoto/core/errors/failure.dart';
import 'package:explorador_contenido_remoto/features/episode/domain/entities/episode.dart';
import 'package:explorador_contenido_remoto/features/episode/presentation/providers/episode_list_notifier.dart';
import 'package:explorador_contenido_remoto/features/episode/presentation/screens/episode_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const tEpisode = Episode(
    id: 1,
    name: 'Pilot',
    airDate: 'December 2, 2013',
    code: 'S01E01',
    characterCount: 19,
  );

  const tState = EpisodesState(
    episodes: [tEpisode],
    currentPage: 1,
    totalPages: 3,
  );

  Widget buildSubject({required AsyncValue<EpisodesState> state}) {
    return ProviderScope(
      overrides: [
        episodeListProvider.overrideWith(
          () => _FakeEpisodeListNotifier(state),
        ),
      ],
      child: const MaterialApp(home: EpisodeListScreen()),
    );
  }

  group('EpisodeListScreen', () {
    testWidgets('shows loading indicator when state is AsyncLoading',
        (tester) async {
      await tester.pumpWidget(buildSubject(state: const AsyncLoading()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows episode list when state is AsyncData', (tester) async {
      await tester.pumpWidget(buildSubject(state: const AsyncData(tState)));
      await tester.pump();

      expect(find.text('Pilot'), findsOneWidget);
    });

    testWidgets('shows episode code and air date in subtitle', (tester) async {
      await tester.pumpWidget(buildSubject(state: const AsyncData(tState)));
      await tester.pump();

      expect(find.textContaining('S01E01'), findsOneWidget);
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

      expect(find.text('No se encontraron episodios'), findsOneWidget);
      expect(find.text('Limpiar búsqueda'), findsOneWidget);
    });

    testWidgets('shows search TextField', (tester) async {
      await tester.pumpWidget(buildSubject(state: const AsyncData(tState)));

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows AppBar with title "Episodios"', (tester) async {
      await tester.pumpWidget(buildSubject(state: const AsyncData(tState)));

      expect(find.text('Episodios'), findsOneWidget);
    });
  });
}

class _FakeEpisodeListNotifier extends EpisodeListNotifier {
  final AsyncValue<EpisodesState> _state;
  _FakeEpisodeListNotifier(this._state);

  @override
  Future<EpisodesState> build() async {
    state = _state;
    return _state.value ??
        const EpisodesState(episodes: [], currentPage: 1, totalPages: 1);
  }

  @override
  Future<void> search(String name) async {}

  @override
  Future<void> loadNextPage() async {}
}
