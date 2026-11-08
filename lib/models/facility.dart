import 'package:latlong2/latlong.dart';

enum FacilityType { rumahSakit, puskesmas, klinik }

extension FacilityTypeX on FacilityType {
  String get label {
    switch (this) {
      case FacilityType.rumahSakit:
        return 'Rumah Sakit';
      case FacilityType.puskesmas:
        return 'Puskesmas';
      case FacilityType.klinik:
        return 'Klinik';
    }
  }

  String get shortLabel {
    switch (this) {
      case FacilityType.rumahSakit:
        return 'RS';
      case FacilityType.puskesmas:
        return 'Puskesmas';
      case FacilityType.klinik:
        return 'Klinik';
    }
  }
}

class Facility {
  final String id;
  final String name;
  final FacilityType type;
  final String address;
  final double lat;
  final double lng;
  final double rating;
  final int reviewCount;
  final String phone;
  final bool open24h;
  final int openHour;
  final int closeHour;
  final List<String> services;

  const Facility({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.lat,
    required this.lng,
    required this.rating,
    required this.reviewCount,
    required this.phone,
    this.open24h = false,
    this.openHour = 8,
    this.closeHour = 16,
    required this.services,
  });

  LatLng get latLng => LatLng(lat, lng);

  bool get isOpenNow {
    if (open24h) return true;
    final now = DateTime.now();
    final h = now.hour + now.minute / 60.0;
    return h >= openHour && h < closeHour;
  }

  String get hoursLabel {
    if (open24h) return 'Buka · 24 jam';
    String f(int h) => '${h.toString().padLeft(2, '0')}.00';
    return '${isOpenNow ? 'Buka' : 'Tutup'} · ${f(openHour)}–${f(closeHour)}';
  }

  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return name.toLowerCase().contains(q) ||
        address.toLowerCase().contains(q) ||
        type.label.toLowerCase().contains(q) ||
        services.any((s) => s.toLowerCase().contains(q));
  }
}
