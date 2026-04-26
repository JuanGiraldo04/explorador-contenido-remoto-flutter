import 'package:explorador_contenido_remoto/features/episode/data/models/episode_page_model.dart';
import 'package:explorador_contenido_remoto/features/episode/domain/entities/episode_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final tPageJson = {
    'info': {'count': 51, 'pages': 3, 'next': 'url', 'prev': null},
    'results': [
      {
        'id': 1,
        'name': 'Pilot',
        'air_date': 'December 2, 2013',
        'episode': 'S01E01',
        'characters': ['url1', 'url2'],
      },
    ],
  };

  group('EpisodePageModel', () {
    test('fromJson returns an EpisodePageModel with correct values', () {
      final model = EpisodePageModel.fromJson(tPageJson, page: 1);

      expect(model, isA<EpisodePageModel>());
      expect(model.currentPage, 1);
      expect(model.totalPages, 3);
      expect(model.episodes.length, 1);
      expect(model.episodes.first.name, 'Pilot');
    });

    test('toEntity returns EpisodePage with correct values', () {
      final entity = EpisodePageModel.fromJson(tPageJson, page: 1).toEntity();

      expect(entity, isA<EpisodePage>());
      expect(entity.currentPage, 1);
      expect(entity.totalPages, 3);
      expect(entity.episodes.length, 1);
    });

    test('hasNextPage is true when currentPage < totalPages', () {
      final entity = EpisodePageModel.fromJson(tPageJson, page: 1).toEntity();
      expect(entity.hasNextPage, isTrue);
    });

    test('hasNextPage is false on last page', () {
      final entity = EpisodePageModel.fromJson(tPageJson, page: 3).toEntity();
      expect(entity.hasNextPage, isFalse);
    });
  });
}
