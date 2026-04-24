import '../../domain/entities/episode.dart';

class EpisodeModel {
  const EpisodeModel({
    required this.id,
    required this.name,
    required this.airDate,
    required this.code,
    required this.characterCount,
  });

  final int id;
  final String name;
  final String airDate;
  final String code;
  final int characterCount;

  factory EpisodeModel.fromJson(Map<String, dynamic> json) => EpisodeModel(
        id: json['id'] as int,
        name: json['name'] as String,
        airDate: json['air_date'] as String,
        code: json['episode'] as String,
        characterCount: (json['characters'] as List).length,
      );

  Episode toEntity() => Episode(
        id: id,
        name: name,
        airDate: airDate,
        code: code,
        characterCount: characterCount,
      );
}
