import 'dart:math';

import 'package:flutter/material.dart';

import '../models/spin_beam.dart';

/// Ekrandaki parmak dairelerini canvas üzerine çizen [CustomPainter].
///
/// Her parmak için pastel dolgu, beyaz kenarlık, glow ve döngü vurgu
/// efektlerini işler. Açıklanan sonucu da çizer: öne çıkan daireler büyür
/// ve parlar, takım harfi ya da sıra numarası dairenin ortasına yazılır.
class FingerPainter extends CustomPainter {
  final Map<int, Offset> activePointers;
  final Map<int, Color> pointerColors;
  final List<int> lockedPointerIds;

  /// Açıklamada öne çıkan pointer'lar: kazananlar, kaybedenler, takım
  /// modunda herkes, sıra modunda birinci. Boşsa sonuç henüz açıklanmadı.
  final List<int> spotlightPointerIds;

  /// Dairelerin ortasına yazılan etiketler (takım harfi ya da sıra numarası)
  final Map<int, String> labels;

  /// True ise öne çıkmayan daireler neredeyse tamamen solar. Sıra modunda
  /// false — herkesin numarası okunabilir kalmalı.
  final bool dimOthers;

  /// Sonuç açıklanmadan önce dönen rulet ışını; dönmüyorsa null
  final SpinBeam? beam;

  /// True iken pointer listesi kilitlenmiş demektir (choosing veya revealed)
  final bool isLocked;

  /// Öne çıkan dairelerin scale animasyonunun anlık değeri (1.0 → 1.4)
  final double winnerScale;

  /// Öne çıkan dairelerin glow animasyonunun anlık değeri (0.35 → 1.0)
  final double winnerGlow;

  const FingerPainter({
    required this.activePointers,
    required this.pointerColors,
    required this.lockedPointerIds,
    required this.spotlightPointerIds,
    required this.labels,
    required this.dimOthers,
    required this.beam,
    required this.isLocked,
    required this.winnerScale,
    required this.winnerGlow,
  });

  /// Temel yarıçap — 90px çap
  static const double _baseRadius = 45.0;

  /// Işın konisinin yarı açısı (radyan) — uçtaki genişliği belirler
  static const double _beamSpread = 0.055;

  /// Işının merkeze yaklaşmadan kestiği yarıçap. Ortada boşluk kalması hem
  /// dönen bir tekerlek kolu hissi verir hem de "Seçiliyor..." yazısının
  /// üstüne parlak bir nokta binmesini engeller.
  static const double _beamInnerGap = 30.0;

  /// Işının gerisinde bırakılan sönük kopya sayısı; dönüş yönünü hissettirir
  static const int _beamTrailCount = 3;

  /// İki iz kopyası arasındaki açı farkı
  static const double _beamTrailStep = 0.085;

  @override
  void paint(Canvas canvas, Size size) {
    final hasResult = spotlightPointerIds.isNotEmpty;

    // Işın dairelerin altında kalsın — parmakların üstünden geçen bir tarama
    // değil, altlarında dönen bir işaretçi gibi okunuyor
    final beam = this.beam;
    if (beam != null && !hasResult) _paintBeam(canvas, beam);

    for (final entry in activePointers.entries) {
      final pointerId = entry.key;
      final position = entry.value;
      final color = pointerColors[pointerId] ?? Colors.white;

      final isSpotlit = spotlightPointerIds.contains(pointerId);

      // Işının şu an gösterdiği daire mi?
      final isCycleHighlight = !hasResult &&
          beam != null &&
          beam.highlightIndex < lockedPointerIds.length &&
          lockedPointerIds[beam.highlightIndex] == pointerId;

      // ── Görsel durum hesapla ──────────────────────────────────────────────
      double opacity;
      double scale;

      if (hasResult) {
        // Öne çıkanlar büyür ve parlak kalır; diğerleri solar
        opacity = isSpotlit ? 1.0 : (dimOthers ? 0.15 : 0.6);
        scale = isSpotlit ? winnerScale : 1.0;
      } else if (isLocked) {
        // Döngülü vurgulama animasyonu
        opacity = isCycleHighlight ? 1.0 : 0.40;
        scale = isCycleHighlight ? 1.15 : 1.0;
      } else {
        opacity = 1.0;
        scale = 1.0;
      }

      final currentRadius = _baseRadius * scale;

      // ── Öne çıkan daire için nabız gibi yayılan ışık ──────────────────────
      if (isSpotlit) {
        _paintGlow(
          canvas,
          position,
          currentRadius * 1.7 + 70.0 * winnerGlow,
          color,
          0.55 * winnerGlow,
        );
      }

      // ── Döngü vurgusu için yumuşak aydınlık halka ────────────────────────
      if (isCycleHighlight) {
        _paintGlow(
          canvas,
          position,
          currentRadius * 1.35 + 35.0,
          Colors.white,
          0.24,
        );
      }

      // ── Pastel dolgulu daire ──────────────────────────────────────────────
      final fillPaint = Paint()
        ..color = color.withAlpha((255 * opacity * 0.50).round())
        ..style = PaintingStyle.fill;
      canvas.drawCircle(position, currentRadius, fillPaint);

      // ── Beyaz kenarlık halkası ────────────────────────────────────────────
      final borderPaint = Paint()
        ..color = Colors.white.withAlpha((255 * opacity).round())
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSpotlit ? 3.5 : 2.0;
      canvas.drawCircle(position, currentRadius, borderPaint);

      // ── Takım harfi ya da sıra numarası ───────────────────────────────────
      final label = labels[pointerId];
      if (label != null) {
        _paintLabel(canvas, label, position, currentRadius, opacity);
      }
    }
  }

