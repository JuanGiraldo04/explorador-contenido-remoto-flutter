import 'character.dart';

class CharacterFilter {
  const CharacterFilter({this.name, this.status});

  final String? name;
  final CharacterStatus? status;

  bool get isEmpty => (name == null || name!.isEmpty) && status == null;
}
