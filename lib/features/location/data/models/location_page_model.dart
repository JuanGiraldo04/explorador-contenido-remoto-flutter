import '../../domain/entities/location_page.dart';
import 'location_model.dart';

class LocationPageModel {
  const LocationPageModel({
    required this.locations,
    required this.currentPage,
    required this.totalPages,
  });

  final List<LocationModel> locations;
  final int currentPage;
  final int totalPages;

  factory LocationPageModel.fromJson(
    Map<String, dynamic> json, {
    required int page,
  }) {
    final info = json['info'] as Map<String, dynamic>;
    final results = (json['results'] as List)
        .map((e) => LocationModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return LocationPageModel(
      totalPages: info['pages'] as int,
      currentPage: page,
      locations: results,
    );
  }

  LocationPage toEntity() => LocationPage(
        locations: locations.map((m) => m.toEntity()).toList(),
        currentPage: currentPage,
        totalPages: totalPages,
      );
}
