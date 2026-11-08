import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../models/geofence_event.dart';
import '../providers/app_state.dart';
import 'map_screen.dart';

/// Layar "Anda Masuk Area Geofencing": peta dengan lingkaran radius
/// dan kartu pemberitahuan di bagian bawah.
class GeofenceScreen extends StatelessWidget {
  final GeofenceEvent event;
  const GeofenceScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final f = event.facility;
    final user = context.read<AppState>().userPosition;

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: f.latLng,
              initialZoom: 15,
              interactionOptions:
                  const InteractionOptions(flags: InteractiveFlag.none),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.sehat_bersama',
              ),
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: f.latLng,
                    radius: event.radius,
                    useRadiusInMeter: true,
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderColor: AppColors.primary.withValues(alpha: 0.6),
                    borderStrokeWidth: 2,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: user,
                    width: 22,
                    height: 22,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                    ),
                  ),
                  Marker(
                    point: f.latLng,
                    width: 60,
                    height: 76,
                    child: const Align(
                      alignment: Alignment.topCenter,
                      child: Icon(
                        Icons.location_on,
                        color: AppColors.red,
                        size: 46,
                        shadows: [Shadow(color: Colors.black38, blurRadius: 6)],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Redupkan peta di belakang kartu
          Positioned.fill(
            child: IgnorePointer(
              child: ColoredBox(color: Colors.black.withValues(alpha: 0.28)),
            ),
          ),
          // Lencana radius
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Radius ${event.radius.round()} m',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Kartu pemberitahuan
          Positioned(
            left: 16,
            right: 16,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: InkResponse(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Icon(Icons.close, size: 20),
                        ),
                      ),
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.green.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.where_to_vote,
                            color: AppColors.green, size: 34),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Anda Masuk Area Geofencing',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Selamat! Anda telah memasuki area ${f.name} '
                        '(radius ${event.radius.round()} m).\n'
                        'Jarak Anda: ${formatDistance(event.distance)}.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textMuted,
                            height: 1.4),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => MapScreen(focus: f),
                          ),
                        ),
                        child: const Text('Lihat Lokasi'),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.border),
                        ),
                        child: const Text('Tutup'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
