import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../models/facility.dart';
import '../models/route_result.dart';
import '../providers/app_state.dart';
import '../services/routing_service.dart';

class RouteScreen extends StatefulWidget {
  final Facility facility;
  const RouteScreen({super.key, required this.facility});

  @override
  State<RouteScreen> createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  final MapController _mapController = MapController();
  final RoutingService _routing = RoutingService();

  RouteResult? _route;
  TransportMode _mode = TransportMode.car;
  bool _loading = true;
  late LatLng _from;

  @override
  void initState() {
    super.initState();
    _from = context.read<AppState>().userPosition;
    _load();
  }

  Future<void> _load() async {
    final result = await _routing.fetchRoute(_from, widget.facility.latLng);
    if (!mounted) return;
    setState(() {
      _route = result;
      _loading = false;
    });
    final bounds = LatLngBounds.fromPoints(result.points);
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.fromLTRB(50, 120, 50, 260),
        maxZoom: 17,
      ),
    );
  }

  Future<void> _startNavigation() async {
    final f = widget.facility;
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&origin=${_from.latitude},${_from.longitude}'
      '&destination=${f.lat},${f.lng}'
      '&travelmode=${_mode == TransportMode.walk ? 'walking' : 'driving'}',
    );
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka aplikasi peta')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.facility;
    final route = _route;

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(
                (_from.latitude + f.lat) / 2,
                (_from.longitude + f.lng) / 2,
              ),
              initialZoom: 14.5,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.sehat_bersama',
              ),
              if (route != null)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: route.points,
                      strokeWidth: 5,
                      color: AppColors.primary,
                      pattern: route.isFallback
                          ? StrokePattern.dashed(segments: const [10, 8])
                          : const StrokePattern.solid(),
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _from,
                    width: 24,
                    height: 24,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                    ),
                  ),
                  if (route != null && route.points.length > 1)
                    Marker(
                      point: route.points[route.points.length ~/ 2],
                      width: 84,
                      height: 46,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Text(
                          '${route.minutesFor(_mode)} menit\n${formatDistance(route.distanceMeters)}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                          ),
                        ),
                      ),
                    ),
                  Marker(
                    point: f.latLng,
                    width: 140,
                    height: 78,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on,
                            color: AppColors.red,
                            size: 42,
                            shadows: const [
                              Shadow(color: Colors.black38, blurRadius: 6)
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              f.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 9.5, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      Expanded(
                        child: Text(
                          'Rute ke ${f.name}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 14,
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_loading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: CircularProgressIndicator(),
                      )
                    else if (route != null) ...[
                      Row(
                        children: [
                          for (final m in TransportMode.values) ...[
                            Expanded(
                              child: _ModeTile(
                                mode: m,
                                minutes: route.minutesFor(m),
                                distance: formatDistance(route.distanceMeters),
                                selected: _mode == m,
                                onTap: () => setState(() => _mode = m),
                              ),
                            ),
                            if (m != TransportMode.values.last)
                              const SizedBox(width: 8),
                          ],
                        ],
                      ),
                      if (route.isFallback)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            'Layanan rute tidak tersedia, ditampilkan garis lurus perkiraan.',
                            style: TextStyle(
                                fontSize: 11.5, color: AppColors.textMuted),
                          ),
                        ),
                    ],
                    const SizedBox(height: 14),
                    ElevatedButton(
                      onPressed: _loading ? null : _startNavigation,
                      child: const Text('Mulai Navigasi'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeTile extends StatelessWidget {
  final TransportMode mode;
  final int minutes;
  final String distance;
  final bool selected;
  final VoidCallback onTap;

  const _ModeTile({
    required this.mode,
    required this.minutes,
    required this.distance,
    required this.selected,
    required this.onTap,
  });

  IconData get _icon {
    switch (mode) {
      case TransportMode.car:
        return Icons.directions_car;
      case TransportMode.walk:
        return Icons.directions_walk;
      case TransportMode.motor:
        return Icons.two_wheeler;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : AppColors.background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_icon,
                color: selected ? Colors.white : AppColors.textMuted),
          ),
          const SizedBox(height: 6),
          Text('$minutes mnt',
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          Text(distance,
              style:
                  const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
