import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../enums/UserRole.dart';

class PersonalInfoTab extends StatefulWidget {
  const PersonalInfoTab({super.key});

  @override
  State<PersonalInfoTab> createState() => _PersonalInfoTabState();
}

class _PersonalInfoTabState extends State<PersonalInfoTab> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _agencyNameController = TextEditingController();

  UserRole _selectedRole = UserRole.person;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _agencyNameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate() && !_isSaving) {
      setState(() { _isSaving = true; });

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Usuario no autenticado.')),
        );
        setState(() { _isSaving = false; });
        return;
      }

      final userData = {
        "id": user.uid,
        "mail": user.email,
        "name": _nameController.text,
        "phoneNumber": _phoneController.text,
        "role": _selectedRole == UserRole.agency ? "AGENCY" : "PERSON",
        "agencyName": _agencyNameController.text.isNotEmpty ? _agencyNameController.text : null,
      };

      try {
        final url = Uri.parse('http://localhost:8080/user');

        print('Enviando a Ktor: ${jsonEncode(userData)}');

        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            // En el futuro, aquí añadirías el token de autenticación:
            // 'Authorization': 'Bearer TU_ID_TOKEN_DE_FIREBASE'
          },
          body: jsonEncode(userData),
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200 || response.statusCode == 201) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Perfil guardado con éxito en el servidor')),
            );
          }
        } else {
          final errorData = jsonDecode(response.body);
          final errorMessage = errorData['error'] ?? 'Error desconocido del servidor.';
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error del servidor: $errorMessage')),
            );
          }
        }

      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error de conexión: No se pudo contactar al servidor. ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() { _isSaving = false; });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usamos un Scaffold aquí para poder usar el FloatingActionButton
    return Scaffold(
      body: Form(
        key: _formKey,
        // Usamos ListView para que el formulario sea scrollable si el teclado aparece
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre Completo *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) => (value == null || value.isEmpty) ? 'El nombre es obligatorio' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),

            const Text('Tipo de Usuario', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            DropdownButtonFormField<UserRole>(
              value: _selectedRole,
              onChanged: (UserRole? newValue) {
                setState(() {
                  _selectedRole = newValue!;
                });
              },
              items: UserRole.values.map((UserRole role) {
                return DropdownMenuItem<UserRole>(
                  value: role,
                  child: Text(role == UserRole.agency ? 'Inmobiliaria' : 'Persona'),
                );
              }).toList(),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),

            if (_selectedRole == UserRole.agency)
              TextFormField(
                controller: _agencyNameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la Inmobiliaria *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business_outlined),
                ),
                validator: (value) => (_selectedRole == UserRole.agency && (value == null || value.isEmpty)) ? 'Este campo es obligatorio para inmobiliarias' : null,
              ),
            const SizedBox(height: 80), // Espacio extra para que el botón flotante no tape el último campo
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveProfile,
        label: _isSaving ? const Text('Guardando...') : const Text('Guardar'),
        icon: _isSaving
            ? Container(
          width: 24,
          height: 24,
          padding: const EdgeInsets.all(2.0),
          child: const CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 3,
          ),
        )
            : const Icon(Icons.save),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}
