import 'package:flutter/material.dart';
import 'package:matchhouse_flutter/screens/discover_page.dart';

class HomeScreen extends StatefulWidget {
  final String userEmail;

  const HomeScreen({super.key, required this.userEmail});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Variable para guardar el índice de la pestaña seleccionada
  int _selectedIndex = 0;

  // Lista de las páginas que corresponden a cada pestaña
  static final List<Widget> _pages = <Widget>[
    const DiscoverPage(),
    // Placeholders (contenidos de ejemplo) para las otras pestañas
    const Center(child: Text('Aquí irá el Mapa', style: TextStyle(fontSize: 24))),
    const Center(child: Text('Aquí irán los Favoritos', style: TextStyle(fontSize: 24))),
    const Center(child: Text('Aquí irá el Perfil', style: TextStyle(fontSize: 24))),
  ];

  // Función que se llama cuando se toca una pestaña
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // El body ahora muestra la página que corresponda al índice seleccionado
      body: _pages.elementAt(_selectedIndex),

      // Aquí definimos la barra de navegación inferior
      bottomNavigationBar: BottomNavigationBar(
        // Lista de los botones de la barra
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
