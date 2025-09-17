import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:test7/models/geofence.dart';

class GeofenceMap extends StatefulWidget {
  const GeofenceMap({
    super.key,
    required this.geoFences,
    required this.userLatitude,
    required this.userLongitude,
  });

  final List<Geofence> geoFences;
  final double? userLatitude;
  final double? userLongitude;

  @override
  State<GeofenceMap> createState() => _GeofenceMapState();
}

class _GeofenceMapState extends State<GeofenceMap> {
  final Completer<GoogleMapController> _mapController = Completer();
  static const double _defaultZoom = 15.0;

  Set<Marker> _markers = {};
  Set<Circle> _geofenceCircles = {};

  @override
  void initState() {
    super.initState();
    _buildGeofenceFeatures();
  }

  void _buildGeofenceFeatures() {
    _markers = widget.geoFences.map((geofence) {
      return Marker(
        markerId: MarkerId(geofence.id),
        position: LatLng(geofence.latitude, geofence.longitude),
        infoWindow: InfoWindow(title: geofence.name),
      );
    }).toSet();

    _geofenceCircles = widget.geoFences.map((geofence) {
      return Circle(
        circleId: CircleId(geofence.id),
        center: LatLng(geofence.latitude, geofence.longitude),
        radius: geofence.radius,
        fillColor: Colors.blue.withOpacity(0.2),
        strokeColor: Colors.blue.withOpacity(0.7),
        strokeWidth: 2,
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.userLatitude == null || widget.userLongitude == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final LatLng userLatLng = LatLng(
      widget.userLatitude!,
      widget.userLongitude!,
    );

    CameraPosition initialCameraPosition = CameraPosition(
      target: userLatLng,
      zoom: _defaultZoom,
    );

    return Container(
      height: 300,
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: GoogleMap(
          mapType: MapType.normal,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          initialCameraPosition: initialCameraPosition,
          markers: _markers,
          circles: _geofenceCircles,
          onMapCreated: (GoogleMapController controller) {
            _mapController.complete(controller);
          },
        ),
      ),
    );
  }
}
