import 'package:rastreamento_app_admin/models/coordinates.dart';

class Loja {
  final String id;
  final String nome;
  final String endereco;
  final Coordinates coordenadas;

  Loja({
    required this.id,
    required this.nome,
    required this.endereco,
    required this.coordenadas,
  });

  factory Loja.fromJson(Map<String, dynamic> json) {
    return Loja(
      id: json['_id'] as String,
      nome: json['nome'] as String,
      endereco: json['endereco'] as String,
      coordenadas:
          Coordinates.fromJson(json['coordenadas'] as Map<String, dynamic>),
    );
  }
}
