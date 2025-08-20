import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/farm.dart';

class MapScreen extends StatefulWidget {
  final List<Farm> farms;

  const MapScreen({Key? key, required this.farms}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  LatLng? _initialPosition;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  void _initializeMap() {
    if (widget.farms.isNotEmpty) {
      // Use first farm with valid location as initial position
      final firstFarmWithLocation = widget.farms.firstWhere(
        (farm) => farm.geoPoint != null,
        orElse: () => widget.farms.first,
      );
      
      _initialPosition = firstFarmWithLocation.geoPoint != null
          ? LatLng(
              firstFarmWithLocation.geoPoint!.latitude,
              firstFarmWithLocation.geoPoint!.longitude,
            )
          : const LatLng(0, 0); // Fallback position
    } else {
      _initialPosition = const LatLng(0, 0); // Default position
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm Locations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _zoomToFarms,
          ),
        ],
      ),
      body: _initialPosition == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _initialPosition!,
                zoom: 12,
              ),
              markers: _buildMarkers(),
              onMapCreated: (controller) {
                setState(() {
                  mapController = controller;
                });
                // Small delay to ensure map is fully loaded
                Future.delayed(const Duration(milliseconds: 500), _zoomToFarms);
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _zoomToFarms,
        child: const Icon(Icons.zoom_out_map),
      ),
    );
  }

  Set<Marker> _buildMarkers() {
    return widget.farms.where((farm) => farm.geoPoint != null).map((farm) {
        return Marker(
          markerId: MarkerId(farm.id),
          position: LatLng(farm.geoPoint!.latitude, farm.geoPoint!.longitude),
          infoWindow: InfoWindow(
            title: farm.name,
            snippet: farm.isVerified ? 'Verified' : null,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            farm.isVerified 
                ? BitmapDescriptor.hueGreen 
                : BitmapDescriptor.hueOrange,
          ),
        );
    }).toSet();
  }

  Future<void> _zoomToFarms() async {
    if (widget.farms.isEmpty) return;

    final farmsWithLocation = widget.farms.where((f) => f.geoPoint != null).toList();
    if (farmsWithLocation.isEmpty) return;

    if (farmsWithLocation.length == 1) {
      // Single farm - zoom to its location
      final farm = farmsWithLocation.first;
      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(farm.geoPoint!.latitude, farm.geoPoint!.longitude),
          14,
        ),
      );
    } else {
      // Multiple farms - calculate bounds
      final bounds = _calculateBounds(farmsWithLocation);
      mapController.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 50),
      );
    }
  }

  LatLngBounds _calculateBounds(List<Farm> farms) {
    double? minLat, maxLat, minLng, maxLng;

    for (final farm in farms) {
      if (farm.geoPoint == null) continue;
      
      final lat = farm.geoPoint!.latitude;
      final lng = farm.geoPoint!.longitude;

      minLat = minLat == null ? lat : (lat < minLat ? lat : minLat);
      maxLat = maxLat == null ? lat : (lat > maxLat ? lat : maxLat);
      minLng = minLng == null ? lng : (lng < minLng ? lng : minLng);
      maxLng = maxLng == null ? lng : (lng > maxLng ? lng : maxLng);
    }

    return LatLngBounds(
      northeast: LatLng(maxLat ?? 0, maxLng ?? 0),
      southwest: LatLng(minLat ?? 0, minLng ?? 0),
    );
  }
}