import 'package:explorador_contenido_remoto/core/errors/api_result.dart';
import 'package:explorador_contenido_remoto/core/errors/failure.dart';
import 'package:explorador_contenido_remoto/features/character/domain/entities/character.dart';
import 'package:explorador_contenido_remoto/features/character/domain/entities/character_filter.dart';
import 'package:explorador_contenido_remoto/features/character/domain/entities/character_page.dart';
import 'package:explorador_contenido_remoto/features/character/domain/repositories/character_repository.dart';
import 'package:explorador_contenido_remoto/features/character/domain/usecases/get_characters.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockCharacterRepository extends Mock implements CharacterRepository {
  @override
  Result<CharacterPage> getCharacters({
    int? page = 1,
    CharacterFilter? filter = const CharacterFilter(),
  }) =>
      (super.noSuchMethod(
        Invocation.method(#getCharacters, [], {#page: page, #filter: filter}),
        returnValue: Future.value(
          const ApiSuccess(
            CharacterPage(characters: [], currentPage: 0, totalPages: 0),
          ),
        ),
      ) as Result<CharacterPage>);
}

void main() {
  late MockCharacterRepository mockRepository;
  late GetCharacters useCase;

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

  const tCharacterPage = CharacterPage(
    characters: [tCharacter],
    currentPage: 1,
    totalPages: 42,
  );

  setUp(() {
    mockRepository = MockCharacterRepository();
    useCase = GetCharacters(mockRepository);
  });

  group('GetCharacters', () {
    test(
      'Given a successful repository call, returns ApiSuccess with CharacterPage',
      () async {
        when(
          mockRepository.getCharacters(
            page: anyNamed('page'),
            filter: anyNamed('filter'),
          ),
        ).thenAnswer((_) async => const ApiSuccess(tCharacterPage));

        final result = await useCase();

        expect(result, isA<ApiSuccess<CharacterPage>>());
        final data = (result as ApiSuccess<CharacterPage>).data;
        expect(data.characters, [tCharacter]);
        expect(data.currentPage, 1);
        verify(mockRepository.getCharacters(page: 1)).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test(
      'Given an empty page, returns ApiSuccess with empty characters list',
      () async {
        const emptyPage = CharacterPage(
          characters: [],
          currentPage: 1,
          totalPages: 1,
        );
        when(
          mockRepository.getCharacters(
            page: anyNamed('page'),
            filter: anyNamed('filter'),
          ),
        ).thenAnswer((_) async => const ApiSuccess(emptyPage));

        final result = await useCase();

        final data = (result as ApiSuccess<CharacterPage>).data;
        expect(data.characters, isEmpty);
      },
    );

    test(
      'Given a network failure, returns ApiError with NetworkFailure',
      () async {
        when(
          mockRepository.getCharacters(
            page: anyNamed('page'),
            filter: anyNamed('filter'),
          ),
        ).thenAnswer((_) async => const ApiError(NetworkFailure()));

        final result = await useCase();

        expect(result, isA<ApiError<CharacterPage>>());
        expect((result as ApiError<CharacterPage>).failure, isA<NetworkFailure>());
      },
    );

    test(
      'Given a filter, passes it correctly to the repository',
      () async {
        const filter = CharacterFilter(name: 'Rick', status: CharacterStatus.alive);
        when(
          mockRepository.getCharacters(
            page: anyNamed('page'),
            filter: anyNamed('filter'),
          ),
        ).thenAnswer((_) async => const ApiSuccess(tCharacterPage));

        await useCase(page: 2, filter: filter);

        verify(mockRepository.getCharacters(page: 2, filter: filter)).called(1);
      },
    );

    test(
      'Given a server error, returns ApiError with ServerErrorFailure',
      () async {
        when(
          mockRepository.getCharacters(
            page: anyNamed('page'),
            filter: anyNamed('filter'),
          ),
        ).thenAnswer((_) async => const ApiError(ServerErrorFailure()));

        final result = await useCase();

        expect((result as ApiError<CharacterPage>).failure, isA<ServerErrorFailure>());
      },
    );
  });
}
