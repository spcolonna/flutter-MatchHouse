import 'package:flutter/material.dart';
import '../models/House.dart';
import '../models/UserModel.dart';
import '../services/IProfileService.dart';
import '../services/KtorUserService.dart';
import 'FavoritesPage.dart';
import 'ProfilePage.dart';
import 'discover_page.dart';
import 'MapPage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final IUserService _userService = KtorUserService();

  UserModel? _userProfile;
  bool _isLoadingProfile = true;
  List<House> _favoriteHouses = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final results = await Future.wait([
        _userService.getUserProfile(),
        _userService.getFavoriteHouses(),
      ]);

      if (mounted) {
        setState(() {
          _userProfile = results[0] as UserModel;
          _favoriteHouses = results[1] as List<House>;
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      print("Error cargando el perfil: $e");
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  void _toggleFavorite(String houseId) => _loadUserData();

  List<Widget> _buildPages() {
    return [
      const DiscoverPage(),
      MapPage(favoriteHouses: _favoriteHouses, onFavoriteToggle: _toggleFavorite),
      FavoritesPage(favoriteHouses: _favoriteHouses, onFavoriteToggle: _toggleFavorite),
      if (_userProfile != null)
        ProfilePage(user: _userProfile!, onProfileUpdated: _loadUserData)
      else if (_isLoadingProfile)
        const Center(child: CircularProgressIndicator())
      else
        const Center(child: Text("No se pudo cargar el perfil.")),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack( // IndexedStack mantiene el estado de las pestañas al cambiar
        index: _selectedIndex,
        children: _buildPages(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home), // Icono diferente cuando está activo
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            activeIcon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
      ),
    );
  }
}
