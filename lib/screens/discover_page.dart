import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

import '../models/House.dart';
import '../widgets/NearbyHouseCard.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  bool _isLoading = true;
  String? _errorMessage;
  List<House> _nearbyHouses = [];

  @override
  void initState() {
    super.initState();
    _fetchNearbyHouses();
  }

  Future<void> _fetchNearbyHouses() async {
    try {
      Location location = Location();

      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) { throw Exception('Servicio de ubicación deshabilitado.'); }
      }

      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          throw Exception('Permiso de ubicación denegado por el usuario.');
        }
      }

      LocationData locationData = await location.getLocation().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          print('DEBUG: Timeout de ubicación. Usando ubicación harcodeada para Rivera y Soca.');
          final Map<String, double> hardcodedLocation = {
            "latitude": -34.9004,
            "longitude": -56.1557,
            "accuracy": 0.0,
            "altitude": 0.0,
            "speed": 0.0,
            "speed_accuracy": 0.0,
            "heading": 0.0,
            "time": DateTime.now().millisecondsSinceEpoch.toDouble(),
          };

          return LocationData.fromMap(hardcodedLocation);
        },
      );
      final lat = locationData.latitude;
      final lon = locationData.longitude;

      if (lat == null || lon == null) {
        throw Exception('No se pudo obtener las coordenadas.');
      }

      final baseUrl = 'http://localhost:8080';
      final endpoint = '/house/nearby';
      final queryParameters = {
        'lat': lat.toString(),
        'lon': lon.toString(),
      };

      final uri = Uri.parse(baseUrl + endpoint).replace(queryParameters: queryParameters);
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> housesJson = json.decode(response.body);
        setState(() {
          _nearbyHouses = housesJson.map((json) => House.fromJson(json)).toList();
          _isLoading = false;
          _errorMessage = null;
        });
      } else {
        throw Exception('El servidor respondió con un error: ${response.statusCode}');
      }
    } catch (e) {
      print('!!! ERROR CAPTURADO: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Widget para mostrar el contenido principal (la lista horizontal)
  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(child: Text('Error: $_errorMessage'));
    }
    if (_nearbyHouses.isEmpty) {
      return const Center(child: Text('No se encontraron casas cercanas.'));
    }

    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16),
        itemCount: _nearbyHouses.length,
        itemBuilder: (context, index) {
          final house = _nearbyHouses[index];
          return NearbyHouseCard(house: house);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MatchHouse', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Cerca de Ti',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          _buildContent(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Descubre tu Próximo Hogar',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          // Aquí iría el widget de tarjetas deslizables
          // Puedes usar un paquete como 'flutter_card_swiper' para esto
          Container(
            height: 400,
            alignment: Alignment.center,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(16)
            ),
            child: const Text(
              'Aquí va el carrusel de tarjetas\npara hacer match',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
