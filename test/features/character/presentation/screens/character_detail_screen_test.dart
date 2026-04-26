import 'package:explorador_contenido_remoto/features/character/domain/entities/character.dart';
import 'package:explorador_contenido_remoto/features/character/presentation/screens/character_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const tCharacter = Character(
    id: 1,
    name: 'Rick Sanchez',
    status: CharacterStatus.alive,
    species: 'Human',
    type: 'Genius',
    gender: CharacterGender.male,
    image: '',
    origin: CharacterLocation(name: 'Earth (C-137)', url: ''),
    location: CharacterLocation(name: 'Citadel of Ricks', url: ''),
  );

  const tDeadCharacter = Character(
    id: 2,
    name: 'Birdperson',
    status: CharacterStatus.dead,
    species: 'Alien',
    type: '',
    gender: CharacterGender.male,
    image: '',
    origin: CharacterLocation(name: 'Bird World', url: ''),
    location: CharacterLocation(name: 'unknown', url: ''),
  );

  Widget buildSubject(Character character) {
    return MaterialApp(home: CharacterDetailScreen(character: character));
  }

  group('CharacterDetailScreen', () {
    testWidgets('shows character name', (tester) async {
      await tester.pumpWidget(buildSubject(tCharacter));
      expect(find.text('Rick Sanchez'), findsWidgets);
    });

    testWidgets('shows alive status label', (tester) async {
      await tester.pumpWidget(buildSubject(tCharacter));
      expect(find.text('Vivo'), findsOneWidget);
    });

    testWidgets('shows dead status label', (tester) async {
      await tester.pumpWidget(buildSubject(tDeadCharacter));
      expect(find.text('Muerto'), findsOneWidget);
    });

    testWidgets('shows species info row', (tester) async {
      await tester.pumpWidget(buildSubject(tCharacter));
      expect(find.text('Especie'), findsOneWidget);
      expect(find.text('Human'), findsOneWidget);
    });

    testWidgets('shows type info row when type is not empty', (tester) async {
      await tester.pumpWidget(buildSubject(tCharacter));
      expect(find.text('Tipo'), findsOneWidget);
      expect(find.text('Genius'), findsOneWidget);
    });

    testWidgets('hides type row when type is empty', (tester) async {
      await tester.pumpWidget(buildSubject(tDeadCharacter));
      expect(find.text('Tipo'), findsNothing);
    });

    testWidgets('shows gender info row', (tester) async {
      await tester.pumpWidget(buildSubject(tCharacter));
      expect(find.text('Género'), findsOneWidget);
      expect(find.text('Masculino'), findsOneWidget);
    });

    testWidgets('shows origin info row', (tester) async {
      await tester.pumpWidget(buildSubject(tCharacter));
      expect(find.text('Origen'), findsOneWidget);
      expect(find.text('Earth (C-137)'), findsWidgets);
    });

    testWidgets('shows last location info row', (tester) async {
      await tester.pumpWidget(buildSubject(tCharacter));
      expect(find.text('Última ubicación'), findsOneWidget);
      expect(find.text('Citadel of Ricks'), findsOneWidget);
    });
  });
}
