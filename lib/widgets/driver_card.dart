import 'package:flutter/material.dart';
import 'package:rastreamento_app_admin/models/driver.dart';

class DriverCard extends StatelessWidget {
  final Driver driver;

  const DriverCard({super.key, required this.driver});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor:
              driver.isActive ? Colors.green[600] : Colors.red[600],
          child: Icon(
            driver.isActive ? Icons.motorcycle : Icons.no_transfer,
            color: Colors.white,
          ),
        ),
        title: Text(
          driver.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Text(
          driver.phone,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white54,
          size: 16,
        ),
        onTap: () {
          print('Clicou no entregador: ${driver.name}');
        },
      ),
    );
  }
}
