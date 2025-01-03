class LocationModel {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String description;

  LocationModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.description,
  });

  factory LocationModel.fromMap(Map<String, dynamic> map, String id) {
    return LocationModel(
      id: id,
      name: map['name'] ?? '',
      latitude: map['latitude'] ?? 0.0,
      longitude: map['longitude'] ?? 0.0,
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
    };
  }
}
