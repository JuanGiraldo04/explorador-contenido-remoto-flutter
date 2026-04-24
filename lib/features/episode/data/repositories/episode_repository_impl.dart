import '../../../../core/errors/api_result.dart';
import '../../domain/domain.dart';
import '../datasources/datasources.dart';

class EpisodeRepositoryImpl implements EpisodeRepository {
  const EpisodeRepositoryImpl(this._dataSource);

  final EpisodeRemoteDataSource _dataSource;

  @override
  Result<EpisodePage> getEpisodes({int page = 1, String? name}) =>
      executeApiCall(
        () async =>
            (await _dataSource.getEpisodes(page: page, name: name)).toEntity(),
      );
}
