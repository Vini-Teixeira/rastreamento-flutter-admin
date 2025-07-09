import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rastreamento_app_admin/models/loja.dart';

class LojasService {
  final String _apiHostPort = '192.168.0.3:3000';
  final String _apiLojasPath = '/lojas';
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, String>> _getAuthHeaders() async {
    final User? user = _auth.currentUser;
    if (user == null) {
      debugPrint(">>> DEBUG: _getAuthHeaders FALHOU. Motivo: Usuário é nulo.");
      throw Exception(
          'Usuário não autenticado. Impossível realizar a operação.');
    }

    final String? token = await user.getIdToken(true);

    if (token == null) {
      debugPrint(">>> DEBUG: _getAuthHeaders FALHOU. Motivo: Token é nulo.");
      throw Exception('Não foi possível obter o token de autenticação.');
    }

    // --- LINHA DE DEBUG ADICIONADA ---
    // Vamos imprimir os primeiros 30 caracteres do token para confirmar que ele existe.
    debugPrint(
        ">>> DEBUG: Token obtido com sucesso. Início: ${token.substring(0, 30)}...");
    // --- FIM DA LINHA DE DEBUG ---

    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }

  // Método para buscar a lista de todas as lojas
  Future<List<Loja>> getLojas() async {
    final uri = Uri.http(_apiHostPort, _apiLojasPath);
    debugPrint(">>> DEBUG: Tentando buscar lojas em: $uri");

    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        debugPrint(">>> DEBUG: Lojas carregadas com sucesso!");
        final List<dynamic> lojasJson =
            jsonDecode(response.body) as List<dynamic>;
        return lojasJson
            .map((json) => Loja.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        debugPrint(
            '>>> DEBUG: Falha ao carregar lojas. Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Falha ao carregar lojas: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('>>> DEBUG: Erro de conexão ao buscar lojas: $e');
      throw Exception('Erro de conexão ao buscar lojas: $e');
    }
  }

  // Método para criar uma nova loja
  Future<Loja> createLoja(Map<String, dynamic> lojaData) async {
    final uri = Uri.http(_apiHostPort, _apiLojasPath);
    // Também usamos os cabeçalhos autenticados aqui
    final headers = await _getAuthHeaders();

    try {
      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(lojaData),
      );
      if (response.statusCode == 201) {
        // 201 Created
        return Loja.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
            'Falha ao criar loja: ${response.statusCode} - ${errorBody['message'] ?? 'Erro desconhecido'}');
      }
    } catch (e) {
      throw Exception('Erro de conexão ao criar loja: $e');
    }
  }
}
