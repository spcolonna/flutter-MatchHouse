import 'package:flutter/material.dart';
import 'package:matchhouse_flutter/models/House.dart';
import 'package:matchhouse_flutter/screens/tabs/myHousesSubScreens/AddEditHousePage.dart';
import 'package:matchhouse_flutter/services/IUserService.dart';
import 'package:matchhouse_flutter/services/KtorUserService.dart';

class MyHousesTab extends StatefulWidget {
  const MyHousesTab({super.key});

  @override
  State<MyHousesTab> createState() => _MyHousesTabState();
}

class _MyHousesTabState extends State<MyHousesTab> {
  final IUserService _userService = KtorUserService();
  late Future<List<House>> _myHousesFuture;

  @override
  void initState() {
    super.initState();
    _myHousesFuture = _userService.getMyHouses();
  }

  void _refreshHouses() {
    setState(() {
      _myHousesFuture = _userService.getMyHouses();
    });
  }

  void _navigateAndRefresh(Widget page) async {
    final result = await Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    if (result == true) {
      _refreshHouses();
    }
  }

  void _deleteHouse(String houseId) async {
    // Popup de confirmación
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: const Text('¿Estás seguro de que quieres eliminar esta propiedad? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _userService.deleteHouse(houseId);
        _refreshHouses();
      } catch (e) {
        // Mostrar error
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<House>>(
        future: _myHousesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aún no has añadido ninguna casa.'));
          }

          final myHouses = snapshot.data!;
          return ListView.builder(
            itemCount: myHouses.length,
            itemBuilder: (context, index) {
              final house = myHouses[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.house_siding, size: 40, color: Colors.deepPurple),
                  title: Text(house.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('\$${house.price}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _navigateAndRefresh(AddEditHousePage(house: house))),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteHouse(house.id)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateAndRefresh(const AddEditHousePage()),
        label: const Text('Agregar Casa'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
