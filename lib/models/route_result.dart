import 'package:latlong2/latlong.dart';

enum TransportMode { car, walk, motor }

extension TransportModeX on TransportMode {
  String get label {
    switch (this) {
      case TransportMode.car:
        return 'Mobil';
      case TransportMode.walk:
        return 'Jalan';
      case TransportMode.motor:
        return 'Motor';
    }
  }

  /// Kecepatan rata-rata (km/jam) untuk estimasi waktu.
  double get speedKmh {
    switch (this) {
      case TransportMode.car:
        return 35;
      case TransportMode.walk:
        return 5;
      case TransportMode.motor:
        return 30;
    }
  }

  String get googleMode {
    switch (this) {
      case TransportMode.car:
        return 'driving';
      case TransportMode.walk:
        return 'walking';
      case TransportMode.motor:
        return 'two-wheeler';
    }
  }
}

class RouteResult {
  final List<LatLng> points;
  final double distanceMeters;

  /// true jika layanan rute gagal dan hanya garis lurus yang digunakan.
  final bool isFallback;

  const RouteResult({
    required this.points,
    required this.distanceMeters,
    this.isFallback = false,
  });

  int minutesFor(TransportMode mode) {
    final hours = (distanceMeters / 1000) / mode.speedKmh;
    final minutes = (hours * 60).round();
    return minutes < 1 ? 1 : minutes;
  }
}
