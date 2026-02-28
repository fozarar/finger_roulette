import 'dart:ui';

/// Confetti parçacığı — pozisyon, hız, renk ve opaklık bilgisini taşır.
/// Her frame'de [update] çağrılarak fizik simülasyonu yapılır.
class Particle {
  Offset position;
  Offset velocity; // pixels / saniye

  final Color color;
  final double radius;
  double opacity;

  Particle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.radius,
    this.opacity = 1.0,
  });

  /// [dt]: son güncellemeden bu yana geçen süre (saniye cinsinden)
  void update(double dt) {
    // Yerçekimi ivmesi
    velocity = Offset(velocity.dx, velocity.dy + 520 * dt);
    position = position + velocity * dt;
    // Zamanla solar
    opacity = (opacity - dt * 0.85).clamp(0.0, 1.0);
  }

  bool get isDead => opacity <= 0;
}
