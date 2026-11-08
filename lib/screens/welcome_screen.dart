import 'package:flutter/material.dart';

import '../core/theme.dart';
import 'main_shell.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _enter(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            const _Logo(),
            const SizedBox(height: 14),
            const Text(
              'Sehat Bersama\nSmart Village',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                height: 1.2,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 44),
              child: Text(
                'Temukan lokasi Klinik, Puskesmas\ndan Rumah Sakit terdekat\ndengan mudah.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13, color: AppColors.textMuted, height: 1.4),
              ),
            ),
            const SizedBox(height: 8),
            const Expanded(
              child: SizedBox(
                width: double.infinity,
                child: CustomPaint(painter: _VillagePainter()),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 10, 28, 0),
              child: ElevatedButton(
                onPressed: () => _enter(context),
                child: const Text('Mulai'),
              ),
            ),
            TextButton(
              onPressed: () => _enter(context),
              child: const Text('Masuk',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 84,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          const Icon(Icons.location_on, size: 84, color: AppColors.primary),
          Positioned(
            top: 17,
            child: Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, size: 26, color: AppColors.red),
            ),
          ),
        ],
      ),
    );
  }
}

/// Ilustrasi desa: rumah sakit, rumah warga, jalan, pepohonan.
class _VillagePainter extends CustomPainter {
  const _VillagePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Langit
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Color(0xFFD6E9FF)],
        ).createShader(Offset.zero & size),
    );

    // Awan
    final cloud = Paint()..color = Colors.white;
    canvas.drawOval(Rect.fromLTWH(w * 0.05, h * 0.12, w * 0.22, h * 0.07), cloud);
    canvas.drawOval(Rect.fromLTWH(w * 0.72, h * 0.06, w * 0.24, h * 0.08), cloud);

    // Bukit
    final hill = Path()
      ..moveTo(0, h * 0.72)
      ..quadraticBezierTo(w * 0.25, h * 0.58, w * 0.5, h * 0.7)
      ..quadraticBezierTo(w * 0.78, h * 0.58, w, h * 0.7)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(hill, Paint()..color = const Color(0xFFBFE3C2));

    final grass = Path()
      ..moveTo(0, h * 0.8)
      ..quadraticBezierTo(w * 0.5, h * 0.72, w, h * 0.8)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(grass, Paint()..color = const Color(0xFF8ED08F));

    // Jalan
    final road = Path()
      ..moveTo(w * 0.47, h * 0.76)
      ..quadraticBezierTo(w * 0.40, h * 0.9, w * 0.12, h)
      ..lineTo(w * 0.78, h)
      ..quadraticBezierTo(w * 0.56, h * 0.9, w * 0.53, h * 0.76)
      ..close();
    canvas.drawPath(road, Paint()..color = const Color(0xFF8D96A3));

    final line = Path()
      ..moveTo(w * 0.50, h * 0.78)
      ..quadraticBezierTo(w * 0.47, h * 0.9, w * 0.45, h);
    canvas.drawPath(
      line,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.8),
    );

    // Rumah sakit
    final bw = w * 0.36;
    final bh = h * 0.34;
    final left = (w - bw) / 2;
    final base = h * 0.77;
    final top = base - bh;
    canvas.drawRect(Rect.fromLTWH(left, top, bw, bh),
        Paint()..color = const Color(0xFFF7F8FA));
    canvas.drawRect(Rect.fromLTWH(left, top, bw, bh * 0.16),
        Paint()..color = AppColors.primary);
    // salib merah
    canvas.drawCircle(Offset(w / 2, top - bh * 0.1), bw * 0.1,
        Paint()..color = Colors.white);
    final r = Paint()..color = AppColors.red;
    canvas.drawRect(
        Rect.fromCenter(
            center: Offset(w / 2, top - bh * 0.1),
            width: bw * 0.13,
            height: bw * 0.04),
        r);
    canvas.drawRect(
        Rect.fromCenter(
            center: Offset(w / 2, top - bh * 0.1),
            width: bw * 0.04,
            height: bw * 0.13),
        r);
    // jendela
    final win = Paint()..color = const Color(0xFFBFE0FF);
    for (var row = 0; row < 3; row++) {
      for (var col = 0; col < 5; col++) {
        canvas.drawRect(
          Rect.fromLTWH(left + bw * (0.07 + col * 0.18),
              top + bh * (0.26 + row * 0.2), bw * 0.11, bh * 0.1),
          win,
        );
      }
    }
    canvas.drawRect(
      Rect.fromLTWH(w / 2 - bw * 0.07, base - bh * 0.18, bw * 0.14, bh * 0.18),
      win,
    );

    // Rumah warga
    _house(canvas, w * 0.08, h * 0.80, w * 0.22, h * 0.14, AppColors.red);
    _house(canvas, w * 0.72, h * 0.80, w * 0.22, h * 0.14, AppColors.orange);

    // Pohon
    _tree(canvas, w * 0.33, h * 0.80, h * 0.1);
    _tree(canvas, w * 0.67, h * 0.80, h * 0.1);
    _tree(canvas, w * 0.04, h * 0.86, h * 0.12);
    _tree(canvas, w * 0.97, h * 0.86, h * 0.12);
  }

  void _house(Canvas canvas, double x, double base, double hw, double hh,
      Color roofColor) {
    canvas.drawRect(Rect.fromLTWH(x, base - hh, hw, hh),
        Paint()..color = const Color(0xFFFFF3DC));
    final roof = Path()
      ..moveTo(x - hw * 0.08, base - hh)
      ..lineTo(x + hw / 2, base - hh * 1.6)
      ..lineTo(x + hw * 1.08, base - hh)
      ..close();
    canvas.drawPath(roof, Paint()..color = roofColor);
    canvas.drawRect(
      Rect.fromLTWH(x + hw * 0.4, base - hh * 0.55, hw * 0.2, hh * 0.55),
      Paint()..color = const Color(0xFF8A5A33),
    );
  }

  void _tree(Canvas canvas, double cx, double base, double s) {
    canvas.drawRect(
      Rect.fromCenter(
          center: Offset(cx, base - s * 0.2), width: s * 0.14, height: s * 0.4),
      Paint()..color = const Color(0xFF7A5230),
    );
    canvas.drawCircle(Offset(cx, base - s * 0.6), s * 0.4,
        Paint()..color = const Color(0xFF2F9E55));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
