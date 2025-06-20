import 'package:flutter/material.dart';

class MyHousesTab extends StatelessWidget {
  const MyHousesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold( // Usamos un Scaffold para poder poner el FloatingActionButton
      body: const Center(
        child: Text(
          'Aquí irá la lista de "Mis Casas"',
          style: TextStyle(fontSize: 20),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navegar a la pantalla de crear nueva casa
        },
        label: const Text('Agregar Casa'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}
