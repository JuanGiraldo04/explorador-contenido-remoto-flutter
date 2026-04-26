import 'package:explorador_contenido_remoto/features/episode/domain/entities/episode.dart';
import 'package:explorador_contenido_remoto/features/episode/presentation/screens/episode_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const tEpisode = Episode(
    id: 1,
    name: 'Pilot',
    airDate: 'December 2, 2013',
    code: 'S01E01',
    characterCount: 19,
  );

  Widget buildSubject(Episode episode) {
    return MaterialApp(home: EpisodeDetailScreen(episode: episode));
  }

  group('EpisodeDetailScreen', () {
    testWidgets('shows episode name in AppBar and body', (tester) async {
      await tester.pumpWidget(buildSubject(tEpisode));
      expect(find.text('Pilot'), findsWidgets);
    });

    testWidgets('shows episode code', (tester) async {
      await tester.pumpWidget(buildSubject(tEpisode));
      expect(find.text('Código'), findsOneWidget);
      expect(find.text('S01E01'), findsOneWidget);
    });

    testWidgets('shows air date', (tester) async {
      await tester.pumpWidget(buildSubject(tEpisode));
      expect(find.text('Fecha de emisión'), findsOneWidget);
      expect(find.text('December 2, 2013'), findsOneWidget);
    });

    testWidgets('shows character count', (tester) async {
      await tester.pumpWidget(buildSubject(tEpisode));
      expect(find.text('Personajes'), findsOneWidget);
      expect(find.text('19'), findsOneWidget);
    });
  });
}
