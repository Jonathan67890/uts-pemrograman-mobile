import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:sehat_bersama/data/facility_data.dart';
import 'package:sehat_bersama/services/geofence_service.dart';

void main() {
  final service = GeofenceService();
  final facility = FacilityData.all.first;

  test('event ENTER muncul sekali saat masuk radius', () {
    final inside = <String>{};

    // di luar radius -> tidak ada event
    var events = service.detectEntered(
      const LatLng(-6.5944, 106.7892),
      FacilityData.all,
      500,
      inside,
    );
    expect(events, isEmpty);

    // tepat di lokasi fasilitas -> ada event
    events = service.detectEntered(facility.latLng, FacilityData.all, 500, inside);
    expect(events.any((e) => e.facility.id == facility.id), isTrue);

    // tetap di dalam -> tidak terulang
    events = service.detectEntered(facility.latLng, FacilityData.all, 500, inside);
    expect(events, isEmpty);
  });

  test('event muncul lagi setelah keluar dan masuk kembali', () {
    final inside = <String>{};
    service.detectEntered(facility.latLng, FacilityData.all, 500, inside);
    service.detectEntered(const LatLng(-6.5, 106.5), FacilityData.all, 500, inside);
    final events =
    service.detectEntered(facility.latLng, FacilityData.all, 500, inside);
    expect(events.any((e) => e.facility.id == facility.id), isTrue);
  });
}
