import 'package:explorador_contenido_remoto/features/location/data/models/location_page_model.dart';
import 'package:explorador_contenido_remoto/features/location/domain/entities/location_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final tPageJson = {
    'info': {'count': 126, 'pages': 7, 'next': 'url', 'prev': null},
    'results': [
      {
        'id': 1,
        'name': 'Earth (C-137)',
        'type': 'Planet',
        'dimension': 'Dimension C-137',
        'residents': ['url1', 'url2'],
      },
    ],
  };

  group('LocationPageModel', () {
    test('fromJson returns a LocationPageModel with correct values', () {
      final model = LocationPageModel.fromJson(tPageJson, page: 1);

      expect(model, isA<LocationPageModel>());
      expect(model.currentPage, 1);
      expect(model.totalPages, 7);
      expect(model.locations.length, 1);
      expect(model.locations.first.name, 'Earth (C-137)');
    });

    test('toEntity returns LocationPage with correct values', () {
      final entity = LocationPageModel.fromJson(tPageJson, page: 1).toEntity();

      expect(entity, isA<LocationPage>());
      expect(entity.currentPage, 1);
      expect(entity.totalPages, 7);
      expect(entity.locations.length, 1);
    });

    test('hasNextPage is true when currentPage < totalPages', () {
      final entity = LocationPageModel.fromJson(tPageJson, page: 1).toEntity();
      expect(entity.hasNextPage, isTrue);
    });

    test('hasNextPage is false on last page', () {
      final entity = LocationPageModel.fromJson(tPageJson, page: 7).toEntity();
      expect(entity.hasNextPage, isFalse);
    });
  });
}
