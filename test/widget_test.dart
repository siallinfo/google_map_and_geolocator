import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_and_geolocator/models/location_model.dart';

void main() {
  test('formats latitude and longitude for the marker info window', () {
    expect(
      LocationModel.formatCoordinates(37.4219983, -122.084),
      '37.421998, -122.084000',
    );
  });
}
