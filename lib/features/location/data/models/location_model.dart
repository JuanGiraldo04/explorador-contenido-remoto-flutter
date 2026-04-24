import '../../domain/entities/location.dart';

class LocationModel {
  const LocationModel({
    required this.id,
    required this.name,
    required this.type,
    required this.dimension,
    required this.residentCount,
  });

  final int id;
  final String name;
  final String type;
  final String dimension;
  final int residentCount;

  factory LocationModel.fromJson(Map<String, dynamic> json) => LocationModel(
        id: json['id'] as int,
        name: json['name'] as String,
        type: json['type'] as String,
        dimension: json['dimension'] as String,
        residentCount: (json['residents'] as List).length,
      );

  Location toEntity() => Location(
        id: id,
        name: name,
        type: type.isEmpty ? 'Desconocido' : type,
        dimension: dimension.isEmpty ? 'Desconocida' : dimension,
        residentCount: residentCount,
      );
}
