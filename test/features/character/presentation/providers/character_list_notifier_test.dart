import 'package:explorador_contenido_remoto/core/errors/api_result.dart';
import 'package:explorador_contenido_remoto/features/character/domain/entities/character.dart';
import 'package:explorador_contenido_remoto/features/character/domain/entities/character_filter.dart';
import 'package:explorador_contenido_remoto/features/character/domain/entities/character_page.dart';
import 'package:explorador_contenido_remoto/features/character/domain/usecases/get_characters.dart';
import 'package:explorador_contenido_remoto/features/character/presentation/providers/character_list_notifier.dart';
import 'package:explorador_contenido_remoto/features/character/presentation/providers/character_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockGetCharacters extends Mock implements GetCharacters {
  @override
  Result<CharacterPage> call({
    int? page = 1,
    CharacterFilter? filter = const CharacterFilter(),
  }) =>
      (super.noSuchMethod(
            Invocation.method(#call, [], {#page: page, #filter: filter}),
            returnValue: Future.value(
              const ApiSuccess(
                CharacterPage(characters: [], currentPage: 0, totalPages: 0),
              ),
            ),
          )
          as Result<CharacterPage>);
}

void main() {
  const tCharacter = Character(
    id: 1,
    name: 'Rick Sanchez',
    status: CharacterStatus.alive,
    species: 'Human',
    type: '',
    gender: CharacterGender.male,
    image: 'https://rickandmortyapi.com/api/character/avatar/1.jpeg',
    origin: CharacterLocation(name: 'Earth (C-137)', url: ''),
    location: CharacterLocation(name: 'Citadel of Ricks', url: ''),
  );

  const tCharacter2 = Character(
    id: 2,
    name: 'Morty Smith',
    status: CharacterStatus.alive,
    species: 'Human',
    type: '',
    gender: CharacterGender.male,
    image: 'https://rickandmortyapi.com/api/character/avatar/2.jpeg',
    origin: CharacterLocation(name: 'Earth (C-137)', url: ''),
    location: CharacterLocation(name: 'Earth (C-137)', url: ''),
  );

  const tPage1 = CharacterPage(
    characters: [tCharacter],
    currentPage: 1,
    totalPages: 2,
  );

  const tPage2 = CharacterPage(
    characters: [tCharacter2],
    currentPage: 2,
    totalPages: 2,
  );

  late MockGetCharacters mockGetCharacters;

  setUp(() {
    mockGetCharacters = MockGetCharacters();
  });

  ProviderContainer buildContainer() {
    return ProviderContainer(
      overrides: [getCharactersProvider.overrideWithValue(mockGetCharacters)],
    );
  }

  group('CharacterListNotifier', () {
    test('build loads first page of characters', () async {
      when(
        mockGetCharacters.call(page: anyNamed('page')),
      ).thenAnswer((_) async => const ApiSuccess(tPage1));

      final container = buildContainer();
      addTearDown(container.dispose);

      final result = await container.read(characterListProvider.future);

      expect(result.characters, [tCharacter]);
      expect(result.currentPage, 1);
      expect(result.totalPages, 2);
    });

    test('search resets to page 1 with the given filter', () async {
      when(
        mockGetCharacters.call(page: anyNamed('page')),
      ).thenAnswer((_) async => const ApiSuccess(tPage1));
      when(
        mockGetCharacters.call(
          page: anyNamed('page'),
          filter: anyNamed('filter'),
        ),
      ).thenAnswer((_) async => const ApiSuccess(tPage1));

      final container = buildContainer();
      addTearDown(container.dispose);

      await container.read(characterListProvider.future);
      await container
          .read(characterListProvider.notifier)
          .search(const CharacterFilter(name: 'Rick'));

      final state = container.read(characterListProvider).value!;
      expect(state.characters, [tCharacter]);
      expect(state.currentPage, 1);
    });

    test('loadNextPage appends characters from next page', () async {
      when(mockGetCharacters.call(page: anyNamed('page'))).thenAnswer((
        inv,
      ) async {
        final page = inv.namedArguments[#page] as int;
        return page == 1 ? const ApiSuccess(tPage1) : const ApiSuccess(tPage2);
      });

      final container = buildContainer();
      addTearDown(container.dispose);

      await container.read(characterListProvider.future);
      await container.read(characterListProvider.notifier).loadNextPage();

      final state = container.read(characterListProvider).value!;
      expect(state.characters.length, 2);
      expect(state.characters[0].name, 'Rick Sanchez');
      expect(state.characters[1].name, 'Morty Smith');
      expect(state.currentPage, 2);
    });

    test('loadNextPage does nothing when already on last page', () async {
      const lastPage = CharacterPage(
        characters: [tCharacter],
        currentPage: 2,
        totalPages: 2,
      );
      when(
        mockGetCharacters.call(page: anyNamed('page')),
      ).thenAnswer((_) async => const ApiSuccess(lastPage));

      final container = buildContainer();
      addTearDown(container.dispose);

      await container.read(characterListProvider.future);
      await container.read(characterListProvider.notifier).loadNextPage();

      // Only called once (build), not twice
      verify(mockGetCharacters.call(page: anyNamed('page'))).called(1);
    });
  });
}
