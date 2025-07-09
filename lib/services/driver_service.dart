import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:rastreamento_app_admin/models/driver.dart';

class DriverService {
  final String _apiHostPort = '192.168.0.3:3000';
  final String _apiDriversPath = '/entregadores';
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, String>> _getAuthHeaders() async {
    final User? user = _auth.currentUser;

    final String? token = await user?.getIdToken(true);

    if (token == null) {
      print(
          ">>> DEBUG DRIVER_SERVICE: Usuário não logado. Enviando sem token.");
      return {'Content-Type': 'application/json; charset=UTF-8'};
    }

    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<Driver>> getDrivers() async {
    final uri = Uri.http(_apiHostPort, _apiDriversPath);
    final headers = await _getAuthHeaders();
    print('>>> DEBUG DRIVER_SERVICE: Requisição GET para: $uri');

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> driversJson =
            jsonDecode(response.body) as List<dynamic>;
        return driversJson
            .map((json) => Driver.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        if (response.statusCode == 401) {
          throw Exception(
              'Sessão expirada. Por favor, faça o login novamente.');
        }
        final errorBody = jsonDecode(response.body);
        throw Exception(
          'Falha ao carregar entregadores: ${response.statusCode} - ${errorBody['message'] ?? 'Erro desconhecido'}',
        );
      }
    } catch (e) {
      throw Exception('Erro de conexão ao carregar entregadores: $e');
    }
  }

  Future<Driver> createDriver(Map<String, dynamic> driverData) async {
    final uri = Uri.http(_apiHostPort, _apiDriversPath);
    // Protegemos também a rota de criação.
    final headers = await _getAuthHeaders();
    print('>>> DEBUG DRIVER_SERVICE: Requisição POST para: $uri');

    try {
      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(driverData),
      );

      if (response.statusCode == 201) {
        return Driver.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>);
      } else {
        if (response.statusCode == 401) {
          throw Exception(
              'Sessão expirada. Por favor, faça o login novamente.');
        }
        final errorBody = jsonDecode(response.body);
        throw Exception(
          'Falha ao criar entregador: ${response.statusCode} - ${errorBody['message'] ?? 'Erro desconhecido'}',
        );
      }
    } catch (e) {
      throw Exception('Erro de conexão ao criar entregador: $e');
    }
  }
}
