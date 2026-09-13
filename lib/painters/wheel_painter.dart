import 'dart:math';

import 'package:flutter/material.dart';

import '../models/wheel_spin.dart';

/// İsim listesini dilimlere bölüp çizen çark.
///
/// Çark döner, ibre saat 12'de sabit durur. Renkler isim sayısına göre renk
/// çemberine eşit dağıtılır; komşu dilimler ayrıca açık/koyu değişerek
/// birbirinden ayrılır, böylece 20 isimde bile sınırlar okunur kalır.
class WheelPainter extends CustomPainter {
  final List<String> names;

  /// Çarkın o anki dönüşü (radyan)
  final double angle;

  /// Açıklandıysa kazanan dilimler; henüz açıklanmadıysa boş
  final List<int> winners;

  /// Kazanan diliminin öne çıkma animasyonu (0 → 1)
  final double reveal;

  const WheelPainter({
    required this.names,
    required this.angle,
    required this.winners,
    required this.reveal,
  });

  /// Göbeğin yarıçapı — çark yarıçapına oran
  static const double _hubRatio = 0.17;

  @override
  void paint(Canvas canvas, Size size) {
    if (names.isEmpty) return;

    final center = size.center(Offset.zero);
    final radius = min(size.width, size.height) / 2 - 14;
    if (radius <= 0) return;

    final seg = WheelSpin.segment(names.length);
    final hub = radius * _hubRatio;

    for (var i = 0; i < names.length; i++) {
      final start = WheelSpin.startAngle + i * seg + angle;
      final isWinner = winners.contains(i);
      // Kazanan açıklanınca diğerleri geri çekilir; kazanan olduğu gibi kalır
      final dim = winners.isEmpty || isWinner ? 1.0 : 1.0 - 0.62 * reveal;

      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = colorFor(i, names.length).withValues(alpha: dim);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        seg,
        true,
        paint,
      );

      _paintLabel(canvas, center, radius, hub, start + seg / 2, seg, i, dim);
    }

    // ── Kazanan dilimlerin çevresi ────────────────────────────────────────
    for (final winner in winners) {
      if (reveal <= 0) break;
      final start = WheelSpin.startAngle + winner * seg + angle;
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(
          Rect.fromCircle(center: center, radius: radius),
          start,
          seg,
          false,
        )
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0 * reveal
          ..color = Colors.white.withValues(alpha: reveal),
      );
    }

    // ── Dış çember ────────────────────────────────────────────────────────
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = Colors.white.withValues(alpha: 0.85),
    );

    // ── Göbek: dönüşün ekseni ─────────────────────────────────────────────
    canvas.drawCircle(center, hub, Paint()..color = const Color(0xFF111111));
    canvas.drawCircle(
      center,
      hub,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.85),
    );

    _paintPointer(canvas, center, radius);
  }

  /// Renk çemberini isim sayısına eşit böler. Komşu dilimlerin açıklığı
  /// dönüşümlü değişir; yan yana iki yakın ton birbirine karışmasın diye.
  static Color colorFor(int index, int count) {
    final hue = (360.0 / count) * index;
    // Parmak dairelerindeki pastel ton (doygunluk .65, açıklık .80) buranın da
    // ölçüsü: daha doygunu koyu arka planda neon gibi duruyor ve uygulamanın
    // geri kalanıyla aynı dili konuşmuyor.
    final lightness = index.isEven ? 0.78 : 0.70;
    return HSLColor.fromAHSL(1.0, hue % 360, 0.50, lightness).toColor();
  }

  /// İsmi dilimin ortasına, yarıçap boyunca yazar. Sol yarıya düşen yazılar
  /// baş aşağı durmasın diye ters çevrilip dıştan içe hizalanır.
  void _paintLabel(
    Canvas canvas,
    Offset center,
    double radius,
    double hub,
    double midAngle,
    double seg,
    int index,
    double dim,
  ) {
    final available = radius - hub - 22;
    if (available <= 12) return;

    // Yazı yüksekliği dilimin yay genişliğini aşmasın
    final fontSize = (seg * radius * 0.34).clamp(10.0, 22.0);
    final painter = TextPainter(
      text: TextSpan(
        text: names[index],
        style: TextStyle(
          color: Colors.black.withValues(alpha: 0.86 * dim),
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: available);

    final normalized = (midAngle + pi) % (2 * pi) - pi;
    final flip = cos(normalized) < 0;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(normalized);
    if (flip) {
      canvas.rotate(pi);
      painter.paint(canvas, Offset(-radius + 14, -painter.height / 2));
    } else {
      painter.paint(canvas, Offset(hub + 14, -painter.height / 2));
    }
    canvas.restore();
    painter.dispose();
  }

  /// Saat 12'de duran, çarkın içine bakan ibre
  void _paintPointer(Canvas canvas, Offset center, double radius) {
    final tip = Offset(center.dx, center.dy - radius + 10);
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(tip.dx - 15, tip.dy - 26)
      ..lineTo(tip.dx + 15, tip.dy - 26)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawPath(path, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(WheelPainter old) =>
      old.angle != angle ||
      old.names != names ||
      old.winners != winners ||
      old.reveal != reveal;
}
