import '../../../../core/errors/api_result.dart';
import '../entities/entities.dart';

abstract interface class LocationRepository {
  Result<LocationPage> getLocations({int page = 1, String? name});
}
