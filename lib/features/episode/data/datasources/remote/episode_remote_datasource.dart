import 'package:dio/dio.dart';

import '../../../../../core/api/api_endpoints.dart';
import '../../models/models.dart';

class EpisodeRemoteDataSource {
  const EpisodeRemoteDataSource(this._dio);

  final Dio _dio;

  Future<EpisodePageModel> getEpisodes({int page = 1, String? name}) async {
    final response = await _dio.get(
      ApiEndpoints.episodes,
      queryParameters: {
        'page': page,
        if (name != null && name.isNotEmpty) 'name': name,
      },
    );
    return EpisodePageModel.fromJson(
      response.data as Map<String, dynamic>,
      page: page,
    );
  }
}
