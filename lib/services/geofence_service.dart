import 'package:latlong2/latlong.dart';

import '../models/facility.dart';
import '../models/geofence_event.dart';

/// Logika geofencing (software geofence berbasis jarak haversine).
class GeofenceService {
  static const Distance _distance = Distance();

  /// Mengembalikan fasilitas yang BARU dimasuki pengguna.
  /// [inside] diperbarui langsung: fasilitas di dalam radius ditambahkan,
  /// fasilitas di luar radius dihapus, sehingga event tidak terulang
  /// selama pengguna tetap berada di dalam area.
  List<GeofenceEvent> detectEntered(
    LatLng position,
    List<Facility> facilities,
    double radius,
    Set<String> inside,
  ) {
    final events = <GeofenceEvent>[];
    for (final f in facilities) {
      final d = _distance.as(LengthUnit.Meter, position, f.latLng);
      if (d <= radius) {
        if (inside.add(f.id)) {
          events.add(GeofenceEvent(facility: f, distance: d, radius: radius));
        }
      } else {
        inside.remove(f.id);
      }
    }
    return events;
  }
}
