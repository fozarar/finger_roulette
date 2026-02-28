import 'package:flutter/material.dart';

/// Ekrandaki parmak dairelerini canvas üzerine çizen [CustomPainter].
///
/// Her parmak için pastel dolgu, beyaz kenarlık, glow ve döngü vurgu
/// efektlerini işler. Kazanan/kaybeden görsel durumunu da yönetir.
class FingerPainter extends CustomPainter {
  final Map<int, Offset> activePointers;
  final Map<int, Color> pointerColors;
  final List<int> lockedPointerIds;

  /// Kazanan pointer ID'lerinin listesi (birden fazla olabilir)
  final List<int> winnerPointerIds;

  final int highlightIndex;

  /// True iken pointer listesi kilitlenmiş demektir (choosing veya revealed)
  final bool isLocked;

  /// Kazanan scale animasyonunun anlık değeri (1.0 → 1.3)
  final double winnerScale;

  /// Kazanan glow animasyonunun anlık değeri (0.35 → 1.0)
  final double winnerGlow;

  const FingerPainter({
    required this.activePointers,
    required this.pointerColors,
    required this.lockedPointerIds,
    required this.winnerPointerIds,
    required this.highlightIndex,
    required this.isLocked,
    required this.winnerScale,
    required this.winnerGlow,
  });

  /// Temel yarıçap — 90px çap
  static const double _baseRadius = 45.0;

  @override
  void paint(Canvas canvas, Size size) {
    final hasWinner = winnerPointerIds.isNotEmpty;

    for (final entry in activePointers.entries) {
      final pointerId = entry.key;
      final position = entry.value;
      final color = pointerColors[pointerId] ?? Colors.white;

      final isWinner = winnerPointerIds.contains(pointerId);

      // "Choosing..." döngüsünde şu an vurgulanan daire mi?
      final isCycleHighlight = isLocked &&
          !hasWinner &&
          lockedPointerIds.isNotEmpty &&
          lockedPointerIds[highlightIndex % lockedPointerIds.length] ==
              pointerId;

      // ── Görsel durum hesapla ──────────────────────────────────────────────
      double opacity;
      double scale;

      if (hasWinner) {
        // Kazananlar büyür ve parlak kalır; diğerleri solar
        opacity = isWinner ? 1.0 : 0.15;
        scale = isWinner ? winnerScale : 1.0;
      } else if (isLocked) {
        // Döngülü vurgulama animasyonu
        opacity = isCycleHighlight ? 1.0 : 0.40;
        scale = isCycleHighlight ? 1.15 : 1.0;
      } else {
        opacity = 1.0;
        scale = 1.0;
      }

      final currentRadius = _baseRadius * scale;

      // ── Kazanan için nabız gibi yayılan glow halkası ──────────────────────
      if (isWinner && hasWinner) {
        final glowPaint = Paint()
          ..color = color.withAlpha((255 * 0.55 * winnerGlow).round())
          ..maskFilter =
              MaskFilter.blur(BlurStyle.normal, 28.0 * winnerGlow);
        canvas.drawCircle(position, currentRadius * 1.7, glowPaint);
      }

      // ── Döngü vurgusu için yumuşak aydınlık halka ────────────────────────
      if (isCycleHighlight) {
        final cyclePaint = Paint()
          ..color = Colors.white.withAlpha(60)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14.0);
        canvas.drawCircle(position, currentRadius * 1.35, cyclePaint);
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
        ..strokeWidth = isWinner ? 3.5 : 2.0;
      canvas.drawCircle(position, currentRadius, borderPaint);
    }
  }

  @override
  bool shouldRepaint(FingerPainter old) =>
      old.activePointers != activePointers ||
      old.winnerPointerIds != winnerPointerIds ||
      old.highlightIndex != highlightIndex ||
      old.winnerScale != winnerScale ||
      old.winnerGlow != winnerGlow ||
      old.isLocked != isLocked;
}
