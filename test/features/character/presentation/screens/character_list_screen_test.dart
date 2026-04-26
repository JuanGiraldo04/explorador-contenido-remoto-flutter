import 'package:explorador_contenido_remoto/core/errors/failure.dart';
import 'package:explorador_contenido_remoto/features/character/domain/entities/character.dart';
import 'package:explorador_contenido_remoto/features/character/domain/entities/character_filter.dart';
import 'package:explorador_contenido_remoto/features/character/presentation/providers/character_list_notifier.dart';
import 'package:explorador_contenido_remoto/features/character/presentation/screens/character_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const tCharacter = Character(
    id: 1,
    name: 'Rick Sanchez',
    status: CharacterStatus.alive,
    species: 'Human',
    type: '',
    gender: CharacterGender.male,
    image: '',
    origin: CharacterLocation(name: 'Earth (C-137)', url: ''),
    location: CharacterLocation(name: 'Citadel of Ricks', url: ''),
  );

  const tState = CharactersState(
    characters: [tCharacter],
    currentPage: 1,
    totalPages: 1,
  );

  Widget buildSubject({required AsyncValue<CharactersState> state}) {
    return ProviderScope(
      overrides: [
        characterListProvider.overrideWith(
          () => _FakeCharacterListNotifier(state),
        ),
      ],
      child: const MaterialApp(home: CharacterListScreen()),
    );
  }

  group('CharacterListScreen', () {
    testWidgets('shows loading indicator when state is AsyncLoading', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject(state: const AsyncLoading()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows character list when state is AsyncData', (tester) async {
      await tester.pumpWidget(buildSubject(state: const AsyncData(tState)));
      await tester.pump();

      expect(find.text('Rick Sanchez'), findsOneWidget);
    });

    testWidgets('shows subtitle with species and location', (tester) async {
      await tester.pumpWidget(buildSubject(state: const AsyncData(tState)));
      await tester.pump();

      expect(find.textContaining('Human'), findsOneWidget);
    });

    testWidgets('shows error view with retry button when state is AsyncError', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSubject(
          state: AsyncError(const ServerErrorFailure(), StackTrace.empty),
        ),
      );

      expect(
        find.text('Error del servidor. Intenta de nuevo más tarde.'),
        findsOneWidget,
      );
      expect(find.text('Reintentar'), findsOneWidget);
    });

    testWidgets('shows not-found view when error is NotFoundFailure', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSubject(
          state: AsyncError(const NotFoundFailure(), StackTrace.empty),
        ),
      );

      expect(find.text('No se encontraron personajes'), findsOneWidget);
      expect(find.text('Limpiar búsqueda'), findsOneWidget);
    });

    testWidgets('shows search TextField', (tester) async {
      await tester.pumpWidget(buildSubject(state: const AsyncData(tState)));

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows status filter chips', (tester) async {
      await tester.pumpWidget(buildSubject(state: const AsyncData(tState)));

      expect(find.text('Todos'), findsOneWidget);
      expect(find.text('Vivo').first, findsOneWidget);
      expect(find.text('Muerto'), findsOneWidget);
      expect(find.text('Desconocido'), findsOneWidget);
    });
  });
}

class _FakeCharacterListNotifier extends CharacterListNotifier {
  final AsyncValue<CharactersState> _state;
  _FakeCharacterListNotifier(this._state);

  @override
  Future<CharactersState> build() async {
    state = _state;
    return _state.value ??
        const CharactersState(characters: [], currentPage: 1, totalPages: 1);
  }

  @override
  Future<void> search(CharacterFilter filter) async {}

  @override
  Future<void> loadNextPage() async {}
}
