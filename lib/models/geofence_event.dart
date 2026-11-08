import 'facility.dart';

/// Peristiwa ketika pengguna memasuki radius geofence sebuah fasilitas.
class GeofenceEvent {
  final Facility facility;
  final double distance;
  final double radius;

  const GeofenceEvent({
    required this.facility,
    required this.distance,
    required this.radius,
  });
}
