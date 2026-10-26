import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_and_geolocator/models/location_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationController extends ChangeNotifier {
  static const trackingInterval = Duration(seconds: 10);

  final List<LatLng> _route = [];
  Timer? _locationTimer;
  LocationModel? _currentLocation;
  String? _error;
  bool _isFetching = false;
  bool _isDisposed = false;

  LocationModel? get currentLocation => _currentLocation;
  List<LatLng> get route => List.unmodifiable(_route);
  String? get error => _error;
  bool get isFetching => _isFetching;
  bool get isTracking => _locationTimer != null;

  void startTracking() {
    if (_locationTimer != null) return;

    _locationTimer = Timer.periodic(
      trackingInterval,
      (_) => unawaited(refreshLocation()),
    );
    notifyListeners();
    unawaited(refreshLocation(requestPermission: true));
  }

  Future<void> refreshLocation({bool requestPermission = false}) async {
    if (_isFetching || _isDisposed) return;

    _isFetching = true;
    _notifyIfActive();

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw Exception('Turn on location services to show your position.');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied && requestPermission) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission was denied. Tap Try again to retry.');
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Location permission is disabled. Enable it in your device settings.',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      if (_isDisposed) return;

      final location = LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
        updatedAt: DateTime.now(),
      );
      _currentLocation = location;
      _route.add(location.latLng);
      _error = null;
    } on Exception catch (error) {
      if (!_isDisposed) {
        _error = error.toString().replaceFirst('Exception: ', '');
      }
    } finally {
      _isFetching = false;
      _notifyIfActive();
    }
  }

  void _notifyIfActive() {
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _locationTimer?.cancel();
    super.dispose();
  }
}
