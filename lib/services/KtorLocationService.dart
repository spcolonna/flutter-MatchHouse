import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

import '../models/Country.dart';
import '../models/Department.dart';
import '../models/Neighborhood.dart';
import 'interfaces/ILocationService.dart';

class KtorLocationService implements ILocationService {
  String get _baseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    if (Platform.isAndroid) return 'http://10.0.2.2:8080';
    return 'http://localhost:8080';
  }

  @override
  Future<List<Country>> getAvailableCountries() async {
    final url = Uri.parse('$_baseUrl/locations/countries');
    print('Buscando países desde Ktor: $url');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Country.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar los países: ${response.statusCode}');
      }
    } catch (e) {
      print('Error de conexión al obtener países: $e');
      throw Exception('No se pudo conectar al servidor.');
    }
  }

  @override
  Future<List<Department>> getDepartments(String countryName) async {
    final url = Uri.parse('$_baseUrl/locations/countries/$countryName/departments');
    print('Buscando departamentos desde Ktor: $url');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Department.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar los departamentos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error de conexión al obtener departamentos: $e');
      throw Exception('No se pudo conectar al servidor.');
    }
  }

  @override
  Future<List<Neighborhood>> getNeighborhoods(String departmentName) async {
    final url = Uri.parse('$_baseUrl/locations/departments/$departmentName/neighborhoods');
    print('Buscando barrios desde Ktor: $url');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Neighborhood.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar los barrios: ${response.statusCode}');
      }
    } catch (e) {
      print('Error de conexión al obtener barrios: $e');
      throw Exception('No se pudo conectar al servidor.');
    }
  }
}
