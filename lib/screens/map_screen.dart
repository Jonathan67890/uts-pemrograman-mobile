import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../models/facility.dart';
import '../providers/app_state.dart';
import 'detail_screen.dart';
import 'list_screen.dart';
import 'route_screen.dart';

/// Peta Lokasi: pin fasilitas, posisi pengguna, lingkaran geofence (opsional).
/// Tekan lama pada peta untuk memindahkan posisi (simulasi geofencing).
class MapScreen extends StatefulWidget {
  final Facility? focus;
  const MapScreen({super.key, this.focus});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  FacilityType? _type;
  String _query = '';
  Facility? _selected;
  bool _showGeofence = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.focus;
  }

  void _select(Facility f) {
    setState(() => _selected = f);
    _mapController.move(f.latLng, 16);
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final items = app.search(type: _type, query: _query);
    final center = widget.focus?.latLng ?? app.userPosition;
    final bottomOffset = _selected != null ? 196.0 : 24.0;

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 15,
              minZoom: 5,
              maxZoom: 18,
              onTap: (_, __) => setState(() => _selected = null),
              onLongPress: (_, point) {
                app.simulateAt(point);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Posisi disimulasikan di titik ini'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.sehat_bersama',
              ),
              if (_showGeofence)
                CircleLayer(
                  circles: [
                    for (final f in items)
                      CircleMarker(
                        point: f.latLng,
                        radius: app.geofenceRadius,
                        useRadiusInMeter: true,
                        color: typeColor(f.type).withValues(alpha: 0.10),
                        borderColor: typeColor(f.type).withValues(alpha: 0.5),
                        borderStrokeWidth: 1.5,
                      ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  for (final f in items)
                    Marker(
                      point: f.latLng,
                      width: 140,
                      height: 78,
                      child: GestureDetector(
                        onTap: () => _select(f),
                        child: _PinMarker(
                          facility: f,
                          selected: _selected?.id == f.id,
                        ),
                      ),
                    ),
                  Marker(
                    point: app.userPosition,
                    width: 70,
                    height: 70,
                    child: const _UserMarker(),
                  ),
                ],
              ),
            ],
          ),

          // Header: judul, pencarian, filter
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          if (widget.focus != null)
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.arrow_back),
                            )
                          else
                            const SizedBox(width: 8),
                          const Expanded(
                            child: Text('Peta Lokasi',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        height: 42,
                        child: TextField(
                          onChanged: (v) => setState(() => _query = v),
                          style: const TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Cari lokasi...',
                            hintStyle: const TextStyle(
                                color: AppColors.textMuted, fontSize: 13),
                            prefixIcon: const Icon(Icons.search, size: 20),
                            filled: true,
                            fillColor: AppColors.background,
                            contentPadding: EdgeInsets.zero,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: AppColors.border),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      FacilityFilterChips(
                        selected: _type,
                        rsLabel: 'RS',
                        onChanged: (t) => setState(() => _type = t),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Tombol di kanan: lapisan geofence + lokasi saya
          Positioned(
            right: 16,
            bottom: bottomOffset,
            child: Column(
              children: [
                _MapButton(
                  icon: Icons.layers_outlined,
                  active: _showGeofence,
                  onTap: () => setState(() => _showGeofence = !_showGeofence),
                ),
                const SizedBox(height: 10),
                _MapButton(
                  icon: Icons.my_location,
                  onTap: () async {
                    if (app.usingSimulation) await app.startTracking();
                    _mapController.move(app.userPosition, 16);
                  },
                ),
              ],
            ),
          ),

          // Info mode simulasi (hanya muncul saat simulasi aktif)
          if (app.usingSimulation)
            Positioned(
              left: 16,
              bottom: bottomOffset + 6,
              child: GestureDetector(
                onTap: () async {
                  await app.startTracking();
                  _mapController.move(app.userPosition, 15);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Mode simulasi · ketuk untuk kembali ke GPS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

          // Kartu fasilitas terpilih
          if (_selected != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: _SelectedCard(
                facility: _selected!,
                distance: formatDistance(app.distanceTo(_selected!)),
              ),
            ),
        ],
      ),
    );
  }
}

class _MapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool active;
  const _MapButton(
      {required this.icon, required this.onTap, this.active = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 6,
            ),
          ],
        ),
        child: Icon(icon,
            size: 21, color: active ? Colors.white : AppColors.primary),
      ),
    );
  }
}

/// Pin berwarna per jenis fasilitas, dengan nama di bawahnya.
class _PinMarker extends StatelessWidget {
  final Facility facility;
  final bool selected;
  const _PinMarker({required this.facility, required this.selected});

  @override
  Widget build(BuildContext context) {
    final c = typeColor(facility.type);
    return Align(
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_on,
            color: c,
            size: selected ? 48 : 40,
            shadows: const [Shadow(color: Colors.black38, blurRadius: 6)],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              facility.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserMarker extends StatelessWidget {
  const _UserMarker();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3), width: 1),
          ),
        ),
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
          ),
        ),
      ],
    );
  }
}

class _SelectedCard extends StatelessWidget {
  final Facility facility;
  final String distance;
  const _SelectedCard({required this.facility, required this.distance});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 14,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(facility.name,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(
            '${facility.type.label} · $distance · ${facility.hoursLabel}',
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 2),
          Text(
            facility.address,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(44)),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => DetailScreen(facility: facility),
                    ),
                  ),
                  child: const Text('Detail'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(44)),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => RouteScreen(facility: facility),
                    ),
                  ),
                  child: const Text('Rute'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
