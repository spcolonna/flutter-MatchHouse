import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final String userEmail;

  const HomeScreen({super.key, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Página de Inicio'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Text(
          '¡Bienvenido a MatchHouse, $userEmail!',
          style: const TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}
