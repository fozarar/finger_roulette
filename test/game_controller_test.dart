import 'dart:math';

import 'package:fake_async/fake_async.dart';
import 'package:finger_roulette/controllers/game_controller.dart';
import 'package:finger_roulette/models/game_mode.dart';
import 'package:finger_roulette/models/game_phase.dart';
import 'package:finger_roulette/models/input_source.dart';
import 'package:finger_roulette/services/names_service.dart';
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
  GameMode? lastMode;
  InputSource? lastInput;
  PickOutcome? lastOutcome;
  int? lastPlayers;
  int? lastPicks;

  @override
  Future<int> recordGameCompleted({
    required GameMode mode,
    required InputSource input,
    required int playerCount,
    PickOutcome? outcome,
    int? pickCount,
  }) async {
    completed++;
    lastMode = mode;
    lastInput = input;
    lastOutcome = outcome;
    lastPlayers = playerCount;
    lastPicks = pickCount;
    return completed;
  }

  @override
  void logEvent(String name, [Map<String, Object?> params = const {}]) {}
}

/// Diske gitmeyen isim deposu
class _FakeNames extends NamesService {
  _FakeNames([this.stored = const []]);

  List<String> stored;

  @override
  List<String> load() => stored;

  @override
  Future<void> save(List<String> names) async => stored = names;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeStats stats;
  late _FakeNames nameStore;

  GameController build({List<String> names = const []}) {
    stats = _FakeStats();
    nameStore = _FakeNames(names);
    return GameController(
      random: Random(42),
      sound: _SilentSound(),
      stats: stats,
      // init() çağrılmadığı için puan isteme sessizce atlanır
      review: ReviewService(),
      nameStore: nameStore,
    );
  }

  void down(GameController c, int id, {Offset at = const Offset(150, 400)}) =>
      c.handlePointerDown(PointerDownEvent(pointer: id, position: at));

  void up(GameController c, int id) =>
      c.handlePointerUp(PointerUpEvent(pointer: id));

  /// [fingers] parmağı koyar ve sonuç açıklanana kadar zamanı ilerletir
  void playRound(FakeAsync async, GameController c, int fingers) {
    for (var i = 1; i <= fingers; i++) {
      down(c, i, at: Offset(70.0 * i, 300));
    }
    async.elapse(const Duration(milliseconds: 2800));
  }

  group('seçim', () {
    test('2 oyuncuda kazanan seçimi atlanır ve oyun başlar', () {
      final c = build();
      c.selectPlayerCount(2);
      expect(c.phase, GamePhase.waiting);
      expect(c.selectedPlayerCount, 2);
      expect(c.selectedPickCount, 1);
      c.dispose();
    });

    test('3+ oyuncuda kazanan seçilene kadar setup fazında kalır', () {
      final c = build();
      c.selectPlayerCount(4);
      expect(c.phase, GamePhase.setup);
      c.selectPickCount(2);
      expect(c.phase, GamePhase.waiting);
      expect(c.selectedPickCount, 2);
      c.dispose();
    });

    test('oyuncu sayısı düşünce geçersiz kazanan seçimi temizlenir', () {
      final c = build();
      c.selectPlayerCount(5);
      c.selectPickCount(4);
      c.selectPlayerCount(3); // 4 kazanan artık geçersiz
      expect(c.selectedPickCount, isNull);
      c.dispose();
    });

    test('kaybeden seçilse de kaç kişi sorusu aynı şekilde sorulur', () {
      final c = build();
      c.selectOutcome(PickOutcome.losers);
      c.selectPlayerCount(4);
      expect(c.phase, GamePhase.setup);
      c.selectPickCount(1);
      expect(c.phase, GamePhase.waiting);
      c.dispose();
    });

    test('kazanan/kaybeden değişimi bekleyen oyuncu seçimini korur', () {
      final c = build();
      c.selectPlayerCount(4);
      c.selectOutcome(PickOutcome.losers);
      expect(c.outcome, PickOutcome.losers);
      expect(c.pendingPlayerCount, 4, reason: 'çekiliş değişmedi');
      expect(c.phase, GamePhase.setup);
      c.dispose();
    });

    test('takım ve sıra modları oyuncu sayısından sonra hemen başlar', () {
      for (final mode in [GameMode.teams, GameMode.order]) {
        final c = build();
        c.selectMode(mode);
        c.selectPlayerCount(4);
        expect(c.phase, GamePhase.waiting, reason: mode.name);
        expect(c.selectedPlayerCount, 4, reason: mode.name);
        expect(c.selectedPickCount, isNull, reason: mode.name);
        c.dispose();
      }
    });

    test('mod değişince yarım kalan seçim sıfırlanır', () {
      final c = build();
      c.selectPlayerCount(4);
      expect(c.pendingPlayerCount, 4);
      c.selectMode(GameMode.teams);
      expect(c.pendingPlayerCount, isNull);
      expect(c.phase, GamePhase.setup);
      c.dispose();
    });

    test('ayarları değiştirmek modu ve kazanan/kaybeden seçimini korur', () {
      final c = build();
      c.selectOutcome(PickOutcome.losers);
      c.selectPlayerCount(3);
      c.changeSettings();
      expect(c.phase, GamePhase.setup);
      expect(c.mode, GameMode.pick);
      expect(c.outcome, PickOutcome.losers);
      c.dispose();
    });
  });

