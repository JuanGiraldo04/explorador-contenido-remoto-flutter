import '../../../../core/errors/api_result.dart';
import '../../domain/domain.dart';
import '../datasources/datasources.dart';

class LocationRepositoryImpl implements LocationRepository {
  const LocationRepositoryImpl(this._dataSource);

  final LocationRemoteDataSource _dataSource;

  @override
  Result<LocationPage> getLocations({int page = 1, String? name}) =>
      executeApiCall(
        () async =>
            (await _dataSource.getLocations(page: page, name: name)).toEntity(),
      );
}
