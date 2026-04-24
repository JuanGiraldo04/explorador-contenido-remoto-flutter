import '../../../../core/errors/api_result.dart';
import '../entities/entities.dart';

abstract interface class EpisodeRepository {
  Result<EpisodePage> getEpisodes({int page = 1, String? name});
}
