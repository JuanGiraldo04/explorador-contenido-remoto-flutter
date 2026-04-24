import '../../../../core/errors/api_result.dart';
import '../../domain/domain.dart';
import '../datasources/datasources.dart';

class CharacterRepositoryImpl implements CharacterRepository {
  const CharacterRepositoryImpl(this._dataSource);

  final CharacterRemoteDataSource _dataSource;

  @override
  Result<CharacterPage> getCharacters({
    int page = 1,
    CharacterFilter filter = const CharacterFilter(),
  }) => executeApiCall(
    () async =>
        (await _dataSource.getCharacters(page: page, filter: filter)).toEntity(),
  );
}
