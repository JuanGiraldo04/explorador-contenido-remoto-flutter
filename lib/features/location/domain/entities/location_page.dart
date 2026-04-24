import 'location.dart';

class LocationPage {
  const LocationPage({
    required this.locations,
    required this.currentPage,
    required this.totalPages,
  });

  final List<Location> locations;
  final int currentPage;
  final int totalPages;

  bool get hasNextPage => currentPage < totalPages;
}
