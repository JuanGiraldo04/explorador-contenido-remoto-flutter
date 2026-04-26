import 'package:explorador_contenido_remoto/core/errors/api_result.dart';
import 'package:explorador_contenido_remoto/features/episode/domain/entities/episode.dart';
import 'package:explorador_contenido_remoto/features/episode/domain/entities/episode_page.dart';
import 'package:explorador_contenido_remoto/features/episode/domain/usecases/get_episodes.dart';
import 'package:explorador_contenido_remoto/features/episode/presentation/providers/episode_list_notifier.dart';
import 'package:explorador_contenido_remoto/features/episode/presentation/providers/episode_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockGetEpisodes extends Mock implements GetEpisodes {
  @override
  Result<EpisodePage> call({int? page = 1, String? name}) =>
      (super.noSuchMethod(
            Invocation.method(#call, [], {#page: page, #name: name}),
            returnValue: Future.value(
              const ApiSuccess(
                EpisodePage(episodes: [], currentPage: 0, totalPages: 0),
              ),
            ),
          )
          as Result<EpisodePage>);
}

void main() {
  const tEpisode = Episode(
    id: 1,
    name: 'Pilot',
    airDate: 'December 2, 2013',
    code: 'S01E01',
    characterCount: 19,
  );

  const tEpisode2 = Episode(
    id: 2,
    name: 'Lawnmower Dog',
    airDate: 'December 9, 2013',
    code: 'S01E02',
    characterCount: 5,
  );

  const tPage1 = EpisodePage(
    episodes: [tEpisode],
    currentPage: 1,
    totalPages: 3,
  );

  const tPage2 = EpisodePage(
    episodes: [tEpisode2],
    currentPage: 2,
    totalPages: 3,
  );

  late MockGetEpisodes mockGetEpisodes;

  setUp(() {
    mockGetEpisodes = MockGetEpisodes();
  });

  ProviderContainer buildContainer() {
    return ProviderContainer(
      overrides: [getEpisodesProvider.overrideWithValue(mockGetEpisodes)],
    );
  }

  group('EpisodeListNotifier', () {
    test('build loads first page of episodes', () async {
      when(
        mockGetEpisodes.call(page: anyNamed('page')),
      ).thenAnswer((_) async => const ApiSuccess(tPage1));

      final container = buildContainer();
      addTearDown(container.dispose);

      final result = await container.read(episodeListProvider.future);

      expect(result.episodes, [tEpisode]);
      expect(result.currentPage, 1);
      expect(result.totalPages, 3);
    });

    test('search resets to page 1 and filters by name', () async {
      when(
        mockGetEpisodes.call(page: anyNamed('page')),
      ).thenAnswer((_) async => const ApiSuccess(tPage1));
      when(
        mockGetEpisodes.call(page: anyNamed('page'), name: anyNamed('name')),
      ).thenAnswer((_) async => const ApiSuccess(tPage1));

      final container = buildContainer();
      addTearDown(container.dispose);

      await container.read(episodeListProvider.future);
      await container.read(episodeListProvider.notifier).search('Pilot');

      final state = container.read(episodeListProvider).value!;
      expect(state.episodes, [tEpisode]);
      expect(state.name, 'Pilot');
      expect(state.currentPage, 1);
    });

    test('search with empty string resets name in state', () async {
      when(
        mockGetEpisodes.call(page: anyNamed('page')),
      ).thenAnswer((_) async => const ApiSuccess(tPage1));
      when(
        mockGetEpisodes.call(page: anyNamed('page'), name: anyNamed('name')),
      ).thenAnswer((_) async => const ApiSuccess(tPage1));

      final container = buildContainer();
      addTearDown(container.dispose);

      await container.read(episodeListProvider.future);
      await container.read(episodeListProvider.notifier).search('Pilot');
      await container.read(episodeListProvider.notifier).search('');

      final state = container.read(episodeListProvider).value!;
      expect(state.name, '');
    });

    test('loadNextPage appends episodes and preserves name', () async {
      when(
        mockGetEpisodes.call(page: anyNamed('page')),
      ).thenAnswer((_) async => const ApiSuccess(tPage1));
      when(
        mockGetEpisodes.call(page: anyNamed('page'), name: anyNamed('name')),
      ).thenAnswer((inv) async {
        final page = inv.namedArguments[#page] as int;
        return page == 2 ? const ApiSuccess(tPage2) : const ApiSuccess(tPage1);
      });

      final container = buildContainer();
      addTearDown(container.dispose);

      await container.read(episodeListProvider.future);
      await container.read(episodeListProvider.notifier).loadNextPage();

      final state = container.read(episodeListProvider).value!;
      expect(state.episodes.length, 2);
      expect(state.currentPage, 2);
    });
  });
}
