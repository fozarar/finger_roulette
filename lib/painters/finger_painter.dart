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
  final List<int> spotlightIds;

  /// Dairelerin ortasına yazılan etiketler (takım harfi ya da sıra numarası)
  final Map<int, String> labels;

  /// True ise öne çıkmayan daireler neredeyse tamamen solar. Sıra modunda
  /// false — herkesin numarası okunabilir kalmalı.
  final bool dimOthers;

  /// Dönüş sırasında hangi dairenin vurgulanacağını ve tik sesinin ne zaman
  /// çalacağını belirleyen geometri. Işığın kendisi çizilmiyor: ekranda dönen
  /// bir koni huzursuz duruyordu, dairelerin sırayla yanması gerilimi zaten
  /// taşıyor. Dönmüyorsa null.
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
    required this.spotlightIds,
    required this.labels,
    required this.dimOthers,
    required this.beam,
    required this.isLocked,
    required this.winnerScale,
    required this.winnerGlow,
  });

  /// Temel yarıçap — 90px çap
  static const double _baseRadius = 45.0;

  @override
  void paint(Canvas canvas, Size size) {
    final hasResult = spotlightIds.isNotEmpty;

    final beam = this.beam;

    for (final entry in activePointers.entries) {
      final pointerId = entry.key;
      final position = entry.value;
      final color = pointerColors[pointerId] ?? Colors.white;

      final isSpotlit = spotlightIds.contains(pointerId);

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
      old.spotlightIds != spotlightIds ||
      old.labels != labels ||
      old.dimOthers != dimOthers ||
      // Işın her karede yeniden üretilir; kimlik karşılaştırması dönerken
      // her kare yeniden çizdirir, ışın yokken hiç çizdirmez
      old.beam != beam ||
      old.winnerScale != winnerScale ||
      old.winnerGlow != winnerGlow ||
      old.isLocked != isLocked;
}
