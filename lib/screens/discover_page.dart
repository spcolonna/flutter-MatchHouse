import 'dart:async';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:latlong2/latlong.dart';

import '../models/House.dart';
import '../widgets/NearbyHouseCard.dart';
import '../widgets/DiscoveryCard.dart';
import '../services/IUserService.dart';
import '../services/KtorUserService.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  final IUserService _userService = KtorUserService();
  final CardSwiperController _swiperController = CardSwiperController();

  bool _isLoading = true;
  String? _errorMessage;
  List<House> _nearbyHouses = [];
  List<House> _discoveryHouses = [];

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    try {
      final locationData = await _getUserLocation();
      final lat = locationData.latitude;
      final lon = locationData.longitude;

      if (lat == null || lon == null) {
        throw Exception('No se pudo obtener coordenadas válidas.');
      }

      final userLocation = LatLng(lat, lon);

      final results = await Future.wait([
        _userService.getNearbyHouses(userLocation),
        _userService.getDiscoveryHouses(),
      ]);

      if (mounted) {
        setState(() {
          _nearbyHouses = results[0];
          _discoveryHouses = results[1];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('!!! ERROR CAPTURADO EN DiscoverPage: $e');
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<LocationData> _getUserLocation() async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) throw Exception('Servicio de ubicación deshabilitado.');
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        throw Exception('Permiso de ubicación denegado por el usuario.');
      }
    }

    return await location.getLocation().timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        print('DEBUG: Timeout de ubicación. Usando ubicación harcodeada para Rivera y Soca.');
        return LocationData.fromMap({
          "latitude": -34.9004,
          "longitude": -56.1557,
          "accuracy": 50.0,
          "altitude": 0.0,
          "speed": 0.0,
          "speed_accuracy": 0.0,
          "heading": 0.0,
          "time": DateTime.now().millisecondsSinceEpoch.toDouble(),
        });
      },
    );
  }

  /// Se ejecuta cada vez que el usuario desliza una tarjeta del carrusel.
  bool _onSwipe(int previousIndex, int? currentIndex, CardSwiperDirection direction) {
    final houseId = _discoveryHouses[previousIndex].id;

    if (direction == CardSwiperDirection.right) {
      print('LIKE a la casa: $houseId');
      // TODO: Llamar al servicio para añadir a favoritos: _userService.addFavorite(houseId);
    } else if (direction == CardSwiperDirection.left) {
      print('DISLIKE a la casa: $houseId');
      // TODO: Llamar a un servicio para registrar la interacción y no mostrarla de nuevo.
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MatchHouse', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Colors.black,
      ),
      body: _buildPageContent(),
    );
  }

  Widget _buildPageContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Ocurrió un error: $_errorMessage', textAlign: TextAlign.center),
          ));
    }

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // --- SECCIÓN 1: CASAS CERCANAS ---
        _buildSectionTitle('Cerca de Ti'),
        _buildNearbyHousesList(),
        const SizedBox(height: 24),

        // --- SECCIÓN 2: DESCUBRE TU PRÓXIMO HOGAR ---
        _buildSectionTitle('Descubre tu Próximo Hogar'),
        _buildDiscoverySwiper(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildNearbyHousesList() {
    if (_nearbyHouses.isEmpty) {
      return const ListTile(title: Text('No se encontraron casas cercanas.'));
    }
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _nearbyHouses.length,
        itemBuilder: (context, index) {
          final house = _nearbyHouses[index];
          return NearbyHouseCard(house: house);
        },
      ),
    );
  }

  Widget _buildDiscoverySwiper() {
    if (_discoveryHouses.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('¡Has visto todo por ahora! Vuelve más tarde.'),
        ),
      );
    }
    return SizedBox(
      height: 500,
      child: CardSwiper(
        controller: _swiperController,
        cardsCount: _discoveryHouses.length,
        onSwipe: _onSwipe,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
          final house = _discoveryHouses[index];
          return DiscoveryCard(house: house);
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
