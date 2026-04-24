enum CharacterStatus { alive, dead, unknown }

enum CharacterGender { female, male, genderless, unknown }

class CharacterLocation {
  const CharacterLocation({required this.name, required this.url});

  final String name;
  final String url;
}

class Character {
  const Character({
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
  final CharacterStatus status;
  final String species;
  final String type;
  final CharacterGender gender;
  final String image;
  final CharacterLocation origin;
  final CharacterLocation location;
}
