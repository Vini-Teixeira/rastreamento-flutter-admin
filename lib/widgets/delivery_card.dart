import 'package:flutter/material.dart';
import 'package:rastreamento_app_admin/models/delivery.dart';

class DeliveryCard extends StatelessWidget {
  final Delivery delivery;
  final VoidCallback onTap;

  const DeliveryCard({super.key, required this.delivery, required this.onTap});

  Color _getStatusColor(DeliveryStatus status, BuildContext context) {
    switch (status) {
      case DeliveryStatus.pending:
      case DeliveryStatus.accepted:
      case DeliveryStatus.pickedUp:
      case DeliveryStatus.onTheWay:
        return Theme.of(context).colorScheme.secondary;
      case DeliveryStatus.delivered:
        return const Color(0xFF2E8B57);
      case DeliveryStatus.cancelled:
        return Theme.of(context).colorScheme.error;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 4.0,

      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          width: double.infinity,
          height: 90.0,
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Condutor: ${delivery.driver?.name ?? 'Não atribuído'}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Item: ${delivery.itemDescription}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'De: ${delivery.origin.address}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Para: ${delivery.destination.address}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _getStatusText(delivery.status),
                      textAlign: TextAlign.end,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _getStatusColor(delivery.status, context),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      delivery.status == DeliveryStatus.delivered
                          ? _formatDate(delivery.updatedAt)
                          : delivery.status == DeliveryStatus.onTheWay
                          ? 'A caminho'
                          : 'Pendente',
                      textAlign: TextAlign.end,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusText(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.pending:
        return 'Pendente';
      case DeliveryStatus.accepted:
        return 'Aceita';
      case DeliveryStatus.pickedUp:
        return 'Coletada';
      case DeliveryStatus.onTheWay:
        return 'A caminho';
      case DeliveryStatus.delivered:
        return 'Entregue';
      case DeliveryStatus.cancelled:
        return 'Cancelada';
    }
  }
}
