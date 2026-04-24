import '../../domain/entities/character_page.dart';
import 'character_model.dart';

class CharacterPageModel {
  const CharacterPageModel({
    required this.characters,
    required this.currentPage,
    required this.totalPages,
  });

  final List<CharacterModel> characters;
  final int currentPage;
  final int totalPages;

  factory CharacterPageModel.fromJson(
    Map<String, dynamic> json, {
    required int page,
  }) {
    final info = json['info'] as Map<String, dynamic>;
    final results = (json['results'] as List)
        .map((e) => CharacterModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return CharacterPageModel(
      totalPages: info['pages'] as int,
      currentPage: page,
      characters: results,
    );
  }

  CharacterPage toEntity() => CharacterPage(
        characters: characters.map((m) => m.toEntity()).toList(),
        currentPage: currentPage,
        totalPages: totalPages,
      );
}
