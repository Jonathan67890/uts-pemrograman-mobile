import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/facility_data.dart';
import '../models/facility.dart';
import '../models/geofence_event.dart';
import '../services/geofence_service.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';

class AppState extends ChangeNotifier {
  /// Titik pusat desa (dipakai jika GPS tidak tersedia).
  static const LatLng villageCenter = LatLng(-6.5944, 106.7892);

  final LocationService _location = LocationService();
  final GeofenceService _geofence = GeofenceService();
  final NotificationService _notifications = NotificationService();
  static const Distance _distance = Distance();

  final List<Facility> facilities = FacilityData.all;

  String userName = 'Andi Pratama';
  String userPhone = '0812 3456 7890';

  LatLng userPosition = villageCenter;
  bool gpsAvailable = false;
  bool usingSimulation = false;
  bool notificationsEnabled = true;
  double geofenceRadius = 500;
  Set<String> favorites = {};

  final Set<String> _inside = {};
  StreamSubscription<LatLng>? _sub;
  final StreamController<GeofenceEvent> _events =
      StreamController<GeofenceEvent>.broadcast();

  Stream<GeofenceEvent> get geofenceEvents => _events.stream;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    // Pengguna baru mendapat 4 favorit awal (sesuai contoh desain).
    favorites = (prefs.getStringList('favorites') ??
            <String>['rs-01', 'pkm-01', 'kl-01', 'rs-02'])
        .toSet();
    notificationsEnabled = prefs.getBool('notifications') ?? true;
    geofenceRadius = prefs.getDouble('radius') ?? 500;
    notifyListeners();

    await _notifications.init();
    await startTracking();
  }

  /// Mulai/ulang pelacakan GPS (keluar dari mode simulasi).
  Future<void> startTracking() async {
    usingSimulation = false;
    final ok = await _location.ensurePermission();
    gpsAvailable = ok;
    if (!ok) {
      notifyListeners();
      return;
    }
    final pos = await _location.current();
    if (pos != null) _applyGps(pos);
    await _sub?.cancel();
    _sub = _location.stream().listen((p) {
      if (!usingSimulation) _applyGps(p);
    });
    notifyListeners();
  }

  /// True bila posisi GPS jauh dari desa (mis. emulator di luar negeri).
  bool outsideVillage = false;

  void _applyGps(LatLng p) {
    final km = _distance.as(LengthUnit.Kilometer, p, villageCenter);
    if (km > 50) {
      outsideVillage = true;
      _updatePosition(villageCenter);
    } else {
      outsideVillage = false;
      _updatePosition(p);
    }
  }

  /// Simulasi lokasi untuk menguji geofencing.
  void simulateAt(LatLng p) {
    usingSimulation = true;
    _updatePosition(p);
  }

  void _updatePosition(LatLng p) {
    userPosition = p;
    final entered = _geofence.detectEntered(
      p,
      facilities,
      geofenceRadius,
      _inside,
    );
    for (final e in entered) {
      _events.add(e);
      if (notificationsEnabled) {
        _notifications.show(
          'Anda berada di area ${e.facility.name}',
          'Jarak Anda: ${e.distance.round()} meter',
        );
      }
    }
    notifyListeners();
  }

  double distanceTo(Facility f) =>
      _distance.as(LengthUnit.Meter, userPosition, f.latLng);

  /// Pencarian + filter, diurutkan dari yang terdekat.
  List<Facility> search({FacilityType? type, String query = ''}) {
    final list = facilities
        .where((f) => (type == null || f.type == type) && f.matches(query))
        .toList();
    list.sort((a, b) => distanceTo(a).compareTo(distanceTo(b)));
    return list;
  }

  List<Facility> get favoriteFacilities =>
      facilities.where((f) => favorites.contains(f.id)).toList();

  bool isFavorite(String id) => favorites.contains(id);

  Future<void> toggleFavorite(String id) async {
    if (!favorites.add(id)) favorites.remove(id);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', favorites.toList());
  }

  Future<void> setNotifications(bool value) async {
    notificationsEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', value);
  }

  Future<void> setRadius(double value) async {
    geofenceRadius = value;
    _inside.clear();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('radius', value);
  }

  @override
  void dispose() {
    _sub?.cancel();
    _events.close();
    super.dispose();
  }
}
