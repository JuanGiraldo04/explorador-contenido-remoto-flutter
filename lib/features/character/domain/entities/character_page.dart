import 'character.dart';

class CharacterPage {
  const CharacterPage({
    required this.characters,
    required this.currentPage,
    required this.totalPages,
  });

  final List<Character> characters;
  final int currentPage;
  final int totalPages;

  bool get hasNextPage => currentPage < totalPages;
}
