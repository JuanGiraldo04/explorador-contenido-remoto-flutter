import 'package:explorador_contenido_remoto/core/errors/api_result.dart';
import 'package:explorador_contenido_remoto/core/errors/failure.dart';
import 'package:explorador_contenido_remoto/features/episode/domain/entities/episode.dart';
import 'package:explorador_contenido_remoto/features/episode/domain/entities/episode_page.dart';
import 'package:explorador_contenido_remoto/features/episode/domain/repositories/episode_repository.dart';
import 'package:explorador_contenido_remoto/features/episode/domain/usecases/get_episodes.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockEpisodeRepository extends Mock implements EpisodeRepository {
  @override
  Result<EpisodePage> getEpisodes({int? page = 1, String? name}) =>
      (super.noSuchMethod(
        Invocation.method(#getEpisodes, [], {#page: page, #name: name}),
        returnValue: Future.value(
          const ApiSuccess(
            EpisodePage(episodes: [], currentPage: 0, totalPages: 0),
          ),
        ),
      ) as Result<EpisodePage>);
}

void main() {
  late MockEpisodeRepository mockRepository;
  late GetEpisodes useCase;

  const tEpisode = Episode(
    id: 1,
    name: 'Pilot',
    airDate: 'December 2, 2013',
    code: 'S01E01',
    characterCount: 19,
  );

  const tEpisodePage = EpisodePage(
    episodes: [tEpisode],
    currentPage: 1,
    totalPages: 3,
  );

  setUp(() {
    mockRepository = MockEpisodeRepository();
    useCase = GetEpisodes(mockRepository);
  });

  group('GetEpisodes', () {
    test(
      'Given a successful repository call, returns ApiSuccess with EpisodePage',
      () async {
        when(
          mockRepository.getEpisodes(
            page: anyNamed('page'),
            name: anyNamed('name'),
          ),
        ).thenAnswer((_) async => const ApiSuccess(tEpisodePage));

        final result = await useCase();

        expect(result, isA<ApiSuccess<EpisodePage>>());
        final data = (result as ApiSuccess<EpisodePage>).data;
        expect(data.episodes, [tEpisode]);
        verify(mockRepository.getEpisodes(page: 1)).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test(
      'Given an empty page, returns ApiSuccess with empty episodes list',
      () async {
        const emptyPage = EpisodePage(episodes: [], currentPage: 1, totalPages: 1);
        when(
          mockRepository.getEpisodes(
            page: anyNamed('page'),
            name: anyNamed('name'),
          ),
        ).thenAnswer((_) async => const ApiSuccess(emptyPage));

        final result = await useCase();

        final data = (result as ApiSuccess<EpisodePage>).data;
        expect(data.episodes, isEmpty);
      },
    );

    test(
      'Given a network failure, returns ApiError with NetworkFailure',
      () async {
        when(
          mockRepository.getEpisodes(
            page: anyNamed('page'),
            name: anyNamed('name'),
          ),
        ).thenAnswer((_) async => const ApiError(NetworkFailure()));

        final result = await useCase();

        expect(result, isA<ApiError<EpisodePage>>());
        expect((result as ApiError<EpisodePage>).failure, isA<NetworkFailure>());
      },
    );

    test(
      'Given a name, passes it correctly to the repository',
      () async {
        when(
          mockRepository.getEpisodes(
            page: anyNamed('page'),
            name: anyNamed('name'),
          ),
        ).thenAnswer((_) async => const ApiSuccess(tEpisodePage));

        await useCase(page: 2, name: 'Pilot');

        verify(mockRepository.getEpisodes(page: 2, name: 'Pilot')).called(1);
      },
    );

    test(
      'Given a not found failure, returns ApiError with NotFoundFailure',
      () async {
        when(
          mockRepository.getEpisodes(
            page: anyNamed('page'),
            name: anyNamed('name'),
          ),
        ).thenAnswer((_) async => const ApiError(NotFoundFailure()));

        final result = await useCase(name: 'XYZ');

        expect((result as ApiError<EpisodePage>).failure, isA<NotFoundFailure>());
      },
    );
  });
}
