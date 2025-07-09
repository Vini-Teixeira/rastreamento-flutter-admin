import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rastreamento_app_admin/models/delivery.dart';
import 'package:rastreamento_app_admin/services/delivery_service.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:logging/logging.dart';

class TrackingPage extends StatefulWidget {
  final String deliveryId;

  const TrackingPage({super.key, required this.deliveryId});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  GoogleMapController? _mapController;
  final DeliveryService _deliveryService = DeliveryService();
  Future<Delivery>? _deliveryDetailsFuture;
  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};
  final PolylinePoints polylinePoints = PolylinePoints();

  IO.Socket? _socket;
  final String _wsBaseUrl = 'http://10.0.2.2:3000';
  final Logger _logger = Logger('TrackingPage');
  Delivery? _currentDeliveryData;

  @override
  void initState() {
    super.initState();
    _setupLogger();
    _deliveryDetailsFuture = _fetchDeliveryDetails();
    _connectWebSocket();
  }

  @override
  void dispose() {
    _disconnectWebSocket();
    _mapController?.dispose();
    super.dispose();
  }

  void _setupLogger() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      debugPrint('${record.level.name}: ${record.time}: ${record.message}');
    });
  }

  void _connectWebSocket() {
    try {
      _socket = IO.io(
          _wsBaseUrl,
          IO.OptionBuilder()
              .setTransports(['websocket'])
              .disableAutoConnect()
              .build());

      _socket!.connect();
      _logger.info('Tentando conectar ao Socket.IO: $_wsBaseUrl');

      _socket!.onConnect((_) {
        _logger.info('Conectado ao Socket.IO!');
        _socket!.emit('joinDeliveryRoom', widget.deliveryId);
      });

      _socket!.on('novaLocalizacao', (data) {
        _logger.info('Recebida novaLocalizacao: $data');
        if (data['deliveryId'] == widget.deliveryId &&
            mounted &&
            _currentDeliveryData != null) {
          final LatLng driverLocation = LatLng(
              (data['lat'] as num).toDouble(), (data['lng'] as num).toDouble());

          _updateDriverMarker(driverLocation);
          _drawDynamicPolyline(
              driverLocation, _currentDeliveryData!.destination.coordinates);
        }
      });

      _socket!.onConnectError(
          (err) => _logger.warning('Erro de conexão Socket.IO: $err'));
      _socket!.onError((err) => _logger.warning('Erro geral Socket.IO: $err'));
      _socket!.onDisconnect((_) => _logger.info('Desconectado do Socket.IO.'));
    } catch (e) {
      _logger.severe('Falha ao conectar ou iniciar Socket.IO: $e');
    }
  }

  void _disconnectWebSocket() {
    if (_socket?.connected == true) {
      _socket!.emit('leaveDeliveryRoom', widget.deliveryId);
      _socket!.disconnect();
      _socket!.dispose();
    }
  }

  void _updateDriverMarker(LatLng location) {
    setState(() {
      _markers.removeWhere((m) => m.markerId.value == 'driver_location');
      _markers.add(
        Marker(
          markerId: const MarkerId('driver_location'),
          position: location,
          infoWindow: const InfoWindow(title: 'Entregador'),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          anchor: const Offset(0.5, 0.5),
          flat: true,
        ),
      );
    });
    _mapController?.animateCamera(CameraUpdate.newLatLng(location));
  }

  void _drawDynamicPolyline(
      LatLng driverCoords, Coordinates destinationCoords) {
    final destinationLatLng =
        LatLng(destinationCoords.lat, destinationCoords.lng);

    setState(() {
      _polylines.clear();
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('dynamic_route'),
          points: [driverCoords, destinationLatLng],
          color: Colors.purpleAccent,
          width: 5,
        ),
      );
    });
  }

  Future<Delivery> _fetchDeliveryDetails() async {
    try {
      final delivery =
          await _deliveryService.getDeliveryDetails(widget.deliveryId);
      _currentDeliveryData = delivery;
      if (mounted) _updateMapWithInitialData(delivery);
      return delivery;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar detalhes: $e')),
        );
      }
      rethrow;
    }
  }

  void _updateMapWithInitialData(Delivery delivery) {
    if (!mounted) return;
    setState(() {
      _markers.clear();
      final originLatLng = LatLng(
          delivery.origin.coordinates.lat, delivery.origin.coordinates.lng);
      final destinationLatLng = LatLng(delivery.destination.coordinates.lat,
          delivery.destination.coordinates.lng);

      _markers.add(
        Marker(
          markerId: const MarkerId('origin'),
          position: originLatLng,
          infoWindow:
              InfoWindow(title: 'Origem', snippet: delivery.origin.address),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
      _markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: destinationLatLng,
          infoWindow: InfoWindow(
              title: 'Destino', snippet: delivery.destination.address),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );

      // --- AQUI ESTÁ A CORREÇÃO ---
      // Usamos .name para obter a string do enum e então .toUpperCase()
      if (delivery.status.name.toUpperCase() == 'ON_THE_WAY' &&
          delivery.driverCurrentLocation != null) {
        _updateDriverMarker(LatLng(delivery.driverCurrentLocation!.lat,
            delivery.driverCurrentLocation!.lng));
      }

      _setMapFitToWaypoints(_markers.map((m) => m.position).toList());
    });
  }

  Future<void> _setMapFitToWaypoints(List<LatLng> markerLocations) async {
    if (_mapController == null || markerLocations.length < 2) return;

    final bounds = LatLngBounds(
      southwest: LatLng(
        markerLocations.map((p) => p.latitude).reduce((a, b) => a < b ? a : b),
        markerLocations.map((p) => p.longitude).reduce((a, b) => a < b ? a : b),
      ),
      northeast: LatLng(
        markerLocations.map((p) => p.latitude).reduce((a, b) => a > b ? a : b),
        markerLocations.map((p) => p.longitude).reduce((a, b) => a > b ? a : b),
      ),
    );
    await _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 100),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Rastreando Entrega: ${widget.deliveryId.substring(0, 8)}...'),
        backgroundColor: Colors.grey[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<Delivery>(
        future: _deliveryDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.secondary));
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar detalhes da entrega: ${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          } else if (snapshot.hasData) {
            return GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: LatLng(snapshot.data!.origin.coordinates.lat,
                    snapshot.data!.origin.coordinates.lng),
                zoom: 12.0,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
                _setMapFitToWaypoints(_markers.map((m) => m.position).toList());
              },
              myLocationButtonEnabled: true,
              zoomControlsEnabled: false,
              polylines: _polylines,
              markers: _markers,
            );
          } else {
            return const Center(
                child: Text('Nenhum detalhe de entrega disponível.'));
          }
        },
      ),
    );
  }
}
