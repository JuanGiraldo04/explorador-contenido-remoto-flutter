import '../../../../core/errors/api_result.dart';
import '../entities/entities.dart';

abstract interface class CharacterRepository {
  Result<CharacterPage> getCharacters({
    int page = 1,
    CharacterFilter filter = const CharacterFilter(),
  });
}
