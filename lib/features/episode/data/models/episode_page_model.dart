import '../../domain/entities/episode_page.dart';
import 'episode_model.dart';

class EpisodePageModel {
  const EpisodePageModel({
    required this.episodes,
    required this.currentPage,
    required this.totalPages,
  });

  final List<EpisodeModel> episodes;
  final int currentPage;
  final int totalPages;

  factory EpisodePageModel.fromJson(
    Map<String, dynamic> json, {
    required int page,
  }) {
    final info = json['info'] as Map<String, dynamic>;
    final results = (json['results'] as List)
        .map((e) => EpisodeModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return EpisodePageModel(
      totalPages: info['pages'] as int,
      currentPage: page,
      episodes: results,
    );
  }

  EpisodePage toEntity() => EpisodePage(
        episodes: episodes.map((m) => m.toEntity()).toList(),
        currentPage: currentPage,
        totalPages: totalPages,
      );
}
