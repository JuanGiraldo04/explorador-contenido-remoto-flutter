import '../../../../core/errors/api_result.dart';
import '../domain.dart';

class GetEpisodes {
  const GetEpisodes(this._repository);

  final EpisodeRepository _repository;

  Result<EpisodePage> call({int page = 1, String? name}) =>
      _repository.getEpisodes(page: page, name: name);
}
