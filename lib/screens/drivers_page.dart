import 'package:flutter/material.dart';
import 'package:rastreamento_app_admin/models/driver.dart';
import 'package:rastreamento_app_admin/services/driver_service.dart';
import 'package:rastreamento_app_admin/widgets/driver_card.dart';
import 'package:rastreamento_app_admin/screens/add_driver_page.dart';

class DriversPage extends StatefulWidget {
  const DriversPage({super.key});

  @override
  State<DriversPage> createState() => _DriversPageState();
}

class _DriversPageState extends State<DriversPage> {
  final DriverService _driverService = DriverService();
  List<Driver> _drivers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDrivers();
  }

  Future<void> _fetchDrivers() async {
    try {
      final drivers = await _driverService.getDrivers();
      if (mounted) {
        setState(() {
          _drivers = drivers;
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

  void _navigateToAddDriverPage() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => const AddDriverPage()),
    );
    if (result == true) {
      setState(() {
        _isLoading = true;
      });
      _fetchDrivers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddDriverPage,
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text(
          'Erro ao carregar entregadores:\n$_error',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
    if (_drivers.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum entregador encontrado.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _fetchDrivers,
      child: ListView.builder(
        itemCount: _drivers.length,
        itemBuilder: (context, index) {
          return DriverCard(driver: _drivers[index]);
        },
      ),
    );
  }
}
