import 'dart:math';

import 'package:flutter/material.dart';

import '../models/particle.dart';

/// Kazanan açıklandığında kazananın konumundan fırlayan konfeti parçacıkları.
///
/// [ValueKey] ile sarmalanarak parent yeniden build edildiğinde state korunur;
/// böylece `ListenableBuilder` rebuild etse bile animasyon sıfırlanmaz.
class ParticleOverlay extends StatefulWidget {
  /// Her kazananın ekrandaki konumu
  final List<Offset> origins;

  /// Kazananlara karşılık gelen pastel renkler
  final List<Color> colors;

  const ParticleOverlay({
    super.key,
    required this.origins,
    required this.colors,
  });

  @override
  State<ParticleOverlay> createState() => _ParticleOverlayState();
}

class _ParticleOverlayState extends State<ParticleOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late List<Particle> _particles;
  double _prevTime = 0.0;

  static const int _particlesPerOrigin = 50;
  static const Duration _totalDuration = Duration(milliseconds: 2400);

  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _particles = _generateParticles();
    _controller = AnimationController(vsync: this, duration: _totalDuration)
      ..addListener(_tick)
      ..forward();
  }

  List<Particle> _generateParticles() {
    final particles = <Particle>[];
    for (int i = 0; i < widget.origins.length; i++) {
      final origin = widget.origins[i];
      final baseColor = widget.colors[i];

      for (int j = 0; j < _particlesPerOrigin; j++) {
        final angle = _random.nextDouble() * 2 * pi;
        final speed = 60 + _random.nextDouble() * 300;

        // Tek sayı parçacıklar beyaz — karışık konfeti görünümü
        final color = j.isOdd ? baseColor : Colors.white;

        particles.add(
          Particle(
            position: origin,
            velocity: Offset(
              cos(angle) * speed,
              sin(angle) * speed - 140, // hafif yukarı yönlü
            ),
            color: color,
            radius: 2.0 + _random.nextDouble() * 5.0,
          ),
        );
      }
    }
    return particles;
  }

  void _tick() {
    // controller.value 0..1 → bunu saniyeye çevir
    final t = _controller.value * (_totalDuration.inMilliseconds / 1000.0);
    final dt = t - _prevTime;
    _prevTime = t;
    if (dt <= 0) return;

    setState(() {
      for (final p in _particles) {
        p.update(dt);
      }
      _particles.removeWhere((p) => p.isDead);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ParticlePainter(_particles),
      child: const SizedBox.expand(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// ── Canvas çizici ──────────────────────────────────────────────────────────

class _ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  _ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final p in particles) {
      paint.color = p.color.withAlpha((p.opacity * 255).round());
      canvas.drawCircle(p.position, p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => true;
}