  group('parmak girişi', () {
    test('sol üst köşedeki geri butonu alanı yok sayılır', () {
      final c = build();
      c.selectPlayerCount(3);
      c.selectPickCount(1);
      down(c, 1, at: const Offset(20, 20)); // geri butonu bölgesi
      expect(c.activePointers, isEmpty);
      down(c, 2, at: const Offset(200, 200));
      expect(c.activePointers.length, 1);
      c.dispose();
    });

    test('hedeften fazla parmak kabul edilmez', () {
      final c = build();
      c.selectPlayerCount(3);
      c.selectPickCount(1);
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
        c.selectPickCount(1);

        for (var i = 1; i <= 3; i++) {
          down(c, i, at: Offset(100.0 * i, 300));
        }
        expect(c.phase, GamePhase.choosing);

        async.elapse(const Duration(milliseconds: 800));
        expect(c.phase, GamePhase.locked);
        expect(c.lockedPointerIds.length, 3);

        async.elapse(const Duration(seconds: 2));
        expect(c.phase, GamePhase.revealed);
        expect(c.pickedIds.length, 1);
        expect(c.lockedPointerIds, contains(c.pickedIds.single));
        expect(c.spotlightIds, c.pickedIds);

        async.elapse(const Duration(seconds: 2));
        async.flushMicrotasks();
        expect(c.showReset, isTrue);
        expect(stats.completed, 1);
        expect(stats.lastMode, GameMode.pick);
        expect(stats.lastOutcome, PickOutcome.winners);
        expect(stats.lastPlayers, 3);
        expect(stats.lastPicks, 1);

        c.dispose();
      });
    });

    test('çok kazananlı oyunda doğru sayıda kazanan seçilir', () {
      fakeAsync((async) {
        final c = build();
        c.selectPlayerCount(4);
        c.selectPickCount(2);

        for (var i = 1; i <= 4; i++) {
          down(c, i, at: Offset(80.0 * i, 300));
        }
        async.elapse(const Duration(milliseconds: 2800));

        expect(c.phase, GamePhase.revealed);
        expect(c.pickedIds.length, 2);
        expect(c.pickedIds.toSet().length, 2, reason: 'kazananlar tekil');
        for (final w in c.pickedIds) {
          expect(c.lockedPointerIds, contains(w));
        }

        c.dispose();
      });
    });

    test('kilitlenmeden önce parmaklar çekilirse oyun sıfırlanır', () {
      fakeAsync((async) {
        final c = build();
        c.selectPlayerCount(3);
        c.selectPickCount(1);

        for (var i = 1; i <= 3; i++) {
          down(c, i, at: Offset(100.0 * i, 300));
        }
        up(c, 2);
        up(c, 3); // geriye 1 parmak kaldı

        async.elapse(const Duration(milliseconds: 800));
        expect(c.phase, GamePhase.waiting);
        expect(c.pickedIds, isEmpty);
        expect(stats.completed, 0);

        c.dispose();
      });
    });

    test('kilitlendikten sonra parmak kaldırmak kazananı değiştirmez', () {
      fakeAsync((async) {
        final c = build();
        c.selectPlayerCount(3);
        c.selectPickCount(1);

        for (var i = 1; i <= 3; i++) {
          down(c, i, at: Offset(100.0 * i, 300));
        }
        async.elapse(const Duration(milliseconds: 800));
        expect(c.phase, GamePhase.locked);

        up(c, 1); // kilitliyken kaldırılan parmak ekranda kalmalı
        expect(c.activePointers.containsKey(1), isTrue);
        expect(c.lockedPointerIds.length, 3);

        async.elapse(const Duration(seconds: 2));
        expect(c.pickedIds.length, 1);

        c.dispose();
      });
    });

