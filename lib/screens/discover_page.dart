import 'dart:async';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Modelos, Servicios y Widgets necesarios
import '../models/House.dart';
import '../services/interfaces/IHouseService.dart';
import '../services/KtorHouseService.dart';
import '../widgets/NearbyHouseCard.dart';
import '../widgets/DiscoveryCard.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  // --- ESTADO DE LA PÁGINA ---
  final IHouseService _houseService = KtorHouseService();
  final CardSwiperController _swiperController = CardSwiperController();

  bool _isLoading = true;
  String? _errorMessage;
  // Lista para el carrusel horizontal "Cerca de Ti"
  List<House> _nearbyHouses = [];
  // Lista para el carrusel de tarjetas tipo Tinder
  List<House> _discoveryHouses = [];

  // --- CICLO DE VIDA DEL WIDGET ---

  @override
  void initState() {
    super.initState();
    // Al iniciar la página, cargamos todos los datos necesarios.
    _loadAllData();
  }

  @override
  void dispose() {
    // Liberamos el controlador del swiper para evitar fugas de memoria.
    _swiperController.dispose();
    super.dispose();
  }

  // --- LÓGICA DE DATOS ---

  /// Carga los datos de las casas cercanas y de la cola de descubrimiento en paralelo.
  Future<void> _loadAllData() async {
    try {
      // 1. OBTENEMOS LA UBICACIÓN DEL USUARIO
      final locationData = await _getUserLocation();
      final lat = locationData.latitude;
      final lon = locationData.longitude;

      if (lat == null || lon == null) {
        throw Exception('No se pudo obtener coordenadas válidas.');
      }

      final userLocation = LatLng(lat, lon);

      // 2. LLAMAMOS A LOS MÉTODOS DEL SERVICIO EN PARALELO
      // Usamos Future.wait para ejecutar ambas llamadas a Ktor al mismo tiempo.
      final results = await Future.wait([
        _houseService.getNearbyHouses(userLocation),
        _houseService.getDiscoveryHouses(),
      ]);

      // 3. ACTUALIZAMOS EL ESTADO CON LOS RESULTADOS
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

  /// Obtiene la ubicación del usuario, con lógica de permisos y timeout.
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

    // Usamos tu lógica de timeout con la ubicación harcodeada como fallback
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
      // TODO: Llamar al servicio para añadir a favoritos.
    } else if (direction == CardSwiperDirection.left) {
      print('DISLIKE a la casa: $houseId');
      // TODO: Llamar a un servicio para registrar la interacción y no mostrarla de nuevo.
    }
    return true; // Permite que el swipe se complete.
  }

  // --- CONSTRUCCIÓN DE LA INTERFAZ DE USUARIO (UI) ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nido', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Colors.black,
      ),
      body: _buildPageContent(),
    );
  }

  /// Construye el cuerpo principal de la página, manejando los estados de carga y error.
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

    // Usamos un ListView para poder tener ambas secciones con scroll vertical.
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

  /// Widget de ayuda para construir la lista horizontal de casas cercanas.
  Widget _buildNearbyHousesList() {
    if (_nearbyHouses.isEmpty) {
      return const ListTile(
        leading: Icon(Icons.info_outline, color: Colors.grey),
        title: Text('No se encontraron casas cercanas en este momento.'),
      );
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

  /// Widget de ayuda para construir el carrusel de descubrimiento.
  Widget _buildDiscoverySwiper() {
    if (_discoveryHouses.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('¡Has visto todo por ahora! Vuelve más tarde.', textAlign: TextAlign.center),
        ),
      );
    }
    return SizedBox(
      height: 500, // Altura fija para el carrusel
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

  /// Widget de ayuda para los títulos de sección.
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
