import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../providers/app_state.dart';
import 'welcome_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showLocation(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Consumer<AppState>(
        builder: (context, app, _) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Lokasi Saya',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Text('Latitude : ${app.userPosition.latitude.toStringAsFixed(6)}'),
              Text('Longitude: ${app.userPosition.longitude.toStringAsFixed(6)}'),
              const SizedBox(height: 6),
              Text(
                app.usingSimulation
                    ? 'Sumber: simulasi lokasi'
                    : app.gpsAvailable
                        ? 'Sumber: GPS perangkat'
                        : 'Sumber: pusat desa (GPS tidak tersedia)',
                style: const TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  await app.startTracking();
                  if (context.mounted) Navigator.of(context).pop();
                },
                icon: const Icon(Icons.my_location),
                label: const Text('Gunakan GPS'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Consumer<AppState>(
        builder: (context, app, _) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Notifikasi Geofence',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Aktifkan notifikasi'),
                subtitle: const Text('Beri tahu saat memasuki area fasilitas'),
                value: app.notificationsEnabled,
                onChanged: app.setNotifications,
              ),
              const SizedBox(height: 8),
              Text('Radius geofence: ${app.geofenceRadius.round()} m',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              Slider(
                min: 100,
                max: 1000,
                divisions: 9,
                value: app.geofenceRadius.clamp(100, 1000).toDouble(),
                label: '${app.geofenceRadius.round()} m',
                onChanged: app.setRadius,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Profil',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              IconButton(
                onPressed: () => _showNotifications(context),
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primaryLight,
                child: Icon(Icons.person, size: 34, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(app.userName,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  Text(app.userPhone,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textMuted)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.border),
                bottom: BorderSide(color: AppColors.border),
              ),
            ),
            child: Column(
              children: [
                _MenuTile(
                  icon: Icons.my_location,
                  title: 'Lokasi Saya',
                  onTap: () => _showLocation(context),
                ),
                const Divider(height: 1),
                _MenuTile(
                  icon: Icons.notifications_none,
                  title: 'Notifikasi',
                  trailingText: app.notificationsEnabled ? 'Aktif' : 'Mati',
                  onTap: () => _showNotifications(context),
                ),
                const Divider(height: 1),
                const _MenuTile(
                  icon: Icons.language,
                  title: 'Bahasa',
                  trailingText: 'Indonesia',
                ),
                const Divider(height: 1),
                _MenuTile(
                  icon: Icons.help_outline,
                  title: 'Bantuan',
                  onTap: () => showDialog<void>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Bantuan'),
                      content: const Text(
                        '• Cari fasilitas lewat Beranda atau Peta.\n'
                        '• Tekan lama pada peta untuk simulasi lokasi dan menguji geofencing.\n'
                        '• Atur radius dan notifikasi pada menu Notifikasi.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Tutup'),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1),
                _MenuTile(
                  icon: Icons.info_outline,
                  title: 'Tentang Aplikasi',
                  onTap: () => showAboutDialog(
                    context: context,
                    applicationName: 'Sehat Bersama Smart Village',
                    applicationVersion: '1.0.0',
                    applicationLegalese:
                        'Aplikasi pencarian lokasi fasilitas kesehatan dengan LBS dan Geofencing.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const WelcomeScreen()),
              (_) => false,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailingText;
  final VoidCallback? onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    this.trailingText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(trailingText!,
                style: const TextStyle(
                    fontSize: 12.5, color: AppColors.textMuted)),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, color: AppColors.textMuted),
        ],
      ),
      onTap: onTap,
    );
  }
}
