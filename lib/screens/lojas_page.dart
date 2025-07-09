import 'package:flutter/material.dart';
import 'package:rastreamento_app_admin/models/loja.dart';
import 'package:rastreamento_app_admin/screens/add_loja_page.dart'; // 1. Importar a nova tela
import 'package:rastreamento_app_admin/services/lojas_service.dart';
import 'package:rastreamento_app_admin/widgets/loja_card.dart';

class LojasPage extends StatefulWidget {
  const LojasPage({super.key});

  @override
  State<LojasPage> createState() => _LojasPageState();
}

class _LojasPageState extends State<LojasPage> {
  final LojasService _lojasService = LojasService();
  // 2. Trocamos o Future por uma lista para podermos atualizar a UI
  List<Loja> _lojas = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchLojas();
  }

  // 3. Centralizamos a lógica de busca em um método
  Future<void> _fetchLojas() async {
    try {
      final lojas = await _lojasService.getLojas();
      if (mounted) {
        setState(() {
          _lojas = lojas;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  // 4. Método para navegar e atualizar a lista ao retornar
  void _navigateToAddLojaPage() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => const AddLojaPage()),
    );

    // Se o resultado for 'true', uma loja foi salva com sucesso.
    if (result == true) {
      setState(() {
        _isLoading = true;
      });
      _fetchLojas(); // Recarrega a lista
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddLojaPage, // 5. O botão agora chama a navegação
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  // Widget auxiliar para construir o corpo da tela com base no estado
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text(
          'Erro ao carregar lojas:\n$_error',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
    if (_lojas.isEmpty) {
      return RefreshIndicator(
        // Permite "puxar para atualizar" mesmo se a lista estiver vazia
        onRefresh: _fetchLojas,
        child: const Center(
          child: Text(
            'Nenhuma loja cadastrada.\nClique no botão + para adicionar a primeira.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _fetchLojas,
      child: ListView.builder(
        itemCount: _lojas.length,
        itemBuilder: (context, index) {
          return LojaCard(loja: _lojas[index]);
        },
      ),
    );
  }
}