    test('changeSettings her şeyi sıfırlar', () {
      fakeAsync((async) {
        final c = build();
        c.selectPlayerCount(3);
        c.selectPickCount(1);
        for (var i = 1; i <= 3; i++) {
          down(c, i, at: Offset(100.0 * i, 300));
        }
        async.elapse(const Duration(seconds: 5));
        async.flushMicrotasks();

        c.changeSettings();
        expect(c.phase, GamePhase.setup);
        expect(c.selectedPlayerCount, isNull);
        expect(c.selectedPickCount, isNull);
        expect(c.activePointers, isEmpty);
        expect(c.pickedIds, isEmpty);
        expect(c.showReset, isFalse);

        c.dispose();
      });
    });
  });

  group('modlar', () {
    test('kaybeden seçilince daire kırmızıya döner', () {
      fakeAsync((async) {
        final c = build();
        c.selectOutcome(PickOutcome.losers);
        c.selectPlayerCount(3);
        c.selectPickCount(1);
        playRound(async, c, 3);

        expect(c.phase, GamePhase.revealed);
        final loser = c.pickedIds.single;
        expect(c.pointerColors[loser], GameController.loserColor);
        expect(c.spotlightIds, [loser]);

        async.elapse(const Duration(seconds: 2));
        async.flushMicrotasks();
        expect(stats.lastMode, GameMode.pick);
        expect(stats.lastOutcome, PickOutcome.losers);
        expect(stats.lastPicks, 1);

        c.dispose();
      });
    });

    test('takım modunda herkes dengeli iki takıma dağılır', () {
      fakeAsync((async) {
        for (final players in GameMode.teams.playerCounts) {
          final c = build();
          c.selectMode(GameMode.teams);
          c.selectPlayerCount(players);
          playRound(async, c, players);

          expect(c.phase, GamePhase.revealed, reason: '$players oyuncu');
          expect(c.teamOfId.keys.toSet(), c.lockedPointerIds.toSet());

          final sizes = List.filled(GameController.teamCount, 0);
          for (final team in c.teamOfId.values) {
            sizes[team]++;
          }
          expect(
            sizes.reduce(max) - sizes.reduce(min),
            lessThanOrEqualTo(1),
            reason: '$players oyuncu: takımlar $sizes',
          );

          for (final MapEntry(key: id, value: team)
              in c.teamOfId.entries) {
            expect(c.pointerColors[id], GameController.teamColors[team]);
          }
          // Takım modunda kimse seçilmez, herkes öne çıkar
          expect(c.pickedIds, isEmpty);
          expect(c.spotlightIds.toSet(), c.lockedPointerIds.toSet());

          c.dispose();
        }
      });
    });

    test('sıra modunda her parmak tekil bir sıra alır', () {
      fakeAsync((async) {
        final c = build();
        c.selectMode(GameMode.order);
        c.selectPlayerCount(4);
        playRound(async, c, 4);

        expect(c.phase, GamePhase.revealed);
        expect(c.rankedIds.length, 4);
        expect(c.rankedIds.toSet(), c.lockedPointerIds.toSet());
        // Yalnızca birinci öne çıkar
        expect(c.spotlightIds, [c.rankedIds.first]);

        async.elapse(const Duration(seconds: 2));
        async.flushMicrotasks();
        expect(stats.lastMode, GameMode.order);
        expect(stats.lastOutcome, isNull);
        expect(stats.lastPicks, isNull);

        c.dispose();
      });
    });

    test('ışının hedefi kilitlenince belli olur, sonuçla aynı çıkar', () {
      fakeAsync((async) {
        final c = build();
        c.selectPlayerCount(3);
        c.selectPickCount(1);
        for (var i = 1; i <= 3; i++) {
          down(c, i, at: Offset(100.0 * i, 300));
        }

        async.elapse(const Duration(milliseconds: 800));
        // Işın dönmeye başlamadan hedefi bilinmeli — nereye ineceği baştan
        // belli olmalı — ama sonuç henüz açıklanmamış olmalı
        expect(c.phase, GamePhase.locked);
        expect(c.lockedPointerIds, contains(c.spinTargetId));
        expect(c.pickedIds, isEmpty);
        expect(c.spotlightIds, isEmpty);

        final target = c.spinTargetId;
        async.elapse(GameController.spinDuration);
        expect(c.pickedIds.single, target);

        c.dispose();
      });
    });

    test('sıra modunda ışın birinciye, takım modunda kimseye inmez', () {
      fakeAsync((async) {
        final order = build();
        order.selectMode(GameMode.order);
        order.selectPlayerCount(4);
        playRound(async, order, 4);
        expect(order.spinTargetId, order.rankedIds.first);
        order.dispose();

        final teams = build();
        teams.selectMode(GameMode.teams);
        teams.selectPlayerCount(4);
        // Takım modunda kimse öne çıkmaz; ışın kimseyi göstermeden durur
        playRound(async, teams, 4);
        expect(teams.spinTargetId, isNull);
        teams.dispose();
      });
    });

    test('tur sıfırlanınca ışın hedefi de temizlenir', () {
      fakeAsync((async) {
        final c = build();
        c.selectPlayerCount(3);
        c.selectPickCount(1);
        playRound(async, c, 3);
        expect(c.spinTargetId, isNotNull);

        c.resetGame();
        expect(c.spinTargetId, isNull);

        c.dispose();
      });
    });

    test('tekrar oynamak önceki sonucu temizler, modu korur', () {
      fakeAsync((async) {
        final c = build();
        c.selectMode(GameMode.teams);
        c.selectPlayerCount(4);
        playRound(async, c, 4);
        expect(c.teamOfId, isNotEmpty);

        c.resetGame();
        expect(c.phase, GamePhase.waiting);
        expect(c.teamOfId, isEmpty);
        expect(c.spotlightIds, isEmpty);
        expect(c.pointerColors, isEmpty);
        expect(c.mode, GameMode.teams);

        c.dispose();
      });
    });
  });

  group('isim akışı', () {
    test('saklanan liste açılışta yüklenir', () {
      final c = build(names: ['Ali', 'Veli']);
      expect(c.names, ['Ali', 'Veli']);
      expect(c.input, InputSource.fingers, reason: 'varsayılan parmak');
      c.dispose();
    });

    test('liste güncellenince diske yazılır ve üst sınırda kesilir', () {
      final c = build();
      c.setNames(['Ali', 'Veli', 'Ayşe']);
      expect(nameStore.stored, ['Ali', 'Veli', 'Ayşe']);

      final tooMany = List.generate(NamesService.maxNames + 5, (i) => 'Kişi $i');
      c.setNames(tooMany);
      expect(c.names.length, NamesService.maxNames);
      c.dispose();
    });

    test('isimlerle tur: çark dönerken sonuç saklı, süre dolunca açıklanır', () {
      fakeAsync((async) {
        final c = build(names: ['Ali', 'Veli', 'Ayşe', 'Fatma']);
        c.selectInput(InputSource.names);
        c.selectPlayerCount(c.names.length);
        c.selectPickCount(1);
        expect(c.phase, GamePhase.waiting);

        c.startNameRound();
        expect(c.phase, GamePhase.locked);
        expect(c.participantIds, [0, 1, 2, 3]);
        expect(c.spinTargetId, isNotNull, reason: 'çark hedefi dönüşten önce belli');
        expect(c.pickedIds, isEmpty, reason: 'sonuç dönüş bitmeden açıklanmaz');

        async.elapse(GameController.spinDuration);
        expect(c.phase, GamePhase.revealed);
        expect(c.pickedIds.single, c.spinTargetId);
        expect(c.pickedIds.single, inInclusiveRange(0, 3));
        // Çark kendi rengini seçer; parmak renkleri boş kalmalı
        expect(c.pointerColors, isEmpty);

        async.elapse(const Duration(seconds: 2));
        async.flushMicrotasks();
        expect(stats.lastInput, InputSource.names);
        expect(stats.lastPlayers, 4);

        c.dispose();
      });
    });

    test('iki isimden az olunca tur başlamaz', () {
      final c = build(names: ['Ali']);
      c.selectInput(InputSource.names);
      c.phase = GamePhase.waiting;
      c.startNameRound();
      expect(c.phase, GamePhase.waiting);
      c.dispose();
    });

    test('girdi değişince yarım kalan seçim sıfırlanır', () {
      final c = build(names: ['Ali', 'Veli', 'Ayşe']);
      c.selectPlayerCount(4);
      c.selectInput(InputSource.names);
      expect(c.pendingPlayerCount, isNull);
      expect(c.input, InputSource.names);
      c.dispose();
    });
  });
}
