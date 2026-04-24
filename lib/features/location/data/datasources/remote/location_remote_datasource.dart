import 'package:dio/dio.dart';

import '../../../../../core/api/api_endpoints.dart';
import '../../models/models.dart';

class LocationRemoteDataSource {
  const LocationRemoteDataSource(this._dio);

  final Dio _dio;

  Future<LocationPageModel> getLocations({int page = 1, String? name}) async {
    final response = await _dio.get(
      ApiEndpoints.locations,
      queryParameters: {
        'page': page,
        if (name != null && name.isNotEmpty) 'name': name,
      },
    );
    return LocationPageModel.fromJson(
      response.data as Map<String, dynamic>,
      page: page,
    );
  }
}
