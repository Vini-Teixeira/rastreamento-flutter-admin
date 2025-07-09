import 'package:flutter/material.dart';
import 'package:rastreamento_app_admin/models/loja.dart';

class LojaCard extends StatelessWidget {
  final Loja loja;

  const LojaCard({super.key, required this.loja});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: const CircleAvatar(
          backgroundColor: Colors.amber,
          child: Icon(
            Icons.store,
            color: Colors.black,
          ),
        ),
        title: Text(
          loja.nome,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Text(
          loja.endereco,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.arrow_forward_ios,
            color: Colors.white54, size: 16),
        onTap: () {
          // Ação futura: navegar para a tela de detalhes da loja e seus relatórios
          print('Clicou na loja: ${loja.nome}');
        },
      ),
    );
  }
}
