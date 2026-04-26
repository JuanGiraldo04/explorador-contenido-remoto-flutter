import 'package:explorador_contenido_remoto/features/character/data/models/character_model.dart';
import 'package:explorador_contenido_remoto/features/character/domain/entities/character.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const tJson = {
    'id': 1,
    'name': 'Rick Sanchez',
    'status': 'Alive',
    'species': 'Human',
    'type': '',
    'gender': 'Male',
    'image': 'https://rickandmortyapi.com/api/character/avatar/1.jpeg',
    'origin': {'name': 'Earth (C-137)', 'url': ''},
    'location': {'name': 'Citadel of Ricks', 'url': ''},
  };

  group('CharacterLocationModel', () {
    test('fromJson returns correct model', () {
      final model =
          CharacterLocationModel.fromJson({'name': 'Earth', 'url': 'http://x'});
      expect(model.name, 'Earth');
      expect(model.url, 'http://x');
    });

    test('toEntity returns CharacterLocation', () {
      const model = CharacterLocationModel(name: 'Earth', url: '');
      final entity = model.toEntity();
      expect(entity, isA<CharacterLocation>());
      expect(entity.name, 'Earth');
    });
  });

  group('CharacterModel', () {
    test('fromJson returns a CharacterModel with correct values', () {
      final model = CharacterModel.fromJson(tJson);

      expect(model, isA<CharacterModel>());
      expect(model.id, 1);
      expect(model.name, 'Rick Sanchez');
      expect(model.status, 'Alive');
      expect(model.species, 'Human');
      expect(model.gender, 'Male');
    });

    test('toEntity maps status alive correctly', () {
      final model = CharacterModel.fromJson(tJson);
      final entity = model.toEntity();

      expect(entity, isA<Character>());
      expect(entity.status, CharacterStatus.alive);
    });

    test('toEntity maps status dead correctly', () {
      final model = CharacterModel.fromJson({...tJson, 'status': 'Dead'});
      expect(model.toEntity().status, CharacterStatus.dead);
    });

    test('toEntity maps status unknown correctly', () {
      final model = CharacterModel.fromJson({...tJson, 'status': 'unknown'});
      expect(model.toEntity().status, CharacterStatus.unknown);
    });

    test('toEntity maps gender male correctly', () {
      final model = CharacterModel.fromJson(tJson);
      expect(model.toEntity().gender, CharacterGender.male);
    });

    test('toEntity maps gender female correctly', () {
      final model = CharacterModel.fromJson({...tJson, 'gender': 'Female'});
      expect(model.toEntity().gender, CharacterGender.female);
    });

    test('toEntity maps gender genderless correctly', () {
      final model =
          CharacterModel.fromJson({...tJson, 'gender': 'Genderless'});
      expect(model.toEntity().gender, CharacterGender.genderless);
    });

    test('toEntity maps gender unknown correctly', () {
      final model = CharacterModel.fromJson({...tJson, 'gender': 'unknown'});
      expect(model.toEntity().gender, CharacterGender.unknown);
    });

    test('toEntity maps all fields correctly', () {
      final entity = CharacterModel.fromJson(tJson).toEntity();

      expect(entity.id, 1);
      expect(entity.name, 'Rick Sanchez');
      expect(entity.species, 'Human');
      expect(entity.type, '');
      expect(entity.origin.name, 'Earth (C-137)');
      expect(entity.location.name, 'Citadel of Ricks');
    });
  });
}
