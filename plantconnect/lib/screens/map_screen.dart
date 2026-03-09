import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // ─── Map controller ────────────────────────────────────────────────────────
  GoogleMapController? _mapController;

  // ─── State ─────────────────────────────────────────────────────────────────
  bool _isLoading = true;
  bool _permissionDenied = false;
  Position? _currentPosition;
  final Set<Marker> _markers = {};
  BitmapDescriptor? _customIcon;

  // ─── Live tracking ─────────────────────────────────────────────────────────
  StreamSubscription<Position>? _positionStream;

  // ─── Default fallback camera (India center) ────────────────────────────────
  static const CameraPosition _defaultCamera = CameraPosition(
    target: LatLng(20.5937, 78.9629),
    zoom: 5,
  );

  @override
  void initState() {
    super.initState();
    _loadCustomIcon();
    _initLocation();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  // ─── Load custom plant pin icon ────────────────────────────────────────────
  Future<void> _loadCustomIcon() async {
    try {
      final icon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/icons/plant_pin.png',
      );
      if (mounted) setState(() => _customIcon = icon);
    } catch (e) {
      // Fall back to default marker if asset fails
      debugPrint('Custom icon load failed: $e');
    }
  }

  // ─── Permission + location init ───────────────────────────────────────────
  Future<void> _initLocation() async {
    setState(() {
      _isLoading = true;
      _permissionDenied = false;
    });

    // 1. Check if location service is enabled
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _isLoading = false;
        _permissionDenied = true;
      });
      return;
    }

    // 2. Check / request permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() {
        _isLoading = false;
        _permissionDenied = true;
      });
      return;
    }

    // 3. Fetch current position
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;
      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });

      _updateMarkers(position);
      _animateCameraTo(position);
      _startLiveTracking();
    } catch (e) {
      debugPrint('Location fetch error: $e');
      setState(() => _isLoading = false);
    }
  }

  // ─── Animate camera to position ───────────────────────────────────────────
  void _animateCameraTo(Position position) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 15.5,
        ),
      ),
    );
  }

  // ─── Build marker set ─────────────────────────────────────────────────────
  void _updateMarkers(Position position) {
    final latLng = LatLng(position.latitude, position.longitude);

    setState(() {
      _markers.clear();

      // Standard marker with InfoWindow
      _markers.add(
        Marker(
          markerId: const MarkerId('currentLocation'),
          position: latLng,
          infoWindow: const InfoWindow(
            title: 'You are here',
            snippet: 'Your current GPS location',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
      );

      // Custom plant pin marker (slightly offset so both are visible)
      if (_customIcon != null) {
        _markers.add(
          Marker(
            markerId: const MarkerId('customPin'),
            position: LatLng(
              position.latitude + 0.0001,
              position.longitude + 0.0001,
            ),
            infoWindow: const InfoWindow(
              title: '🌿 PlantConnect',
              snippet: 'Custom plant pin marker',
            ),
            icon: _customIcon!,
          ),
        );
      }
    });
  }

  // ─── Live GPS tracking stream ─────────────────────────────────────────────
  void _startLiveTracking() {
    _positionStream?.cancel();
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // Update every 5 metres moved
      ),
    ).listen((Position position) {
      if (!mounted) return;
      setState(() => _currentPosition = position);
      _updateMarkers(position);
    });
  }

  // ─── Permission denied UI ─────────────────────────────────────────────────
  Widget _buildPermissionDeniedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            const Text(
              'Location Access Required',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'PlantConnect needs location access to show your position on the map and find plants near you.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _initLocation,
              icon: const Icon(Icons.location_on),
              label: const Text('Grant Location Access'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Geolocator.openAppSettings(),
              child: const Text(
                'Open App Settings',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Loading UI ───────────────────────────────────────────────────────────
  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.green),
          const SizedBox(height: 20),
          Text(
            'Fetching your location...',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ─── Location info bottom bar ─────────────────────────────────────────────
  Widget _buildLocationInfoBar() {
    if (_currentPosition == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.green[700],
      child: Row(
        children: [
          const Icon(Icons.my_location, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Lat: ${_currentPosition!.latitude.toStringAsFixed(5)}'
              '  |  Lng: ${_currentPosition!.longitude.toStringAsFixed(5)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const Icon(Icons.circle, color: Colors.greenAccent, size: 8),
          const SizedBox(width: 4),
          const Text(
            'LIVE',
            style: TextStyle(
              color: Colors.greenAccent,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map & Location'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          // Re-center on user location
          if (_currentPosition != null)
            IconButton(
              icon: const Icon(Icons.my_location),
              tooltip: 'Centre on my location',
              onPressed: () => _animateCameraTo(_currentPosition!),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? _buildLoadingView()
                : _permissionDenied
                    ? _buildPermissionDeniedView()
                    : GoogleMap(
                        onMapCreated: (controller) {
                          _mapController = controller;
                          // Animate to user location once map is ready
                          if (_currentPosition != null) {
                            _animateCameraTo(_currentPosition!);
                          }
                        },
                        initialCameraPosition: _defaultCamera,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        zoomControlsEnabled: true,
                        mapToolbarEnabled: true,
                        markers: _markers,
                      ),
          ),
          _buildLocationInfoBar(),
        ],
      ),
    );
  }
}
