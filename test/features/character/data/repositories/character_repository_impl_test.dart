import 'package:explorador_contenido_remoto/core/errors/api_result.dart';
import 'package:explorador_contenido_remoto/features/character/data/datasources/remote/character_remote_datasource.dart';
import 'package:explorador_contenido_remoto/features/character/data/models/character_model.dart';
import 'package:explorador_contenido_remoto/features/character/data/models/character_page_model.dart';
import 'package:explorador_contenido_remoto/features/character/data/repositories/character_repository_impl.dart';
import 'package:explorador_contenido_remoto/features/character/domain/entities/character.dart';
import 'package:explorador_contenido_remoto/features/character/domain/entities/character_filter.dart';
import 'package:explorador_contenido_remoto/features/character/domain/entities/character_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockCharacterRemoteDataSource extends Mock
    implements CharacterRemoteDataSource {
  @override
  Future<CharacterPageModel> getCharacters({
    int? page = 1,
    CharacterFilter? filter = const CharacterFilter(),
  }) =>
      (super.noSuchMethod(
        Invocation.method(#getCharacters, [], {#page: page, #filter: filter}),
        returnValue: Future.value(
          CharacterPageModel(characters: const [], currentPage: 0, totalPages: 0),
        ),
      ) as Future<CharacterPageModel>);
}

void main() {
  late CharacterRepositoryImpl repository;
  late MockCharacterRemoteDataSource mockDataSource;

  final tCharacterPageModel = CharacterPageModel(
    characters: [
      const CharacterModel(
        id: 1,
        name: 'Rick Sanchez',
        status: 'Alive',
        species: 'Human',
        type: '',
        gender: 'Male',
        image: 'https://rickandmortyapi.com/api/character/avatar/1.jpeg',
        origin: CharacterLocationModel(name: 'Earth (C-137)', url: ''),
        location: CharacterLocationModel(name: 'Citadel of Ricks', url: ''),
      ),
    ],
    currentPage: 1,
    totalPages: 42,
  );

  setUp(() {
    mockDataSource = MockCharacterRemoteDataSource();
    repository = CharacterRepositoryImpl(mockDataSource);
  });

  group('CharacterRepositoryImpl', () {
    group('getCharacters', () {
      test('returns ApiSuccess with CharacterPage on success', () async {
        when(
          mockDataSource.getCharacters(
            page: anyNamed('page'),
            filter: anyNamed('filter'),
          ),
        ).thenAnswer((_) async => tCharacterPageModel);

        final result = await repository.getCharacters();

        expect(result, isA<ApiSuccess<CharacterPage>>());
        final data = (result as ApiSuccess<CharacterPage>).data;
        expect(data.characters.length, 1);
        expect(data.characters.first.name, 'Rick Sanchez');
        expect(data.currentPage, 1);
        expect(data.totalPages, 42);
      });

      test('returns ApiSuccess with converted entities', () async {
        when(
          mockDataSource.getCharacters(
            page: anyNamed('page'),
            filter: anyNamed('filter'),
          ),
        ).thenAnswer((_) async => tCharacterPageModel);

        final result = await repository.getCharacters();

        final data = (result as ApiSuccess<CharacterPage>).data;
        expect(data.characters.first, isA<Character>());
        expect(data.characters.first.status, CharacterStatus.alive);
      });

      test(
        'returns ApiError with NetworkFailure when datasource throws DioException',
        () async {
          when(
            mockDataSource.getCharacters(
              page: anyNamed('page'),
              filter: anyNamed('filter'),
            ),
          ).thenThrow(Exception('Network error'));

          final result = await repository.getCharacters();

          expect(result, isA<ApiError<CharacterPage>>());
        },
      );

      test('passes filter to datasource', () async {
        const filter = CharacterFilter(name: 'Rick');
        when(
          mockDataSource.getCharacters(
            page: anyNamed('page'),
            filter: anyNamed('filter'),
          ),
        ).thenAnswer((_) async => tCharacterPageModel);

        await repository.getCharacters(page: 2, filter: filter);

        verify(mockDataSource.getCharacters(page: 2, filter: filter)).called(1);
      });
    });
  });
}
