import 'package:flutter/material.dart';

import 'package:matchhouse_flutter/screens/tabs/PersonalInfoTab.dart';
import 'package:matchhouse_flutter/screens/tabs/SearchFiltersTab.dart';
import 'package:matchhouse_flutter/screens/tabs/MyHousesTab.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        // La propiedad 'bottom' del AppBar es el lugar perfecto para nuestra barra de pestañas
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.deepPurple,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.deepPurple,
          tabs: const [
            Tab(icon: Icon(Icons.person_outline), text: 'Personal'),
            Tab(icon: Icon(Icons.filter_alt_outlined), text: 'Filtros'),
            Tab(icon: Icon(Icons.other_houses_outlined), text: 'Mis Casas'),
          ],
        ),
      ),
      // El body del Scaffold será un TabBarView, que contiene las páginas de cada pestaña
      body: TabBarView(
        controller: _tabController,
        children: const [
          // Cada hijo aquí corresponde a una de las pestañas en el mismo orden
          PersonalInfoTab(),
          SearchFiltersTab(),
          MyHousesTab(),
        ],
      ),
    );
  }
}
