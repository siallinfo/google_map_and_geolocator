import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_and_geolocator/controllers/location_controller.dart';
import 'package:google_maps_and_geolocator/models/location_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationMapScreen extends StatefulWidget {
  const LocationMapScreen({super.key});

  @override
  State<LocationMapScreen> createState() => _LocationMapScreenState();
}

class _LocationMapScreenState extends State<LocationMapScreen> {
  static const _initialCameraPosition = CameraPosition(
    target: LatLng(0, 0),
    zoom: 2,
  );

  final LocationController _locationController = LocationController();
  GoogleMapController? _mapController;
  MapType _mapType = MapType.normal;
  DateTime? _lastAnimatedAt;

  @override
  void initState() {
    super.initState();
    _locationController.addListener(_onLocationChanged);
    _locationController.startTracking();
  }

  @override
  void dispose() {
    _locationController.removeListener(_onLocationChanged);
    _locationController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _onLocationChanged() {
    final location = _locationController.currentLocation;
    if (location == null || location.updatedAt == _lastAnimatedAt) return;

    _lastAnimatedAt = location.updatedAt;
    unawaited(_animateTo(location.latLng));
  }

  Future<void> _animateTo(LatLng point) async {
    final controller = _mapController;
    if (controller == null) return;

    await controller.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: point, zoom: 16)),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    final location = _locationController.currentLocation;
    if (location != null) unawaited(_animateTo(location.latLng));
  }

  Set<Marker> _buildMarkers(LocationModel? location) {
    if (location == null) return const {};

    return {
      Marker(
        markerId: const MarkerId('current_location'),
        position: location.latLng,
        infoWindow: InfoWindow(
          title: 'My current location',
          snippet: location.coordinates,
        ),
      ),
    };
  }

  Set<Polyline> _buildPolylines(List<LatLng> route) {
    if (route.length < 2) return const {};

    return {
      Polyline(
        polylineId: const PolylineId('location_track'),
        points: route,
        color: const Color(0xFF4285F4),
        width: 5,
      ),
    };
  }

  String _formatUpdateTime(DateTime dateTime) {
    final localTime = dateTime.toLocal();
    final hour = localTime.hour.toString().padLeft(2, '0');
    final minute = localTime.minute.toString().padLeft(2, '0');
    final second = localTime.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _locationController,
      builder: (context, _) {
        final location = _locationController.currentLocation;
        final error = _locationController.error;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFF2196F3),
            foregroundColor: Colors.white,
            elevation: 3,
            systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
              statusBarColor: const Color(0xFF1976D2),
            ),
            title: const Text(
              'Real-Time Location Tracker',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            actions: [
              PopupMenuButton<MapType>(
                tooltip: 'Change map type',
                icon: const Icon(Icons.layers),
                onSelected: (mapType) => setState(() => _mapType = mapType),
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: MapType.normal,
                    child: Text('Normal'),
                  ),
                  PopupMenuItem(
                    value: MapType.satellite,
                    child: Text('Satellite'),
                  ),
                  PopupMenuItem(
                    value: MapType.terrain,
                    child: Text('Terrain'),
                  ),
                  PopupMenuItem(
                    value: MapType.hybrid,
                    child: Text('Hybrid'),
                  ),
                ],
              ),
            ],
          ),
          body: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: _initialCameraPosition,
                mapType: _mapType,
                onMapCreated: _onMapCreated,
                markers: _buildMarkers(location),
                polylines: _buildPolylines(_locationController.route),
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
                mapToolbarEnabled: false,
                compassEnabled: true,
                zoomControlsEnabled: true,
              ),
              if (location != null)
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.my_location,
                            color: Color(0xFF176B5B),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  location.coordinates,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Updated ${_formatUpdateTime(location.updatedAt)} · every 10 seconds',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (location == null && error == null)
                const Center(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Text('Finding your location...'),
                    ),
                  ),
                ),
              if (error != null)
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Expanded(child: Text(error)),
                          TextButton(
                            onPressed: _locationController.isFetching
                                ? null
                                : () => unawaited(
                                    _locationController.refreshLocation(
                                      requestPermission: true,
                                    ),
                                  ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
