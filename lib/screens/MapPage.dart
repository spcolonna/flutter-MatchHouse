import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  bool _isLoading = true;
  LatLng? _initialPosition;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _determineInitialPosition();
  }

  // Función modificada para usar la API del paquete 'location'
  Future<void> _determineInitialPosition() async {
    Location location = Location();

    try {
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          throw Exception('Servicio de ubicación deshabilitado.');
        }
      }

      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          throw Exception('Permiso de ubicación denegado.');
        }
      }

      final locationData = await location.getLocation();
      final lat = locationData.latitude;
      final lon = locationData.longitude;

      if (lat == null || lon == null) {
        throw Exception('No se pudo obtener la ubicación.');
      }

      setState(() {
        //_initialPosition = LatLng(lat, lon);
        _initialPosition = const LatLng(-34.9004, -56.1557);
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
        _initialPosition = const LatLng(-34.90, -56.16); // Ubicación por defecto
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // El resto de la UI del mapa no cambia
    return FlutterMap(
      options: MapOptions(
        initialCenter: _initialPosition!,
        initialZoom: 15.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.matchhouse_flutter',
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: _initialPosition!,
              child: const Icon(
                Icons.person_pin_circle,
                color: Colors.blue,
                size: 50.0,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
