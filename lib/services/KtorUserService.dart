import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart' hide User;
import '../enums/UserRole.dart';
import '../models/UserModel.dart';
import 'IUserService.dart';

class KtorUserService implements IUserService {
  final String _baseUrl = 'http://localhost:8080';

  @override
  Future<UserModel> getUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    final url = Uri.parse('$_baseUrl/user/${user.uid}');

    // En el futuro, aquí enviarías el token de autenticación
    // final idToken = await user.getIdToken();
    // final response = await http.get(url, headers: {'Authorization': 'Bearer $idToken'});

    print(url);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return UserModel.fromMap(json.decode(response.body), user.uid);
    } else if (response.statusCode > 400 && response.statusCode < 500) {
      return UserModel(uid: user.uid, email: user.email!, role: UserRole.person);
    } else {
      throw Exception('Error al cargar el perfil del servidor');
    }
  }

  @override
  Future<http.Response> createUserProfile(UserModel user) async {
    final url = Uri.parse('$_baseUrl/user');
    final headers = {'Content-Type': 'application/json; charset=UTF-8'};
    final body = json.encode(user.toMap());

    final response = await http.post(
      url,
      headers: headers,
      // En el futuro, aquí añadirías el token de autenticación:
      // 'Authorization': 'Bearer TU_ID_TOKEN_DE_FIREBASE'
      body: body
    ).timeout(const Duration(seconds: 10));

    return response;
  }

  @override
  Future<void> addFavorite(String houseId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Usuario no autenticado para añadir favorito');

    final url = Uri.parse('$_baseUrl/user/${user.uid}/favorites/$houseId');
    final headers = {'Content-Type': 'application/json; charset=UTF-8'};

    final response = await http.post(url, headers: headers)
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Error al añadir a favoritos: ${response.body}');
    }
  }
}
