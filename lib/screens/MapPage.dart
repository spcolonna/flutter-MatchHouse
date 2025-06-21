import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/House.dart';
import '../widgets/HouseInfoBottomSheet.dart';

class MapPage extends StatefulWidget {
  final List<House> favoriteHouses;
  final Function(String houseId) onFavoriteToggle;

  const MapPage({super.key, required this.favoriteHouses, required this.onFavoriteToggle});
  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  bool _isLoading = true;
  LatLng? _currentPosition;
  String? _errorMessage;
  List<House> _houses = [];
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _loadMapData();
  }

  Future<void> _loadMapData() async {
    Location location = Location();

    try {
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) { throw Exception('Servicio de ubicación deshabilitado.'); }
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

      final userPosition = LatLng(lat, lon);

      final url = Uri.parse('http://localhost:8080/house');
      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> housesJson = json.decode(response.body);
        setState(() {
          //_currentPosition = userPosition;
          _currentPosition = const LatLng(-34.9004, -56.1557);
          _houses = housesJson.map((json) => House.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Error al cargar las casas: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
        _currentPosition = const LatLng(-34.90, -56.16);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text("Error: $_errorMessage", textAlign: TextAlign.center),
        ),
      );
    }

    final List<Marker> markers = [];
    if (_currentPosition != null) {
      markers.add(
        Marker(
          point: _currentPosition!,
          width: 80,
          height: 80,
          child: const Icon(Icons.person_pin_circle, color: Colors.blue, size: 50),
        ),
      );
    }

    for (final house in _houses) {
      final bool isFavorite = widget.favoriteHouses.any((favHouse) => favHouse.id == house.id);

      markers.add(
        Marker(
          point: house.point,
          child: GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  // Le pasamos el estado de favorito y la función de toggle al popup
                  return HouseInfoBottomSheet(
                    house: house,
                    isFavorite: isFavorite,
                    onFavoriteToggle: () {
                      widget.onFavoriteToggle(house.id);
                      Navigator.pop(context); // Cierra el popup después de la acción
                    },
                  );
                },
              );
            },
            child: Icon(
              // El ícono ahora depende de si es favorito o no
              isFavorite ? Icons.favorite : Icons.location_on,
              color: isFavorite ? Colors.red : Colors.deepPurple,
              size: 40,
            ),
          ),
        ),
      );
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _currentPosition!,
        initialZoom: 14.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.matchhouse_flutter',
        ),
        MarkerLayer(markers: markers),
      ],
    );
  }
}
