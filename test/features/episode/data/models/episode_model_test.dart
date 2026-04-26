import 'package:explorador_contenido_remoto/features/episode/data/models/episode_model.dart';
import 'package:explorador_contenido_remoto/features/episode/domain/entities/episode.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const tJson = {
    'id': 1,
    'name': 'Pilot',
    'air_date': 'December 2, 2013',
    'episode': 'S01E01',
    'characters': ['url1', 'url2', 'url3'],
  };

  group('EpisodeModel', () {
    test('fromJson returns an EpisodeModel with correct values', () {
      final model = EpisodeModel.fromJson(tJson);

      expect(model, isA<EpisodeModel>());
      expect(model.id, 1);
      expect(model.name, 'Pilot');
      expect(model.airDate, 'December 2, 2013');
      expect(model.code, 'S01E01');
      expect(model.characterCount, 3);
    });

    test('characterCount equals the length of the characters list', () {
      final json = {...tJson, 'characters': List.generate(5, (i) => 'url$i')};
      final model = EpisodeModel.fromJson(json);
      expect(model.characterCount, 5);
    });

    test('toEntity returns an Episode with correct values', () {
      final entity = EpisodeModel.fromJson(tJson).toEntity();

      expect(entity, isA<Episode>());
      expect(entity.id, 1);
      expect(entity.name, 'Pilot');
      expect(entity.airDate, 'December 2, 2013');
      expect(entity.code, 'S01E01');
      expect(entity.characterCount, 3);
    });
  });
}
