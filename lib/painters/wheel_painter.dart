import 'dart:math';

import 'package:flutter/material.dart';

import '../models/wheel_spin.dart';

/// İsim listesini dilimlere bölüp çizen çark.
///
/// Çark döner, ibre saat 12'de sabit durur. Dilimler ortası boş bir halka
/// olarak çizilir ve aralarında ince karanlık boşluklar kalır; dolu bir pasta
/// koyu arka planda ağır duruyordu. İsimlerin hepsi aynı yarıçapta yazılır —
/// yarıçapı yazının uzunluğuna bırakmak kısa isimleri göbeğe, uzunları kenara
/// yaslayıp çarkı dağınık gösteriyordu.
class WheelPainter extends CustomPainter {
  final List<String> names;

  /// Çarkın o anki dönüşü (radyan)
  final double angle;

  /// Açıklandıysa kazanan dilimler; henüz açıklanmadıysa boş
  final List<int> winners;

  /// Kazanan dilimlerin öne çıkma animasyonu (0 → 1)
  final double reveal;

  /// İsimlerin görünürlüğü (0 → 1). Dönerken sıfıra iner: okunamayan yazılar
  /// dönüşü bulanık gösteriyor, renkler tek başına daha temiz dönüyor.
  final double labelOpacity;

  /// Yazılacak isimlerin indeksleri. Çark dururken hepsi, dönüş bitince
  /// yalnızca ibrenin gösterdiği — göz doğrudan ona gitsin.
  final List<int> labelIndices;

  const WheelPainter({
    required this.names,
    required this.angle,
    required this.winners,
    required this.reveal,
    required this.labelOpacity,
    required this.labelIndices,
  });

  /// Dilimlerin başladığı iç yarıçap (dış yarıçapa oran)
  static const double _innerRatio = 0.34;

  /// İki dilim arasındaki karanlık aralık (radyan)
  static const double _sliceGap = 0.016;

  /// Çarkın kenarı ile ibre arasında bırakılan pay
  static const double _rimMargin = 18.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (names.isEmpty) return;

    final center = size.center(Offset.zero);
    final outer = min(size.width, size.height) / 2 - _rimMargin;
    if (outer <= 0) return;

    final inner = outer * _innerRatio;
    final seg = WheelSpin.segment(names.length);
    // Çok isimde dilim inceliyor; aralık dilimi yutmasın
    final gap = min(_sliceGap, seg * 0.16);

    // ── Dilimler ──────────────────────────────────────────────────────────
    for (var i = 0; i < names.length; i++) {
      final start = WheelSpin.startAngle + i * seg + angle;
      canvas.drawPath(
        _slicePath(center, inner, outer, start + gap / 2, seg - gap),
        Paint()
          ..color = colorFor(i, names.length).withValues(alpha: _dimFor(i)),
      );
    }

    // ── Kazanan dilimin çevresi ───────────────────────────────────────────
    if (reveal > 0) {
      for (final winner in winners) {
        final start = WheelSpin.startAngle + winner * seg + angle;
        canvas.drawPath(
          _slicePath(center, inner, outer, start + gap / 2, seg - gap),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5 * reveal
            ..color = Colors.white.withValues(alpha: 0.9 * reveal),
        );
      }
    }

    // ── İsimler ───────────────────────────────────────────────────────────
    if (labelOpacity > 0.01) {
      for (final i in labelIndices) {
        if (i < 0 || i >= names.length) continue;
        final mid = WheelSpin.startAngle + (i + 0.5) * seg + angle;
        _paintLabel(canvas, center, inner, outer, seg, mid, i);
      }
    }

    _paintPointer(canvas, center, outer);
  }

  /// Açıklamadan sonra kazanan dışındaki dilimler geri çekilir
  double _dimFor(int index) =>
      winners.isEmpty || winners.contains(index) ? 1.0 : 1.0 - 0.66 * reveal;

  /// İç ve dış yay arasındaki halka dilimi
  Path _slicePath(
    Offset center,
    double inner,
    double outer,
    double start,
    double sweep,
  ) =>
      Path()
        ..arcTo(Rect.fromCircle(center: center, radius: outer), start, sweep,
            true)
        ..arcTo(Rect.fromCircle(center: center, radius: inner), start + sweep,
            -sweep, false)
        ..close();

  /// Renk çemberini isim sayısına eşit böler. Parmak dairelerindeki pastel ton
  /// buranın da ölçüsü; daha doygunu koyu arka planda neon gibi duruyor.
  /// Komşu dilimlerin açıklığı dönüşümlü değişerek sınırı belirginleştirir.
  static Color colorFor(int index, int count) {
    final hue = (360.0 / count) * index;
    final lightness = index.isEven ? 0.78 : 0.70;
    return HSLColor.fromAHSL(1.0, hue % 360, 0.50, lightness).toColor();
  }

  /// İsmi dilimin ortasına, halkanın orta yarıçapına yazar. Sol yarıya düşen
  /// yazılar baş aşağı durmasın diye ters çevrilir.
  void _paintLabel(
    Canvas canvas,
    Offset center,
    double inner,
    double outer,
    double seg,
    double midAngle,
    int index,
  ) {
    final band = outer - inner;
    if (band <= 16) return;

    final labelRadius = (inner + outer) / 2;
    // Yazı yüksekliği dilimin o yarıçaptaki yay genişliğini aşmasın
    final fontSize = (seg * labelRadius * 0.42).clamp(10.0, 21.0);
    final painter = _labelPainter(
      names[index],
      fontSize,
      band - 14,
      0.88 * _dimFor(index) * labelOpacity,
    );

    final normalized = (midAngle + pi) % (2 * pi) - pi;
    final flip = cos(normalized) < 0;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(normalized);
    if (flip) canvas.rotate(pi);
    final x = flip ? -labelRadius : labelRadius;
    painter.paint(canvas, Offset(x - painter.width / 2, -painter.height / 2));
    canvas.restore();
  }

  /// Yerleşimi hesaplanmış etiketler.
  ///
  /// Dönüş 60fps çiziliyor ve isimler değişmiyor; her karede hepsini yeniden
  /// yerleştirmek dönüşü takılatıyordu. Opaklık açıklamada kısa süre değiştiği
  /// için ara değerler yuvarlanarak birkaç varyantla sınırlanıyor.
  static final Map<String, TextPainter> _labelCache = {};
  static const int _labelCacheLimit = 240;

  TextPainter _labelPainter(
    String name,
    double fontSize,
    double maxWidth,
    double alpha,
  ) {
    final rounded = (alpha * 20).round() / 20;
    final key = '$name|${fontSize.round()}|${maxWidth.round()}|$rounded';
    final painter = _labelCache.putIfAbsent(
      key,
      () => TextPainter(
        text: TextSpan(
          text: name,
          style: TextStyle(
            color: Colors.black.withValues(alpha: rounded),
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '…',
      )..layout(maxWidth: maxWidth),
    );
    if (_labelCache.length > _labelCacheLimit) {
      _labelCache.remove(_labelCache.keys.first);
    }
    return painter;
  }

  /// Saat 12'de duran, çarkın içine bakan ibre
  void _paintPointer(Canvas canvas, Offset center, double radius) {
    final tip = Offset(center.dx, center.dy - radius + 4);
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(tip.dx - 13, tip.dy - 21)
      ..lineTo(tip.dx + 13, tip.dy - 21)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawPath(path, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(WheelPainter old) =>
      old.angle != angle ||
      old.names != names ||
      old.winners != winners ||
      old.reveal != reveal ||
      old.labelOpacity != labelOpacity ||
      old.labelIndices != labelIndices;
}
