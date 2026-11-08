import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/facility.dart';
import '../providers/app_state.dart';
import '../widgets/facility_card.dart';

/// Daftar Lokasi dengan filter kategori.
class ListScreen extends StatefulWidget {
  final FacilityType? initialType;

  const ListScreen({super.key, this.initialType});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  late FacilityType? _type = widget.initialType;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final items = app.search(type: _type);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        title: const Text('Daftar Lokasi',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: FacilityFilterChips(
              selected: _type,
              rsLabel: 'Rumah Sakit',
              onChanged: (t) => setState(() => _type = t),
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Text('Fasilitas tidak ditemukan',
                        style: TextStyle(color: AppColors.textMuted)),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    children: [
                      for (final f in items) FacilityCard(facility: f),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// Chip filter: Semua / Rumah Sakit (atau RS) / Puskesmas / Klinik.
/// Dipakai pada layar Daftar Lokasi dan Peta.
class FacilityFilterChips extends StatelessWidget {
  final FacilityType? selected;
  final ValueChanged<FacilityType?> onChanged;
  final String rsLabel;

  const FacilityFilterChips({
    super.key,
    required this.selected,
    required this.onChanged,
    this.rsLabel = 'Rumah Sakit',
  });

  @override
  Widget build(BuildContext context) {
    final options = <MapEntry<String, FacilityType?>>[
      const MapEntry('Semua', null),
      MapEntry(rsLabel, FacilityType.rumahSakit),
      const MapEntry('Puskesmas', FacilityType.puskesmas),
      const MapEntry('Klinik', FacilityType.klinik),
    ];
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final o = options[i];
          final active = o.value == selected;
          return GestureDetector(
            onTap: () => onChanged(o.value),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: active ? AppColors.primary : AppColors.border),
              ),
              child: Text(
                o.key,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.white : AppColors.text,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
