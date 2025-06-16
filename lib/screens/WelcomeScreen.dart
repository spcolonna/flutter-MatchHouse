import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../widgets/CustomInputField.dart';
import '../widgets/CustomPasswordField.dart';
import '../widgets/PrimaryButton.dart';
import '../widgets/SecondaryButton.dart';
import 'HomeScreen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _performLogin() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    // ¡Importante! La URL del servidor cambia según la plataforma
    // Para el emulador de Android: 'http://10.0.2.2:8080'
    // Para el simulador de iOS y la web: 'http://localhost:8080'
    const url = 'http://localhost:8080/login'; // Cambia a localhost si usas iOS

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'mail': _emailController.text,
          'password': _passwordController.text,
        }),
      );


      print('CÓDIGO DE ESTADO: ${response.statusCode}');
      print('CUERPO DE LA RESPUESTA: ${response.body}');


      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final userEmail = responseData['mail'];

        // Navegamos a la siguiente pantalla y evitamos que el usuario pueda volver atrás
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomeScreen(userEmail: userEmail),
          ),
        );
      } else {
        final errorData = jsonDecode(response.body);
        _showErrorDialog('Error de Login', errorData['error']);
      }
    } catch (e) {
      print('ERROR DETALLADO EN EL CATCH: $e');
      _showErrorDialog('Error de Conexión', 'No se pudo conectar al servidor. Asegúrate de que está funcionando.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            child: const Text('Ok'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Bienvenido a MatchHouse',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 48.0),
              CustomInputField(
                controller: _emailController,
                labelText: 'Correo Electrónico',
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 16.0),
              CustomPasswordField(
                controller: _passwordController,
              ),
              const SizedBox(height: 32.0),

              // Mostramos el spinner de carga o los botones
              if (_isLoading)
                const CircularProgressIndicator()
              else
                Column(
                  children: [
                    SecondaryButton(
                      text: 'Login',
                      onPressed: _performLogin, // Llamamos a nuestra función de login
                    ),
                    const SizedBox(height: 16.0),
                    PrimaryButton(
                      text: 'Registro',
                      onPressed: () {
                        // Aquí podrías llamar a un endpoint de registro
                      },
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
