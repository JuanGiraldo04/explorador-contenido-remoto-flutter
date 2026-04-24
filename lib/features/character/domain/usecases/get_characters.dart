import '../../../../core/errors/api_result.dart';
import '../domain.dart';

class GetCharacters {
  const GetCharacters(this._repository);

  final CharacterRepository _repository;

  Result<CharacterPage> call({
    int page = 1,
    CharacterFilter filter = const CharacterFilter(),
  }) => _repository.getCharacters(page: page, filter: filter);
}
