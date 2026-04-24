import '../../../../core/errors/api_result.dart';
import '../entities/location_page.dart';
import '../repositories/location_repository.dart';

class GetLocations {
  const GetLocations(this._repository);

  final LocationRepository _repository;

  Result<LocationPage> call({int page = 1, String? name}) =>
      _repository.getLocations(page: page, name: name);
}
