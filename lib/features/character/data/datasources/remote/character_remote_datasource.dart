import 'package:dio/dio.dart';

import '../../../../../core/api/api_endpoints.dart';
import '../../../domain/entities/entities.dart';
import '../../models/models.dart';

class CharacterRemoteDataSource {
  const CharacterRemoteDataSource(this._dio);

  final Dio _dio;

  Future<CharacterPageModel> getCharacters({
    int page = 1,
    CharacterFilter filter = const CharacterFilter(),
  }) async {
    final response = await _dio.get(
      ApiEndpoints.characters,
      queryParameters: {
        'page': page,
        if (filter.name != null && filter.name!.isNotEmpty)
          'name': filter.name!,
        if (filter.status != null) 'status': filter.status!.name,
      },
    );
    return CharacterPageModel.fromJson(
      response.data as Map<String, dynamic>,
      page: page,
    );
  }
}
