import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/dio_provider.dart';
import '../../data/datasources/remote/location_remote_datasource.dart';
import '../../data/repositories/location_repository_impl.dart';
import '../../domain/repositories/location_repository.dart';
import '../../domain/usecases/get_locations.dart';

final locationRemoteDataSourceProvider = Provider<LocationRemoteDataSource>((
  ref,
) {
  return LocationRemoteDataSource(ref.watch(dioProvider));
});

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepositoryImpl(ref.watch(locationRemoteDataSourceProvider));
});

final getLocationsProvider = Provider<GetLocations>((ref) {
  return GetLocations(ref.watch(locationRepositoryProvider));
});
