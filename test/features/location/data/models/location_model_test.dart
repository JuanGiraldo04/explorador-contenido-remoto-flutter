import 'package:explorador_contenido_remoto/features/location/data/models/location_model.dart';
import 'package:explorador_contenido_remoto/features/location/domain/entities/location.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const tJson = {
    'id': 1,
    'name': 'Earth (C-137)',
    'type': 'Planet',
    'dimension': 'Dimension C-137',
    'residents': ['url1', 'url2', 'url3'],
  };

  group('LocationModel', () {
    test('fromJson returns a LocationModel with correct values', () {
      final model = LocationModel.fromJson(tJson);

      expect(model, isA<LocationModel>());
      expect(model.id, 1);
      expect(model.name, 'Earth (C-137)');
      expect(model.type, 'Planet');
      expect(model.dimension, 'Dimension C-137');
      expect(model.residentCount, 3);
    });

    test('residentCount equals the length of residents list', () {
      final json = {...tJson, 'residents': List.generate(10, (i) => 'url$i')};
      final model = LocationModel.fromJson(json);
      expect(model.residentCount, 10);
    });

    test('toEntity returns a Location with correct values', () {
      final entity = LocationModel.fromJson(tJson).toEntity();

      expect(entity, isA<Location>());
      expect(entity.id, 1);
      expect(entity.name, 'Earth (C-137)');
      expect(entity.type, 'Planet');
      expect(entity.dimension, 'Dimension C-137');
      expect(entity.residentCount, 3);
    });

    test('toEntity replaces empty type with "Desconocido"', () {
      final model = LocationModel.fromJson({...tJson, 'type': ''});
      expect(model.toEntity().type, 'Desconocido');
    });

    test('toEntity replaces empty dimension with "Desconocida"', () {
      final model = LocationModel.fromJson({...tJson, 'dimension': ''});
      expect(model.toEntity().dimension, 'Desconocida');
    });
  });
}
