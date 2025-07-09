import 'package:flutter/material.dart';
import 'package:rastreamento_app_admin/services/driver_service.dart';
import 'package:rastreamento_app_admin/widgets/custom_text_field.dart';

class AddDriverPage extends StatefulWidget {
  const AddDriverPage({super.key});

  @override
  State<AddDriverPage> createState() => _AddDriverPageState();
}

class _AddDriverPageState extends State<AddDriverPage> {
  final _formKey = GlobalKey<FormState>();
  final _driverService = DriverService();

  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _ativo = true;
  bool _isLoading = false;

  Future<void> _saveDriver() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final driverData = {
        'nome': _nomeController.text,
        'telefone': _telefoneController.text,
        'ativo': _ativo,
        'password': _passwordController.text,
      };

      try {
        await _driverService.createDriver(driverData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Entregador salvo com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Erro ao salvar: ${e.toString().replaceFirst("Exception: ", "")}'),
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
    _telefoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Novo Entregador'),
        backgroundColor: Colors.grey[850],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              CustomTextField(
                controller: _nomeController,
                hintText: 'Nome Completo',
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _telefoneController,
                hintText: 'Telefone (com DDD)',
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _passwordController,
                hintText: 'Senha Provisória',
                obscureText: true,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title:
                    const Text('Ativo', style: TextStyle(color: Colors.white)),
                subtitle: Text(
                    _ativo
                        ? 'O entregador pode receber entregas'
                        : 'O entregador não receberá entregas',
                    style: const TextStyle(color: Colors.white70)),
                value: _ativo,
                onChanged: (bool value) {
                  setState(() {
                    _ativo = value;
                  });
                },
                activeColor: Colors.amber,
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _saveDriver,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Salvar Entregador',
                          style: TextStyle(color: Colors.black, fontSize: 16)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
