import 'dart:math';

import 'package:finger_roulette/models/spin_beam.dart';
import 'package:flutter_test/flutter_test.dart';

/// Üç parmağı merkezin etrafına eşit aralıklarla yerleştirir
Map<int, Offset> ring(int count, {Offset center = const Offset(200, 400)}) => {
      for (var i = 0; i < count; i++)
        i + 1: center +
            Offset(
              150 * cos(2 * pi * i / count),
              150 * sin(2 * pi * i / count),
            ),
    };

/// İki açı arasındaki en kısa mesafe — test tarafında bağımsız hesaplanır
double angleGap(double a, double b) {
  final gap = (a - b).abs() % (2 * pi);
  return gap > pi ? 2 * pi - gap : gap;
}

void main() {
  group('dönüş eğrisi', () {
    test('başta 0, sonda tam 1', () {
      expect(SpinBeam.rotationFraction(0), 0.0);
      expect(SpinBeam.rotationFraction(1), closeTo(1.0, 1e-12));
    });

    test('geri sarmaz — her adımda artar', () {
      var previous = -1.0;
      for (var i = 0; i <= 100; i++) {
        final value = SpinBeam.rotationFraction(i / 100);
        expect(value, greaterThan(previous));
        previous = value;
      }
    });

    test('ilk %75 sabit hızda döner', () {
      final quarter = SpinBeam.rotationFraction(0.25);
      expect(SpinBeam.rotationFraction(0.50), closeTo(quarter * 2, 1e-12));
      expect(SpinBeam.rotationFraction(0.75), closeTo(quarter * 3, 1e-12));
    });

    test('son çeyrekte yavaşlar', () {
      final fastPhase =
          SpinBeam.rotationFraction(0.5) - SpinBeam.rotationFraction(0.4);
      final endPhase =
          SpinBeam.rotationFraction(1.0) - SpinBeam.rotationFraction(0.9);
      expect(endPhase, lessThan(fastPhase));
    });

    test('sınırların dışı kırpılır', () {
      expect(SpinBeam.rotationFraction(-1), 0.0);
      expect(SpinBeam.rotationFraction(2), closeTo(1.0, 1e-12));
    });
  });

  group('geometri', () {
    test('ışın hedefin tam üstünde durur', () {
      final positions = ring(5);
      for (final target in positions.keys) {
        final beam = SpinBeam.of(
          lockedPointerIds: positions.keys.toList(),
          positions: positions,
          targetPointerId: target,
          t: 1.0,
        )!;

        final targetAngle = atan2(
          positions[target]!.dy - beam.center.dy,
          positions[target]!.dx - beam.center.dx,
        );
        expect(angleGap(beam.angle, targetAngle), closeTo(0, 1e-9));
        expect(
          positions.keys.toList()[beam.highlightIndex],
          target,
          reason: 'vurgulanan parmak hedefin kendisi olmalı',
        );
      }
    });

    test('hedefsiz modda (takım) ışın başladığı yerde durur', () {
      final positions = ring(4);
      final beam = SpinBeam.of(
        lockedPointerIds: positions.keys.toList(),
        positions: positions,
        targetPointerId: null,
        t: 1.0,
      )!;
      expect(angleGap(beam.angle, -pi / 2), closeTo(0, 1e-9));
    });

    test('merkez parmakların ağırlık merkezidir', () {
      final positions = {1: const Offset(100, 200), 2: const Offset(300, 400)};
      final beam = SpinBeam.of(
        lockedPointerIds: [1, 2],
        positions: positions,
        targetPointerId: 1,
        t: 0.0,
      )!;
      expect(beam.center, const Offset(200, 300));
    });

    test('ışın en uzak parmağı geçecek kadar uzun', () {
      final positions = ring(3);
      final beam = SpinBeam.of(
        lockedPointerIds: positions.keys.toList(),
        positions: positions,
        targetPointerId: 1,
        t: 0.5,
      )!;
      expect(beam.reach, greaterThan(150));
    });

    test('tek parmak ya da eksik konum varsa ışın çizilmez', () {
      expect(
        SpinBeam.of(
          lockedPointerIds: [1],
          positions: {1: const Offset(100, 100)},
          targetPointerId: 1,
          t: 0.5,
        ),
        isNull,
      );
      expect(
        SpinBeam.of(
          lockedPointerIds: [1, 2],
          positions: {1: const Offset(100, 100)},
          targetPointerId: 1,
          t: 0.5,
        ),
        isNull,
      );
    });

    test('dönüş boyunca her parmağın üstünden birden çok kez geçer', () {
      final positions = ring(3);
      final ids = positions.keys.toList();
      final passes = <int, int>{for (final id in ids) id: 0};

      // 60fps'te 2 saniye — uygulamadaki kare sayısının aynısı
      int? previous;
      for (var frame = 0; frame <= 120; frame++) {
        final beam = SpinBeam.of(
          lockedPointerIds: ids,
          positions: positions,
          targetPointerId: ids.first,
          t: frame / 120,
        )!;
        if (beam.highlightIndex != previous) {
          passes[ids[beam.highlightIndex]] = passes[ids[beam.highlightIndex]]! + 1;
          previous = beam.highlightIndex;
        }
      }

      // 3 tur × 3 parmak — her parmak en az üç kez vurgulanmalı, yoksa
      // tik sesleri seyrekleşir ve rulet hissi kaybolur
      for (final id in ids) {
        expect(passes[id], greaterThanOrEqualTo(3), reason: 'parmak $id');
      }
    });
  });
}
