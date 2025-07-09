import 'package:flutter/material.dart';
import 'package:rastreamento_app_admin/models/delivery.dart';
import 'package:rastreamento_app_admin/services/delivery_service.dart';
import 'package:rastreamento_app_admin/widgets/delivery_card.dart';
import 'package:rastreamento_app_admin/screens/tracking_page.dart';

abstract class DeliveriesPageStateInterface {
  Future<void> fetchDeliveries({bool isInitialLoad});
}

class DeliveriesPage extends StatefulWidget {
  const DeliveriesPage({super.key});

  @override
  State<DeliveriesPage> createState() => DeliveriesPageState();
}

class DeliveriesPageState extends State<DeliveriesPage>
    implements DeliveriesPageStateInterface {
  final DeliveryService _deliveryService = DeliveryService();
  final List<Delivery> _deliveries = [];
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String _selectedStatusFilter = 'acontecendo';

  final Map<String, List<DeliveryStatus>> _statusFilters = {
    'acontecendo': [
      DeliveryStatus.pending,
      DeliveryStatus.accepted,
      DeliveryStatus.pickedUp,
      DeliveryStatus.onTheWay,
    ],
    'finalizadas': [DeliveryStatus.delivered],
    'canceladas': [DeliveryStatus.cancelled],
  };

  @override
  void initState() {
    super.initState();
    fetchDeliveries(isInitialLoad: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Future<void> fetchDeliveries({bool isInitialLoad = false}) async {
    if (_isLoading || (!_hasMore && !isInitialLoad)) return;

    setState(() {
      _isLoading = true;
      if (isInitialLoad) {
        _deliveries.clear();
        _currentPage = 1;
        _hasMore = true;
      }
    });

    try {
      final newDeliveries = await _deliveryService.getPaginatedDeliveries(
        statuses: _statusFilters[_selectedStatusFilter],
        page: _currentPage,
        limit: 8,
      );

      if (mounted) {
        setState(() {
          _deliveries.addAll(newDeliveries);
          _currentPage++;
          _hasMore = newDeliveries.length == 8;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar entregas: $e')),
        );
        setState(() => _hasMore = false);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      fetchDeliveries();
    }
  }

  void _changeStatusFilter(String newFilter) {
    if (_selectedStatusFilter == newFilter) return;
    setState(() => _selectedStatusFilter = newFilter);
    fetchDeliveries(isInitialLoad: true);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children:
                _statusFilters.keys.map((filterName) {
                  final isSelected = _selectedStatusFilter == filterName;
                  return ElevatedButton(
                    onPressed: () => _changeStatusFilter(filterName),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.surface,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      filterName.toUpperCase(),
                      style: TextStyle(
                        color:
                            isSelected
                                ? Colors.white
                                : Theme.of(context).colorScheme.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
        Expanded(
          child:
              _deliveries.isEmpty
                  ? _isLoading
                      ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                      : const Center(
                        child: Text(
                          'Nenhuma entrega encontrada.',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                  : ListView.builder(
                    controller: _scrollController,
                    itemCount: _deliveries.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _deliveries.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        );
                      }
                      final delivery = _deliveries[index];
                      return DeliveryCard(
                        delivery: delivery,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      TrackingPage(deliveryId: delivery.id),
                            ),
                          );
                        },
                      );
                    },
                  ),
        ),
      ],
    );
  }
}
