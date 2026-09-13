import 'package:finger_roulette/models/spin_curve.dart';
import 'package:flutter_test/flutter_test.dart';

/// Işın ve çark aynı eğriyi kullanır; eğri bozulursa ikisi birden bozulur.
void main() {
  test('başta 0, sonda tam 1', () {
    expect(spinFraction(0), 0.0);
    expect(spinFraction(1), closeTo(1.0, 1e-12));
  });

  test('geri sarmaz — her adımda artar', () {
    var previous = -1.0;
    for (var i = 0; i <= 100; i++) {
      final value = spinFraction(i / 100);
      expect(value, greaterThan(previous));
      previous = value;
    }
  });

  test('ilk %75 sabit hızda döner', () {
    final quarter = spinFraction(0.25);
    expect(spinFraction(0.50), closeTo(quarter * 2, 1e-12));
    expect(spinFraction(0.75), closeTo(quarter * 3, 1e-12));
  });

  test('son çeyrekte yavaşlar', () {
    final fastPhase =
        spinFraction(0.5) - spinFraction(0.4);
    final endPhase =
        spinFraction(1.0) - spinFraction(0.9);
    expect(endPhase, lessThan(fastPhase));
  });

  test('sınırların dışı kırpılır', () {
    expect(spinFraction(-1), 0.0);
    expect(spinFraction(2), closeTo(1.0, 1e-12));
  });
}