  /// Parmakların ağırlık merkezi etrafında dönen rulet ışını.
  ///
  /// Koni uca doğru genişleyip sönen bir projektör gibi çizilir; ortasındaki
  /// ince parlak çizgi hangi noktayı gösterdiğini netleştirir. Arkasındaki
  /// sönük kopyalar hareket izi verir — asıl işi 60fps'te tek karede bile
  /// dönüş yönünün okunmasını sağlamak.
  void _paintBeam(Canvas canvas, SpinBeam beam) {
    canvas.save();
    canvas.translate(beam.center.dx, beam.center.dy);

    // İz önce çizilir ki asıl ışın üstünde kalsın; uzaktaki kopya en sönük
    for (var i = _beamTrailCount; i >= 1; i--) {
      _paintBeamCone(
        canvas,
        beam.angle - i * _beamTrailStep,
        beam.reach,
        0.10 / i,
      );
    }
    _paintBeamCone(canvas, beam.angle, beam.reach, 0.32);

    // Koninin ortasındaki keskin çizgi — ışının tam olarak neyi gösterdiği
    canvas.save();
    canvas.rotate(beam.angle);
    canvas.drawLine(
      const Offset(_beamInnerGap, 0),
      Offset(beam.reach, 0),
      Paint()
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..shader = const LinearGradient(
          colors: [Color(0xE6FFFFFF), Color(0x66FFFFFF), Color(0x00FFFFFF)],
          stops: [0.0, 0.6, 1.0],
        ).createShader(
          Rect.fromLTWH(_beamInnerGap, -1.5, beam.reach - _beamInnerGap, 3),
        ),
    );
    canvas.restore();

    canvas.restore();
  }

  /// [angle] yönüne uzanan, ucuna doğru genişleyip sönen koni.
  /// Canvas'ın merkeze taşınmış olması beklenir.
  void _paintBeamCone(
    Canvas canvas,
    double angle,
    double reach,
    double strength,
  ) {
    canvas.save();
    canvas.rotate(angle);

    final innerSpread = _beamInnerGap * tan(_beamSpread);
    final outerSpread = reach * tan(_beamSpread);
    final path = Path()
      ..moveTo(_beamInnerGap, -innerSpread)
      ..lineTo(reach, -outerSpread)
      ..lineTo(reach, outerSpread)
      ..lineTo(_beamInnerGap, innerSpread)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withAlpha((255 * strength).round()),
            Colors.white.withAlpha((255 * strength * 0.5).round()),
            Colors.white.withAlpha(0),
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(
          Rect.fromLTWH(
            _beamInnerGap,
            -outerSpread,
            reach - _beamInnerGap,
            outerSpread * 2,
          ),
        ),
    );

    canvas.restore();
  }

  /// Merkezden dışarı sönen yumuşak ışık.
  ///
  /// Bulanıklık ([MaskFilter.blur]) yerine radyal gradyan kullanılıyor:
  /// görünüm aynı ama maliyet tek bir çizim. Takım modunda beş daire birden
  /// parladığı için bulanıklık her karede beş kez hesaplanıyordu ve kareler
  /// düşüyordu.
  void _paintGlow(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
    double strength,
  ) {
    if (strength <= 0) return;
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withAlpha((255 * strength).round()),
          color.withAlpha((255 * strength * 0.55).round()),
          color.withAlpha(0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  /// Etiketi dairenin tam ortasına, daireyle birlikte büyüyecek boyutta çizer
  void _paintLabel(
    Canvas canvas,
    String label,
    Offset center,
    double radius,
    double opacity,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: Colors.white.withAlpha((255 * opacity).round()),
          fontSize: radius * 0.8,
          fontWeight: FontWeight.w800,
          shadows: const [Shadow(blurRadius: 6, color: Colors.black54)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
    textPainter.dispose();
  }

  @override
  bool shouldRepaint(FingerPainter old) =>
      old.activePointers != activePointers ||
      old.pointerColors != pointerColors ||
      old.spotlightPointerIds != spotlightPointerIds ||
      old.labels != labels ||
      old.dimOthers != dimOthers ||
      // Işın her karede yeniden üretilir; kimlik karşılaştırması dönerken
      // her kare yeniden çizdirir, ışın yokken hiç çizdirmez
      old.beam != beam ||
      old.winnerScale != winnerScale ||
      old.winnerGlow != winnerGlow ||
      old.isLocked != isLocked;
}
