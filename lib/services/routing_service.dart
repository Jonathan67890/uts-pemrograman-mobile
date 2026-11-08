import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../models/route_result.dart';

/// Mengambil rute dari OSRM (public demo). Bila gagal, memakai garis lurus.
class RoutingService {
  static const Distance _distance = Distance();

  Future<RouteResult> fetchRoute(LatLng from, LatLng to) async {
    try {
      final uri = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '${from.longitude},${from.latitude};${to.longitude},${to.latitude}'
        '?overview=full&geometries=geojson',
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body) as Map<String, dynamic>;
        final routes = json['routes'] as List<dynamic>?;
        if (routes != null && routes.isNotEmpty) {
          final route = routes.first as Map<String, dynamic>;
          final coords = (route['geometry']['coordinates'] as List<dynamic>)
              .map((c) => LatLng(
                    (c[1] as num).toDouble(),
                    (c[0] as num).toDouble(),
                  ))
              .toList();
          return RouteResult(
            points: coords,
            distanceMeters: (route['distance'] as num).toDouble(),
          );
        }
      }
    } catch (_) {
      // jatuh ke garis lurus
    }
    return RouteResult(
      points: [from, to],
      distanceMeters: _distance.as(LengthUnit.Meter, from, to) * 1.3,
      isFallback: true,
    );
  }
}
