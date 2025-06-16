import 'package:flutter/material.dart';
import 'package:matchhouse_flutter/screens/WelcomeScreen.dart';

// Punto de entrada de la aplicación.
void main() {
  runApp(const MyApp());
}

// Widget raíz de la aplicación.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Bienvenida',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const WelcomeScreen(),
    );
  }
}
