import 'package:rastreamento_app_admin/models/coordinates.dart';

class Driver {
  final String id;
  final String name;
  final String phone;
  final bool isActive;
  final Coordinates? location;

  Driver({
    required this.id,
    required this.name,
    required this.phone,
    required this.isActive,
    this.location,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['_id'] as String,
      name: json['nome'] as String,
      phone: json['telefone'] as String,
      isActive: json['ativo'] as bool,
      location:
          json['localizacao'] != null
              ? Coordinates.fromJson(
                json['localizacao'] as Map<String, dynamic>,
              )
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'nome': name,
      'telefone': phone,
      'ativo': isActive,
      'localizacao': location?.toJson(),
    };
  }
}
