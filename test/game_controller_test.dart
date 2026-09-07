import 'dart:math';

import 'package:fake_async/fake_async.dart';
import 'package:finger_roulette/controllers/game_controller.dart';
import 'package:finger_roulette/models/game_phase.dart';
import 'package:finger_roulette/services/review_service.dart';
import 'package:finger_roulette/services/sound_service.dart';
import 'package:finger_roulette/services/stats_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';

/// Platform kanalına dokunmayan ses servisi
class _SilentSound extends SoundService {
  @override
  Future<void> playTick() async {}
  @override
  Future<void> playWin() async {}
  @override
  Future<void> dispose() async {}
}

/// SharedPreferences'e gitmeyen sayaç servisi
class _FakeStats extends StatsService {
  int completed = 0;
  int? lastPlayers;
  int? lastWinners;

  @override
  Future<int> recordGameCompleted({
    required int playerCount,
    required int winnerCount,
  }) async {
    completed++;
    lastPlayers = playerCount;
    lastWinners = winnerCount;
    return completed;
  }

  @override
  void logEvent(String name, [Map<String, Object?> params = const {}]) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeStats stats;

  GameController build() {
    stats = _FakeStats();
    return GameController(
      random: Random(42),
      sound: _SilentSound(),
      stats: stats,
      // init() çağrılmadığı için puan isteme sessizce atlanır
      review: ReviewService(),
    );
  }

  void down(GameController c, int id, {Offset at = const Offset(150, 400)}) =>
      c.handlePointerDown(PointerDownEvent(pointer: id, position: at));

  void up(GameController c, int id) =>
      c.handlePointerUp(PointerUpEvent(pointer: id));

  group('seçim', () {
    test('2 oyuncuda kazanan seçimi atlanır ve oyun başlar', () {
      final c = build();
      c.selectPlayerCount(2);
      expect(c.phase, GamePhase.waiting);
      expect(c.selectedPlayerCount, 2);
      expect(c.selectedWinnerCount, 1);
      c.dispose();
    });

    test('3+ oyuncuda kazanan seçilene kadar setup fazında kalır', () {
      final c = build();
      c.selectPlayerCount(4);
      expect(c.phase, GamePhase.setup);
      c.selectWinnerCount(2);
      expect(c.phase, GamePhase.waiting);
      expect(c.selectedWinnerCount, 2);
      c.dispose();
    });

    test('oyuncu sayısı düşünce geçersiz kazanan seçimi temizlenir', () {
      final c = build();
      c.selectPlayerCount(5);
      c.selectWinnerCount(4);
      c.selectPlayerCount(3); // 4 kazanan artık geçersiz
      expect(c.selectedWinnerCount, isNull);
      c.dispose();
    });
  });

  group('parmak girişi', () {
    test('sol üst köşedeki geri butonu alanı yok sayılır', () {
      final c = build();
      c.selectPlayerCount(3);
      c.selectWinnerCount(1);
      down(c, 1, at: const Offset(20, 20)); // geri butonu bölgesi
      expect(c.activePointers, isEmpty);
      down(c, 2, at: const Offset(200, 200));
      expect(c.activePointers.length, 1);
      c.dispose();
    });

    test('hedeften fazla parmak kabul edilmez', () {
      final c = build();
      c.selectPlayerCount(3);
      c.selectWinnerCount(1);
      for (var i = 1; i <= 5; i++) {
        down(c, i, at: Offset(100.0 * i, 300));
      }
      expect(c.activePointers.length, 3);
      c.dispose();
    });
  });

  group('oyun akışı', () {
    test('3 parmak → kazanan açıklanır ve sayaç artar', () {
      fakeAsync((async) {
        final c = build();
        c.selectPlayerCount(3);
        c.selectWinnerCount(1);

        for (var i = 1; i <= 3; i++) {
          down(c, i, at: Offset(100.0 * i, 300));
        }
        expect(c.phase, GamePhase.choosing);

        async.elapse(const Duration(milliseconds: 800));
        expect(c.phase, GamePhase.locked);
        expect(c.lockedPointerIds.length, 3);

        async.elapse(const Duration(seconds: 2));
        expect(c.phase, GamePhase.revealed);
        expect(c.winnerPointerIds.length, 1);
        expect(c.lockedPointerIds, contains(c.winnerPointerIds.single));

        async.elapse(const Duration(seconds: 2));
        async.flushMicrotasks();
        expect(c.showReset, isTrue);
        expect(stats.completed, 1);
        expect(stats.lastPlayers, 3);
        expect(stats.lastWinners, 1);

        c.dispose();
      });
    });

    test('çok kazananlı oyunda doğru sayıda kazanan seçilir', () {
      fakeAsync((async) {
        final c = build();
        c.selectPlayerCount(4);
        c.selectWinnerCount(2);

        for (var i = 1; i <= 4; i++) {
          down(c, i, at: Offset(80.0 * i, 300));
        }
        async.elapse(const Duration(milliseconds: 2800));

        expect(c.phase, GamePhase.revealed);
        expect(c.winnerPointerIds.length, 2);
        expect(c.winnerPointerIds.toSet().length, 2, reason: 'kazananlar tekil');
        for (final w in c.winnerPointerIds) {
          expect(c.lockedPointerIds, contains(w));
        }

        c.dispose();
      });
    });

    test('kilitlenmeden önce parmaklar çekilirse oyun sıfırlanır', () {
      fakeAsync((async) {
        final c = build();
        c.selectPlayerCount(3);
        c.selectWinnerCount(1);

        for (var i = 1; i <= 3; i++) {
          down(c, i, at: Offset(100.0 * i, 300));
        }
        up(c, 2);
        up(c, 3); // geriye 1 parmak kaldı

        async.elapse(const Duration(milliseconds: 800));
        expect(c.phase, GamePhase.waiting);
        expect(c.winnerPointerIds, isEmpty);
        expect(stats.completed, 0);

        c.dispose();
      });
    });

    test('kilitlendikten sonra parmak kaldırmak kazananı değiştirmez', () {
      fakeAsync((async) {
        final c = build();
        c.selectPlayerCount(3);
        c.selectWinnerCount(1);

        for (var i = 1; i <= 3; i++) {
          down(c, i, at: Offset(100.0 * i, 300));
        }
        async.elapse(const Duration(milliseconds: 800));
        expect(c.phase, GamePhase.locked);

        up(c, 1); // kilitliyken kaldırılan parmak ekranda kalmalı
        expect(c.activePointers.containsKey(1), isTrue);
        expect(c.lockedPointerIds.length, 3);

        async.elapse(const Duration(seconds: 2));
        expect(c.winnerPointerIds.length, 1);

        c.dispose();
      });
    });

    test('changeSettings her şeyi sıfırlar', () {
      fakeAsync((async) {
        final c = build();
        c.selectPlayerCount(3);
        c.selectWinnerCount(1);
        for (var i = 1; i <= 3; i++) {
          down(c, i, at: Offset(100.0 * i, 300));
        }
        async.elapse(const Duration(seconds: 5));
        async.flushMicrotasks();

        c.changeSettings();
        expect(c.phase, GamePhase.setup);
        expect(c.selectedPlayerCount, isNull);
        expect(c.selectedWinnerCount, isNull);
        expect(c.activePointers, isEmpty);
        expect(c.winnerPointerIds, isEmpty);
        expect(c.showReset, isFalse);

        c.dispose();
      });
    });
  });
}
