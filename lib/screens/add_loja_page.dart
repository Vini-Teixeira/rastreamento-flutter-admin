import 'package:flutter/material.dart';
import 'package:rastreamento_app_admin/services/lojas_service.dart';
import 'package:rastreamento_app_admin/widgets/custom_text_field.dart';

class AddLojaPage extends StatefulWidget {
  const AddLojaPage({super.key});

  @override
  State<AddLojaPage> createState() => _AddLojaPageState();
}

class _AddLojaPageState extends State<AddLojaPage> {
  final _formKey = GlobalKey<FormState>();
  final _lojasService = LojasService();

  final _nomeController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();

  bool _isLoading = false;

  Future<void> _saveLoja() async {
    // Valida se os campos do formulário foram preenchidos corretamente
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final lojaData = {
        'nome': _nomeController.text,
        'endereco': _enderecoController.text,
        'coordenadas': {
          'lat': double.tryParse(_latController.text) ?? 0.0,
          'lng': double.tryParse(_lngController.text) ?? 0.0,
        }
      };

      try {
        await _lojasService.createLoja(lojaData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Loja cadastrada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          // Retorna para a tela anterior com um sinal de sucesso
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Erro ao salvar loja: ${e.toString().replaceFirst("Exception: ", "")}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _enderecoController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Nova Loja'),
        backgroundColor: Colors.grey[850],
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            CustomTextField(
              controller: _nomeController,
              hintText: 'Nome da Loja',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _enderecoController,
              hintText: 'Endereço Completo',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _latController,
                    hintText: 'Latitude',
                    keyboardType: TextInputType.numberWithOptions(
                        decimal: true, signed: true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    controller: _lngController,
                    hintText: 'Longitude',
                    keyboardType: TextInputType.numberWithOptions(
                        decimal: true, signed: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _saveLoja,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Salvar Loja',
                        style: TextStyle(color: Colors.black, fontSize: 16)),
                  ),
          ],
        ),
      ),
    );
  }
}
