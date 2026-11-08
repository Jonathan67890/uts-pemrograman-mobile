import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../models/facility.dart';
import '../providers/app_state.dart';
import '../widgets/facility_card.dart';
import '../widgets/facility_image.dart';
import 'map_screen.dart';

class DetailScreen extends StatelessWidget {
  final Facility facility;
  const DetailScreen({super.key, required this.facility});

  static const _order = [
    'Poliklinik',
    'IGD',
    'Rawat Inap',
    'Laboratorium',
    'Radiologi',
    'Farmasi',
    'Rehabilitasi',
  ];

  List<String> get _services {
    int key(String s) {
      final k = _order.indexOf(s);
      return k >= 0 ? k : 100 + facility.services.indexOf(s);
    }

    final list = [...facility.services]
      ..sort((a, b) => key(a).compareTo(key(b)));
    return [...list, 'Lainnya'];
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final fav = app.isFavorite(facility.id);
    final distance = formatDistance(app.distanceTo(facility));

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      FacilityImage(
                        facility: facility,
                        width: double.infinity,
                        height: 230,
                        radius: 0,
                        showSign: true,
                      ),
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _RoundButton(
                                icon: Icons.arrow_back_ios_new,
                                onTap: () => Navigator.of(context).pop(),
                              ),
                              _RoundButton(
                                icon: fav
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: fav ? AppColors.red : AppColors.text,
                                onTap: () => app.toggleFavorite(facility.id),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(facility.name,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                size: 18, color: AppColors.orange),
                            const SizedBox(width: 4),
                            Text(
                              '${facility.rating} (${facility.reviewCount} ulasan)',
                              style: const TextStyle(
                                  fontSize: 13, color: AppColors.textMuted),
                            ),
                            const Spacer(),
                            const Icon(Icons.place,
                                size: 16, color: AppColors.primary),
                            const SizedBox(width: 2),
                            Text(distance,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            StatusChip(open: facility.isOpenNow),
                            const SizedBox(width: 8),
                            Text(facility.hoursLabel,
                                style: const TextStyle(
                                    fontSize: 12.5,
                                    color: AppColors.textMuted)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on,
                                size: 18, color: AppColors.primary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(facility.address,
                                  style: const TextStyle(
                                      fontSize: 13, height: 1.35)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        const Text('Jenis Pelayanan',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        GridView.count(
                          crossAxisCount: 4,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 8,
                          childAspectRatio: 0.9,
                          children: [
                            for (final s in _services)
                              Column(
                                children: [
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(serviceIcon(s),
                                        color: AppColors.primary),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(s,
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 11)),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MapScreen(focus: facility),
                  ),
                ),
                child: const Text('Lihat di Peta'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  const _RoundButton(
      {required this.icon, required this.onTap, this.color = AppColors.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}
