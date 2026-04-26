import 'package:explorador_contenido_remoto/core/errors/api_result.dart';
import 'package:explorador_contenido_remoto/features/episode/data/datasources/remote/episode_remote_datasource.dart';
import 'package:explorador_contenido_remoto/features/episode/data/models/episode_model.dart';
import 'package:explorador_contenido_remoto/features/episode/data/models/episode_page_model.dart';
import 'package:explorador_contenido_remoto/features/episode/data/repositories/episode_repository_impl.dart';
import 'package:explorador_contenido_remoto/features/episode/domain/entities/episode.dart';
import 'package:explorador_contenido_remoto/features/episode/domain/entities/episode_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockEpisodeRemoteDataSource extends Mock
    implements EpisodeRemoteDataSource {
  @override
  Future<EpisodePageModel> getEpisodes({int? page = 1, String? name}) =>
      (super.noSuchMethod(
        Invocation.method(#getEpisodes, [], {#page: page, #name: name}),
        returnValue: Future.value(
          EpisodePageModel(episodes: const [], currentPage: 0, totalPages: 0),
        ),
      ) as Future<EpisodePageModel>);
}

void main() {
  late EpisodeRepositoryImpl repository;
  late MockEpisodeRemoteDataSource mockDataSource;

  final tEpisodePageModel = EpisodePageModel(
    episodes: [
      const EpisodeModel(
        id: 1,
        name: 'Pilot',
        airDate: 'December 2, 2013',
        code: 'S01E01',
        characterCount: 19,
      ),
    ],
    currentPage: 1,
    totalPages: 3,
  );

  setUp(() {
    mockDataSource = MockEpisodeRemoteDataSource();
    repository = EpisodeRepositoryImpl(mockDataSource);
  });

  group('EpisodeRepositoryImpl', () {
    group('getEpisodes', () {
      test('returns ApiSuccess with EpisodePage on success', () async {
        when(
          mockDataSource.getEpisodes(
            page: anyNamed('page'),
            name: anyNamed('name'),
          ),
        ).thenAnswer((_) async => tEpisodePageModel);

        final result = await repository.getEpisodes();

        expect(result, isA<ApiSuccess<EpisodePage>>());
        final data = (result as ApiSuccess<EpisodePage>).data;
        expect(data.episodes.length, 1);
        expect(data.currentPage, 1);
        expect(data.totalPages, 3);
      });

      test('returns ApiSuccess with converted Episode entities', () async {
        when(
          mockDataSource.getEpisodes(
            page: anyNamed('page'),
            name: anyNamed('name'),
          ),
        ).thenAnswer((_) async => tEpisodePageModel);

        final result = await repository.getEpisodes();

        final data = (result as ApiSuccess<EpisodePage>).data;
        expect(data.episodes.first, isA<Episode>());
        expect(data.episodes.first.name, 'Pilot');
        expect(data.episodes.first.code, 'S01E01');
      });

      test('returns ApiError when datasource throws', () async {
        when(
          mockDataSource.getEpisodes(
            page: anyNamed('page'),
            name: anyNamed('name'),
          ),
        ).thenThrow(Exception('Network error'));

        final result = await repository.getEpisodes();

        expect(result, isA<ApiError<EpisodePage>>());
      });

      test('passes name param to datasource', () async {
        when(
          mockDataSource.getEpisodes(
            page: anyNamed('page'),
            name: anyNamed('name'),
          ),
        ).thenAnswer((_) async => tEpisodePageModel);

        await repository.getEpisodes(page: 2, name: 'Pilot');

        verify(mockDataSource.getEpisodes(page: 2, name: 'Pilot')).called(1);
      });
    });
  });
}
