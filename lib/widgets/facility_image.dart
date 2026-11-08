import 'package:flutter/material.dart';

import '../models/facility.dart';

/// Ilustrasi gedung fasilitas kesehatan (digambar dengan CustomPainter,
/// sehingga tidak membutuhkan file foto dan tetap tampil offline).
class FacilityImage extends StatelessWidget {
  final Facility facility;
  final double? width;
  final double? height;
  final double radius;

  /// Tampilkan papan nama bangunan (dipakai pada header halaman detail).
  final bool showSign;

  const FacilityImage({
    super.key,
    required this.facility,
    this.width,
    this.height,
    this.radius = 12,
    this.showSign = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: width,
        height: height,
        child: CustomPaint(
          painter: _BuildingPainter(
            facility.type,
            showSign ? facility.name.toUpperCase() : '',
          ),
        ),
      ),
    );
  }
}

class _BuildingPainter extends CustomPainter {
  final FacilityType type;
  final String sign;

  _BuildingPainter(this.type, this.sign);

  static const _blue = Color(0xFF1E5EFF);
  static const _red = Color(0xFFE5484D);
  static const _green = Color(0xFF2EAA5B);
  static const _glass = Color(0xFFBFE0FF);

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
          colors: [Color(0xFF8EC5FF), Color(0xFFE3F1FF)],
        ).createShader(Offset.zero & size),
    );

    // Jalan + rumput
    final roadTop = h * 0.84;
    canvas.drawRect(Rect.fromLTWH(0, roadTop, w, h - roadTop),
        Paint()..color = const Color(0xFF9AA3AE));
    final grassTop = roadTop - h * 0.05;
    canvas.drawRect(Rect.fromLTWH(0, grassTop, w, h * 0.05),
        Paint()..color = const Color(0xFF7CC47F));
    final baseY = grassTop + h * 0.01;

    // Pohon
    _tree(canvas, w * 0.07, baseY, h * 0.16);
    _tree(canvas, w * 0.94, baseY, h * 0.19);

    switch (type) {
      case FacilityType.rumahSakit:
        _hospital(canvas, w, h, baseY);
        break;
      case FacilityType.puskesmas:
        _puskesmas(canvas, w, h, baseY);
        break;
      case FacilityType.klinik:
        _klinik(canvas, w, h, baseY);
        break;
    }
  }

  void _tree(Canvas canvas, double cx, double baseY, double s) {
    canvas.drawRect(
      Rect.fromCenter(
          center: Offset(cx, baseY - s * 0.2), width: s * 0.14, height: s * 0.4),
      Paint()..color = const Color(0xFF7A5230),
    );
    canvas.drawCircle(Offset(cx, baseY - s * 0.55), s * 0.38,
        Paint()..color = const Color(0xFF3E9B52));
  }

  void _windows(Canvas canvas, Rect area, int rows, int cols) {
    final cw = area.width / cols;
    final ch = area.height / rows;
    final p = Paint()..color = _glass;
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        final rect = Rect.fromLTWH(
          area.left + c * cw + cw * 0.18,
          area.top + r * ch + ch * 0.2,
          cw * 0.64,
          ch * 0.6,
        );
        canvas.drawRRect(
            RRect.fromRectAndRadius(rect, const Radius.circular(1.5)), p);
      }
    }
  }

  void _cross(Canvas canvas, Offset c, double s) {
    canvas.drawCircle(c, s * 0.62, Paint()..color = Colors.white);
    final p = Paint()..color = _red;
    canvas.drawRect(Rect.fromCenter(center: c, width: s, height: s * 0.32), p);
    canvas.drawRect(Rect.fromCenter(center: c, width: s * 0.32, height: s), p);
  }

  void _signText(Canvas canvas, Rect band, double fontSize) {
    final tp = TextPainter(
      text: TextSpan(
        text: sign,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: band.width * 0.92);
    tp.paint(
      canvas,
      Offset(band.center.dx - tp.width / 2, band.center.dy - tp.height / 2),
    );
  }

  void _hospital(Canvas canvas, double w, double h, double baseY) {
    final bw = w * 0.82;
    final bh = h * 0.54;
    final left = (w - bw) / 2;
    final top = baseY - bh;
    final body = Rect.fromLTWH(left, top, bw, bh);

    canvas.drawRect(body, Paint()..color = const Color(0xFFF5F7FA));
    canvas.drawRect(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFFCBD3DD),
    );

    final band = Rect.fromLTWH(left, top, bw, bh * 0.2);
    canvas.drawRect(band, Paint()..color = _blue);
    if (sign.isNotEmpty) {
      _signText(canvas, band, h * 0.05);
    } else {
      _cross(canvas, Offset(w / 2, top - h * 0.07), h * 0.1);
    }

    final winArea = Rect.fromLTWH(
        left + bw * 0.04, top + bh * 0.26, bw * 0.92, bh * 0.46);
    _windows(canvas, winArea, 3, 8);

    // Pintu masuk
    final doorW = bw * 0.16;
    final door = Rect.fromLTWH(w / 2 - doorW / 2, baseY - bh * 0.2, doorW, bh * 0.2);
    canvas.drawRect(door, Paint()..color = _glass);
    canvas.drawRect(
      Rect.fromLTWH(door.left - doorW * 0.2, door.top - bh * 0.03,
          doorW * 1.4, bh * 0.03),
      Paint()..color = _blue,
    );
  }

  void _puskesmas(Canvas canvas, double w, double h, double baseY) {
    final bw = w * 0.68;
    final bh = h * 0.34;
    final left = (w - bw) / 2;
    final top = baseY - bh;

    canvas.drawRect(Rect.fromLTWH(left, top, bw, bh),
        Paint()..color = const Color(0xFFFFF3DC));

    final roof = Path()
      ..moveTo(left - bw * 0.06, top)
      ..lineTo(w / 2, top - bh * 0.5)
      ..lineTo(left + bw * 1.06, top)
      ..close();
    canvas.drawPath(roof, Paint()..color = _green);

    _cross(canvas, Offset(w / 2, top - bh * 0.17), h * 0.09);

    _windows(canvas, Rect.fromLTWH(left + bw * 0.04, top + bh * 0.2, bw * 0.34, bh * 0.45), 1, 2);
    _windows(canvas, Rect.fromLTWH(left + bw * 0.62, top + bh * 0.2, bw * 0.34, bh * 0.45), 1, 2);

    final doorW = bw * 0.16;
    canvas.drawRect(
      Rect.fromLTWH(w / 2 - doorW / 2, baseY - bh * 0.5, doorW, bh * 0.5),
      Paint()..color = const Color(0xFF8A5A33),
    );

    if (sign.isNotEmpty) {
      final band = Rect.fromLTWH(left, top + bh * 0.02, bw, bh * 0.16);
      canvas.drawRect(band, Paint()..color = _green);
      _signText(canvas, band, h * 0.05);
    }
  }

  void _klinik(Canvas canvas, double w, double h, double baseY) {
    final bw = w * 0.7;
    final bh = h * 0.4;
    final left = (w - bw) / 2;
    final top = baseY - bh;

    canvas.drawRect(Rect.fromLTWH(left, top, bw, bh), Paint()..color = Colors.white);
    canvas.drawRect(
      Rect.fromLTWH(left, top, bw, bh),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFFCBD3DD),
    );

    final band = Rect.fromLTWH(left - bw * 0.03, top - bh * 0.02, bw * 1.06, bh * 0.24);
    canvas.drawRect(band, Paint()..color = _blue);
    if (sign.isNotEmpty) {
      _signText(canvas, band, h * 0.05);
    } else {
      _cross(canvas, Offset(w / 2, top + bh * 0.1), h * 0.1);
    }

    _windows(canvas, Rect.fromLTWH(left + bw * 0.04, top + bh * 0.32, bw * 0.42, bh * 0.5), 1, 2);
    _windows(canvas, Rect.fromLTWH(left + bw * 0.54, top + bh * 0.32, bw * 0.42, bh * 0.5), 1, 2);

    final doorW = bw * 0.18;
    canvas.drawRect(
      Rect.fromLTWH(w / 2 - doorW / 2, baseY - bh * 0.34, doorW, bh * 0.34),
      Paint()..color = _glass,
    );
  }

  @override
  bool shouldRepaint(covariant _BuildingPainter old) =>
      old.type != type || old.sign != sign;
}
