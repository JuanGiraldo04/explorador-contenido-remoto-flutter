import 'episode.dart';

class EpisodePage {
  const EpisodePage({
    required this.episodes,
    required this.currentPage,
    required this.totalPages,
  });

  final List<Episode> episodes;
  final int currentPage;
  final int totalPages;

  bool get hasNextPage => currentPage < totalPages;
}
