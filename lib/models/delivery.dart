import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rastreamento_app_admin/models/driver.dart';

enum DeliveryStatus {
  pending,
  accepted,
  pickedUp,
  onTheWay,
  delivered,
  cancelled;

  static DeliveryStatus fromString(String value) {
    final normalized = value.replaceAll('_', '').toLowerCase();

    return DeliveryStatus.values.firstWhere(
      (status) => status.name.toLowerCase() == normalized,
      orElse: () => DeliveryStatus.pending,
    );
  }
}

class Coordinates {
  final double lat;
  final double lng;
  final DateTime? timestamp;

  Coordinates({required this.lat, required this.lng, this.timestamp});

  factory Coordinates.fromJson(Map<String, dynamic> json) {
    return Coordinates(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      timestamp:
          json['timestamp'] != null
              ? DateTime.parse(json['timestamp'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'lat': lat, 'lng': lng, 'timestamp': timestamp?.toIso8601String()};
  }

  LatLng toLatLng() {
    return LatLng(lat, lng);
  }
}

class Location {
  final String address;
  final Coordinates coordinates;

  Location({required this.address, required this.coordinates});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      address: json['address'] as String,
      coordinates: Coordinates.fromJson(
        json['coordinates'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {'address': address, 'coordinates': coordinates.toJson()};
  }
}

class Delivery {
  final String id;
  final Location origin;
  final Location destination;
  final String itemDescription;
  final DeliveryStatus status;
  final Driver? driver;
  final List<Coordinates>? routeHistory;
  final Coordinates? driverCurrentLocation;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Delivery({
    required this.id,
    required this.origin,
    required this.destination,
    required this.itemDescription,
    required this.status,
    this.driver,
    this.routeHistory,
    this.driverCurrentLocation,
    this.createdAt,
    this.updatedAt,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    final String statusString = json['status'] as String;
    //
    final parsedStatus = DeliveryStatus.fromString(statusString);

    return Delivery(
      id: json['_id'] as String,
      origin: Location.fromJson(json['origin'] as Map<String, dynamic>),
      destination: Location.fromJson(
        json['destination'] as Map<String, dynamic>,
      ),
      itemDescription: json['itemDescription'] as String,
      status: parsedStatus,
      //
      driver:
          json['driverId'] != null
              ? (json['driverId'] is Map<String, dynamic>
                  ? Driver.fromJson(json['driverId'] as Map<String, dynamic>)
                  : null)
              : null,
      routeHistory:
          (json['routeHistory'] as List<dynamic>?)
              ?.map((e) => Coordinates.fromJson(e as Map<String, dynamic>))
              .toList(),
      driverCurrentLocation:
          json['driverCurrentLocation'] != null
              ? Coordinates.fromJson(
                json['driverCurrentLocation'] as Map<String, dynamic>,
              )
              : null,
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : null,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'origin': origin.toJson(),
      'destination': destination.toJson(),
      'itemDescription': itemDescription,
      'status': status.toString().split('.').last,
      if (driver != null) 'driverId': driver!.id,
    };
  }
}
