import 'package:explorador_contenido_remoto/core/providers/dio_provider.dart';
import 'package:explorador_contenido_remoto/features/character/data/data.dart';
import 'package:explorador_contenido_remoto/features/character/domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final characterRemoteDataSourceProvider = Provider<CharacterRemoteDataSource>((
  ref,
) {
  return CharacterRemoteDataSource(ref.watch(dioProvider));
});

final characterRepositoryProvider = Provider<CharacterRepository>((ref) {
  return CharacterRepositoryImpl(ref.watch(characterRemoteDataSourceProvider));
});

final getCharactersProvider = Provider<GetCharacters>((ref) {
  return GetCharacters(ref.watch(characterRepositoryProvider));
});
