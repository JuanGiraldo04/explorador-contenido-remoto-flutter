import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/dio_provider.dart';
import '../../data/datasources/remote/episode_remote_datasource.dart';
import '../../data/repositories/episode_repository_impl.dart';
import '../../domain/repositories/episode_repository.dart';
import '../../domain/usecases/get_episodes.dart';

final episodeRemoteDataSourceProvider = Provider<EpisodeRemoteDataSource>((
  ref,
) {
  return EpisodeRemoteDataSource(ref.watch(dioProvider));
});

final episodeRepositoryProvider = Provider<EpisodeRepository>((ref) {
  return EpisodeRepositoryImpl(ref.watch(episodeRemoteDataSourceProvider));
});

final getEpisodesProvider = Provider<GetEpisodes>((ref) {
  return GetEpisodes(ref.watch(episodeRepositoryProvider));
});
