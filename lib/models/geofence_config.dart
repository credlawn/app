class GeofenceConfig {
  final String locationName;
  final double latitude;
  final double longitude;
  final double radius;
  final String? officeStartTime;
  final String? officeEndTime;

  GeofenceConfig({
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.radius,
    this.officeStartTime,
    this.officeEndTime,
  });

  factory GeofenceConfig.fromJson(Map<String, dynamic> json) {
    return GeofenceConfig(
      locationName: json['location_name'] ?? 'Unknown Location',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      radius: (json['radius'] as num).toDouble(),
      officeStartTime: json['office_start_time'],
      officeEndTime: json['office_end_time'],
    );
  }
}
