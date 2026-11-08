import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../models/facility.dart';
import '../providers/app_state.dart';
import '../screens/detail_screen.dart';
import 'facility_image.dart';

class StatusChip extends StatelessWidget {
  final bool open;
  const StatusChip({super.key, required this.open});

  @override
  Widget build(BuildContext context) {
    final c = open ? AppColors.green : AppColors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 7, color: c),
          const SizedBox(width: 4),
          Text(
            open ? 'Buka' : 'Tutup',
            style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// Kartu fasilitas pada Beranda dan Daftar Lokasi.
class FacilityCard extends StatelessWidget {
  final Facility facility;

  /// Jumlah chip layanan yang ditampilkan (sisanya diganti "...").
  final int maxChips;

  const FacilityCard({super.key, required this.facility, this.maxChips = 4});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final distance = formatDistance(app.distanceTo(facility));
    final shown = facility.services.take(maxChips).toList();
    final hasMore = facility.services.length > maxChips;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DetailScreen(facility: facility),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FacilityImage(facility: facility, width: 78, height: 78),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              facility.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          StatusChip(open: facility.isOpenNow),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.place_outlined,
                              size: 14, color: AppColors.textMuted),
                          const SizedBox(width: 2),
                          Text(distance,
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.textMuted)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.star,
                              size: 14, color: AppColors.orange),
                          const SizedBox(width: 2),
                          Text(
                            '${facility.rating} (${facility.reviewCount})',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          for (final s in shown) _Chip(s),
                          if (hasMore) const _Chip('...'),
                        ],
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 28),
                  child: Icon(Icons.chevron_right, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  const _Chip(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text,
          style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
    );
  }
}
