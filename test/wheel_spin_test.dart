import 'dart:math';

import 'package:finger_roulette/models/wheel_spin.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('duruş', () {
    test('her dilim için tam hedefin üstünde durur', () {
      for (final count in [2, 3, 5, 8, 14, 20]) {
        for (var target = 0; target < count; target++) {
          final end = WheelSpin.of(count: count, targetIndex: target, t: 1.0);
          expect(
            end.indexUnderPointer,
            target,
            reason: '$count dilim, hedef $target',
          );
        }
      }
    });

    test('hedefin merkezine oturur, kenarına değil', () {
      const count = 6;
      final end = WheelSpin.of(count: count, targetIndex: 4, t: 1.0);
      final seg = WheelSpin.segment(count);
      // İbrenin dilim içindeki konumu: 0 = başı, 1 = sonu
      final within = ((-end.angle) % (2 * pi)) / seg - 4;
      expect(within, closeTo(0.5, 1e-9));
    });

    test('en az dört tam tur atar', () {
      final sweep = WheelSpin.sweepTo(targetIndex: 0, count: 8);
      expect(sweep, greaterThan(3 * 2 * pi));
      expect(sweep, lessThanOrEqualTo(WheelSpin.turns * 2 * pi));
    });
  });

  group('dönüş', () {
    test('başta durur, geri sarmaz', () {
      final start = WheelSpin.of(count: 7, targetIndex: 3, t: 0.0);
      expect(start.angle, 0.0);

      var previous = 0.0;
      for (var i = 1; i <= 100; i++) {
        final angle = WheelSpin.of(count: 7, targetIndex: 3, t: i / 100).angle;
        expect(angle, greaterThan(previous), reason: 't=${i / 100}');
        previous = angle;
      }
    });

    test('sona doğru yavaşlar', () {
      double step(double from, double to) =>
          WheelSpin.of(count: 7, targetIndex: 3, t: to).angle -
          WheelSpin.of(count: 7, targetIndex: 3, t: from).angle;

      expect(step(0.9, 1.0), lessThan(step(0.1, 0.2)));
    });

    test('dönerken ibrenin altındaki dilim değişir — tik sesi buradan çıkar', () {
      final seen = <int>{};
      for (var i = 0; i <= 200; i++) {
        seen.add(
          WheelSpin.of(count: 5, targetIndex: 2, t: i / 200).indexUnderPointer,
        );
      }
      expect(seen.length, 5, reason: 'dört turda her dilim ibrenin altından geçer');
    });
  });

  test('hedef yokken çark durur', () {
    final idle = WheelSpin.of(count: 6, targetIndex: null, t: 0.7);
    expect(idle.angle, 0.0);
    expect(idle.indexUnderPointer, 0);
  });
}
