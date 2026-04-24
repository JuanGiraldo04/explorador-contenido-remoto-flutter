import '../../domain/entities/character.dart';

class CharacterLocationModel {
  const CharacterLocationModel({required this.name, required this.url});

  final String name;
  final String url;

  factory CharacterLocationModel.fromJson(Map<String, dynamic> json) =>
      CharacterLocationModel(
        name: json['name'] as String,
        url: json['url'] as String,
      );

  CharacterLocation toEntity() => CharacterLocation(name: name, url: url);
}

class CharacterModel {
  const CharacterModel({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.type,
    required this.gender,
    required this.image,
    required this.origin,
    required this.location,
  });

  final int id;
  final String name;
  final String status;
  final String species;
  final String type;
  final String gender;
  final String image;
  final CharacterLocationModel origin;
  final CharacterLocationModel location;

  factory CharacterModel.fromJson(Map<String, dynamic> json) => CharacterModel(
        id: json['id'] as int,
        name: json['name'] as String,
        status: json['status'] as String,
        species: json['species'] as String,
        type: json['type'] as String,
        gender: json['gender'] as String,
        image: json['image'] as String,
        origin: CharacterLocationModel.fromJson(
          json['origin'] as Map<String, dynamic>,
        ),
        location: CharacterLocationModel.fromJson(
          json['location'] as Map<String, dynamic>,
        ),
      );

  Character toEntity() => Character(
        id: id,
        name: name,
        status: _parseStatus(status),
        species: species,
        type: type,
        gender: _parseGender(gender),
        image: image,
        origin: origin.toEntity(),
        location: location.toEntity(),
      );

  static CharacterStatus _parseStatus(String value) =>
      switch (value.toLowerCase()) {
        'alive' => CharacterStatus.alive,
        'dead' => CharacterStatus.dead,
        _ => CharacterStatus.unknown,
      };

  static CharacterGender _parseGender(String value) =>
      switch (value.toLowerCase()) {
        'female' => CharacterGender.female,
        'male' => CharacterGender.male,
        'genderless' => CharacterGender.genderless,
        _ => CharacterGender.unknown,
      };
}
