import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationModel {
  const LocationModel({
    required this.latitude,
    required this.longitude,
    required this.updatedAt,
  });

  final double latitude;
  final double longitude;
  final DateTime updatedAt;

  LatLng get latLng => LatLng(latitude, longitude);

  String get coordinates => formatCoordinates(latitude, longitude);

  static String formatCoordinates(double latitude, double longitude) {
    return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  }
}
