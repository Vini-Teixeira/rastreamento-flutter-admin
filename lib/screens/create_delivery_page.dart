import 'package:flutter/material.dart';
import 'package:rastreamento_app_admin/models/loja.dart';
import 'package:rastreamento_app_admin/services/delivery_service.dart';
import 'package:rastreamento_app_admin/services/lojas_service.dart';
import 'package:rastreamento_app_admin/widgets/custom_text_field.dart';

class CreateDeliveryPage extends StatefulWidget {
  const CreateDeliveryPage({super.key});

  @override
  State<CreateDeliveryPage> createState() => _CreateDeliveryPageState();
}

class _CreateDeliveryPageState extends State<CreateDeliveryPage> {
  final _formKey = GlobalKey<FormState>();
  final _lojasService = LojasService();
  final _deliveryService = DeliveryService();

  // Controladores para os campos de texto
  final _itemController = TextEditingController();
  final _destinationController = TextEditingController();

  // Variáveis de estado
  late Future<List<Loja>> _lojasFuture;
  Loja? _selectedLoja; // Para guardar a loja selecionada no dropdown
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Busca a lista de lojas assim que a tela é iniciada
    _lojasFuture = _lojasService.getLojas();
  }

  @override
  void dispose() {
    _itemController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    // Valida o formulário
    if (_formKey.currentState!.validate()) {
      if (_selectedLoja == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Por favor, selecione uma loja de origem.'),
              backgroundColor: Colors.red),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      // Monta o objeto de dados para enviar à API
      final deliveryData = {
        'itemDescription': _itemController.text,
        'origin': {
          'address': _selectedLoja!.endereco,
          'coordinates': {
            'lat': _selectedLoja!.coordenadas.lat,
            'lng': _selectedLoja!.coordenadas.lng,
          }
        },
        'destination': {
          // O backend fará o geocoding deste endereço
          'address': _destinationController.text,
        }
      };

      try {
        await _deliveryService.createDelivery(deliveryData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Nova entrega criada com sucesso!'),
                backgroundColor: Colors.green),
          );
          // Retorna para a tela anterior com um sinal de sucesso
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Erro: ${e.toString()}'),
                backgroundColor: Colors.red),
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Criar Nova Entrega'),
        backgroundColor: Colors.grey[850],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Dropdown para selecionar a loja de origem
            FutureBuilder<List<Loja>>(
              future: _lojasFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return const Text('Não foi possível carregar as lojas.',
                      style: TextStyle(color: Colors.red));
                }

                final lojas = snapshot.data!;
                return DropdownButtonFormField<Loja>(
                  value: _selectedLoja,
                  hint: const Text('Selecione a Loja de Origem',
                      style: TextStyle(color: Colors.white70)),
                  dropdownColor: Colors.grey[800],
                  style: const TextStyle(color: Colors.white),
                  items: lojas.map((loja) {
                    return DropdownMenuItem<Loja>(
                      value: loja,
                      child: Text(loja.nome),
                    );
                  }).toList(),
                  onChanged: (Loja? newValue) {
                    setState(() {
                      _selectedLoja = newValue;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Campo obrigatório' : null,
                );
              },
            ),
            const SizedBox(height: 16),
            // Campo para descrição do item
            CustomTextField(
              controller: _itemController,
              hintText: 'Descrição do Item (ex: Sapato, Documento)',
            ),
            const SizedBox(height: 16),
            // Campo para o endereço de destino
            CustomTextField(
              controller: _destinationController,
              hintText: 'Endereço Completo de Destino',
            ),
            const SizedBox(height: 32),
            // Botão de submissão
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Criar e Atribuir Entrega',
                        style: TextStyle(color: Colors.black, fontSize: 16)),
                  ),
          ],
        ),
      ),
    );
  }
}
