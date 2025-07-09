import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rastreamento_app_admin/models/delivery.dart';

class DeliveryService {
  final String _apiHostPort = '192.168.0.3:3000';
  final String _apiDeliveriesPath = '/entregas';
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, String>> _getAuthHeaders() async {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw Exception(
          'Usuário não autenticado. Impossível realizar a operação.');
    }

    final String? token = await user.getIdToken(true);

    if (token == null) {
      throw Exception('Não foi possível obter o token de autenticação.');
    }

    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }

  // --- MÉTODOS DA API, AGORA TODOS PROTEGIDOS ---

  // --- AQUI ESTÁ A CORREÇÃO PRINCIPAL ---
  // A assinatura do método agora aceita um Map<String, dynamic>
  Future<dynamic> createDelivery(Map<String, dynamic> deliveryData) async {
    final uri = Uri.http(_apiHostPort, _apiDeliveriesPath);
    final headers = await _getAuthHeaders();

    try {
      final response = await http.post(
        uri,
        headers: headers,
        // Usamos o mapa de dados diretamente para o corpo JSON
        body: jsonEncode(deliveryData),
      );
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          'Falha ao criar entrega: ${response.statusCode} - ${errorBody['message'] ?? 'Erro desconhecido'}',
        );
      }
    } catch (e) {
      throw Exception('Erro de conexão ao criar entrega: $e');
    }
  }

  Future<List<Delivery>> getPaginatedDeliveries({
    List<DeliveryStatus>? statuses,
    int page = 1,
    int limit = 8,
  }) async {
    final headers = await _getAuthHeaders();
    final Map<String, String> queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (statuses != null && statuses.isNotEmpty) {
      queryParams['status'] = statuses.map((s) {
        final String enumName = s.toString().split('.').last;
        switch (enumName) {
          case 'onTheWay':
            return 'on_the_way';
          case 'pickedUp':
            return 'picked_up';
          default:
            return enumName;
        }
      }).join(',');
    }

    final uri = Uri.http(_apiHostPort, _apiDeliveriesPath, queryParams);

    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> deliveriesJson =
            jsonResponse['deliveries'] as List<dynamic>;
        return deliveriesJson
            .map((json) => Delivery.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Falha ao carregar entregas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão ao carregar entregas: $e');
    }
  }

  Future<Delivery> getDeliveryDetails(String id) async {
    final headers = await _getAuthHeaders();
    final uri = Uri.http(_apiHostPort, '$_apiDeliveriesPath/$id');
    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        return Delivery.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>);
      } else {
        throw Exception(
            'Falha ao obter detalhes da entrega: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão ao obter detalhes da entrega: $e');
    }
  }

  Future<Delivery> updateDriverLocation(
      String deliveryId, double lat, double lng) async {
    final headers = await _getAuthHeaders();
    final uri = Uri.http(
        _apiHostPort, '$_apiDeliveriesPath/$deliveryId/driver-location');
    try {
      final response = await http.patch(
        uri,
        headers: headers,
        body: jsonEncode({'lat': lat, 'lng': lng}),
      );
      if (response.statusCode == 200) {
        return Delivery.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>);
      } else {
        throw Exception(
            'Falha ao atualizar localização do entregador: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão ao atualizar localização: $e');
    }
  }

  Future<String> getSnappedRoutePolyline(String deliveryId) async {
    final headers = await _getAuthHeaders();
    final uri =
        Uri.http(_apiHostPort, '$_apiDeliveriesPath/$deliveryId/directions');
    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        return jsonResponse['polyline'] as String;
      } else {
        throw Exception('Falha ao obter rota traçada: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão ao obter rota: $e');
    }
  }
}
