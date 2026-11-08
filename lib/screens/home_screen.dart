import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/facility.dart';
import '../providers/app_state.dart';
import '../widgets/facility_card.dart';
import 'list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _query = '';

  void _openList({FacilityType? type}) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ListScreen(initialType: type)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final searching = _query.trim().isNotEmpty;
    final items = searching ? app.search(query: _query) : app.search().take(3).toList();

    final categories = <_Category>[
      _Category('Rumah Sakit', Icons.add_box_rounded, AppColors.red,
          FacilityType.rumahSakit),
      _Category('Puskesmas', Icons.health_and_safety_rounded, AppColors.green,
          FacilityType.puskesmas),
      _Category('Klinik', Icons.vaccines_rounded, AppColors.primary,
          FacilityType.klinik),
      _Category('Semua', Icons.apps_rounded, AppColors.orange, null),
    ];

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.primary, size: 34),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Smart Village',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800)),
                    Row(
                      children: [
                        Icon(Icons.place,
                            size: 11, color: AppColors.textMuted),
                        SizedBox(width: 2),
                        Text('Kabupaten X',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.textMuted)),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(app.notificationsEnabled
                          ? 'Notifikasi geofence aktif (radius ${app.geofenceRadius.round()} m)'
                          : 'Notifikasi geofence nonaktif'),
                    ),
                  );
                },
                icon: const Icon(Icons.notifications_none, size: 26),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 48,
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Cari rumah sakit, puskesmas, klinik...',
                hintStyle:
                    const TextStyle(color: AppColors.textMuted, fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final c in categories)
                GestureDetector(
                  onTap: () => _openList(type: c.type),
                  child: SizedBox(
                    width: 74,
                    child: Column(
                      children: [
                        Container(
                          width: 62,
                          height: 62,
                          decoration: BoxDecoration(
                            color: c.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Icon(c.icon, color: c.color, size: 32),
                        ),
                        const SizedBox(height: 6),
                        Text(c.label,
                            style: const TextStyle(
                                fontSize: 11.5, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(searching ? 'Hasil Pencarian' : 'Layanan Kesehatan Terdekat',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700)),
              if (!searching)
                TextButton(
                  onPressed: () => _openList(),
                  child: const Text('Lihat Semua >',
                      style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
          if ((!app.gpsAvailable || app.outsideVillage) && !app.usingSimulation)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.orange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: AppColors.orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Posisi Anda di luar area desa atau GPS tidak aktif. Jarak dihitung dari pusat desa.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text('Fasilitas tidak ditemukan',
                    style: TextStyle(color: AppColors.textMuted)),
              ),
            ),
          for (final f in items) FacilityCard(facility: f, maxChips: 3),
        ],
      ),
    );
  }
}

class _Category {
  final String label;
  final IconData icon;
  final Color color;
  final FacilityType? type;
  _Category(this.label, this.icon, this.color, this.type);
}
