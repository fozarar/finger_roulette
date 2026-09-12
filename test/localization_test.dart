import 'dart:math';

import 'package:finger_roulette/controllers/game_controller.dart';
import 'package:finger_roulette/l10n/app_localizations.dart';
import 'package:finger_roulette/l10n/app_localizations_en.dart';
import 'package:finger_roulette/l10n/app_localizations_ru.dart';
import 'package:finger_roulette/l10n/app_localizations_tr.dart';
import 'package:finger_roulette/models/game_mode.dart';
import 'package:finger_roulette/models/game_phase.dart';
import 'package:finger_roulette/screens/game_text.dart';
import 'package:finger_roulette/services/sound_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _SilentSound extends SoundService {
  @override
  Future<void> playTick() async {}
  @override
  Future<void> playWin() async {}
  @override
  Future<void> dispose() async {}
}

GameController controllerIn({
  required GamePhase phase,
  GameMode mode = GameMode.pick,
  PickOutcome outcome = PickOutcome.winners,
  int players = 3,
  int? picks = 1,
  int fingersDown = 0,
  List<int> pickedIds = const [],
}) {
  final c = GameController(random: Random(1), sound: _SilentSound())
    ..mode = mode
    ..outcome = outcome
    ..selectedPlayerCount = players
    ..selectedPickCount = picks
    ..phase = phase
    ..pickedPointerIds = List.of(pickedIds);
  for (var i = 0; i < fingersDown; i++) {
    c.activePointers[i] = Offset(100.0 * i, 200);
  }
  return c;
}

void main() {
  group('durum metni (en)', () {
    final l10n = AppLocalizationsEn();

    test('parmak yokken hedef sayı gösterilir', () {
      final c = controllerIn(phase: GamePhase.waiting, players: 4);
      expect(statusTextFor(l10n, c), 'Put 4 fingers');
    });

    test('tekil/çoğul doğru seçilir', () {
      final one = controllerIn(
        phase: GamePhase.waiting,
        players: 4,
        fingersDown: 3,
      );
      expect(statusTextFor(l10n, one), '1 more finger...');

      final many = controllerIn(
        phase: GamePhase.waiting,
        players: 4,
        fingersDown: 2,
      );
      expect(statusTextFor(l10n, many), '2 more fingers...');
    });

    test('hedefe ulaşınca hazır ol yazar', () {
      final c = controllerIn(
        phase: GamePhase.waiting,
        players: 3,
        fingersDown: 3,
      );
      expect(statusTextFor(l10n, c), 'Get ready...');
    });

    test('kazanan sayısına göre banner değişir', () {
      final single = controllerIn(
        phase: GamePhase.revealed,
        picks: 1,
        pickedIds: [1],
      );
      expect(statusTextFor(l10n, single), 'Winner!');

      final multi = controllerIn(
        phase: GamePhase.revealed,
        picks: 2,
        pickedIds: [1, 2],
      );
      expect(statusTextFor(l10n, multi), 'Winners!');
    });

    test('bilgi etiketi oyuncu ve kazanan sayısını içerir', () {
      final c = controllerIn(phase: GamePhase.waiting, players: 5, picks: 2);
      expect(gameInfoLabelFor(l10n, c), '5 players · 2 winners');
    });

    test('kaybeden seçiliyken banner ve bilgi etiketi değişir', () {
      final c = controllerIn(
        phase: GamePhase.revealed,
        outcome: PickOutcome.losers,
        players: 4,
        picks: 1,
        pickedIds: [2],
      );
      expect(statusTextFor(l10n, c), 'Loser!');
      expect(gameInfoLabelFor(l10n, c), '4 players · 1 loser');
    });

    test('takım ve sıra modlarının kendi metinleri var', () {
      final teams = controllerIn(
        phase: GamePhase.revealed,
        mode: GameMode.teams,
        players: 4,
        picks: null,
      );
      expect(statusTextFor(l10n, teams), 'Teams are set!');
      expect(gameInfoLabelFor(l10n, teams), '4 players · 2 teams');

      final order = controllerIn(
        phase: GamePhase.revealed,
        mode: GameMode.order,
        players: 5,
        picks: null,
      );
      expect(statusTextFor(l10n, order), 'Here’s the order!');
      expect(gameInfoLabelFor(l10n, order), '5 players · turn order');
    });

    test('ikinci soru kazanan/kaybeden seçimine göre değişir', () {
      expect(
        pickCountQuestionFor(l10n, PickOutcome.winners),
        'How many winners?',
      );
      expect(
        pickCountQuestionFor(l10n, PickOutcome.losers),
        'How many losers?',
      );
    });

    test('mod ve düğme adları', () {
      expect(modeLabelFor(l10n, GameMode.pick), 'Pick');
      expect(modeLabelFor(l10n, GameMode.teams), 'Teams');
      expect(modeLabelFor(l10n, GameMode.order), 'Order');
      expect(outcomeLabelFor(l10n, PickOutcome.winners), 'Winner');
      expect(outcomeLabelFor(l10n, PickOutcome.losers), 'Loser');
    });
  });

  group('durum metni (tr)', () {
    final l10n = AppLocalizationsTr();

    test('Türkçe metinler kullanılır', () {
      final waiting = controllerIn(phase: GamePhase.waiting, players: 4);
      expect(statusTextFor(l10n, waiting), '4 parmak koyun');

      final choosing = controllerIn(phase: GamePhase.locked);
      expect(statusTextFor(l10n, choosing), 'Seçiliyor...');

      final revealed = controllerIn(
        phase: GamePhase.revealed,
        picks: 2,
        pickedIds: [1, 2],
      );
      expect(statusTextFor(l10n, revealed), 'Kazananlar!');
    });

    test('mod metinleri Türkçe', () {
      final teams = controllerIn(
        phase: GamePhase.revealed,
        mode: GameMode.teams,
        players: 4,
        picks: null,
      );
      expect(statusTextFor(l10n, teams), 'Takımlar hazır!');
      expect(gameInfoLabelFor(l10n, teams), '4 oyuncu · 2 takım');

      final losers = controllerIn(
        phase: GamePhase.revealed,
        outcome: PickOutcome.losers,
        picks: 2,
        pickedIds: [1, 2],
      );
      expect(statusTextFor(l10n, losers), 'Kaybedenler!');

      expect(modeLabelFor(l10n, GameMode.pick), 'Seç');
      expect(modeLabelFor(l10n, GameMode.order), 'Sıra');
      expect(outcomeLabelFor(l10n, PickOutcome.losers), 'Kaybeden');
    });
  });

  group('daire etiketleri', () {
    test('takım modunda harf, sıra modunda numara yazar', () {
      final teams = controllerIn(
        phase: GamePhase.revealed,
        mode: GameMode.teams,
      )..teamOfPointer = {7: 0, 8: 1, 9: 0};
      expect(resultLabelsFor(teams), {7: 'A', 8: 'B', 9: 'A'});

      final order = controllerIn(
        phase: GamePhase.revealed,
        mode: GameMode.order,
      )..rankedPointerIds = [9, 7, 8];
      expect(resultLabelsFor(order), {9: '1', 7: '2', 8: '3'});

      final picked = controllerIn(phase: GamePhase.revealed, pickedIds: [7]);
      expect(resultLabelsFor(picked), isEmpty);
    });
  });

  test('Rusça oyuncu sayısı 2-4 için "игрока" çekimini kullanır', () {
    final l10n = AppLocalizationsRu();
    expect(l10n.gameInfo(4, 1), '4 игрока · 1 победитель');
    expect(l10n.gameInfo(5, 2), '5 игроков · 2 победителя');
    expect(l10n.gameInfoTeams(4, 2), '4 игрока · 2 команды');
  });

  test('desteklenen 16 dilin hepsi eksiksiz yüklenir', () async {
    expect(AppLocalizations.supportedLocales.length, 16);

    for (final locale in AppLocalizations.supportedLocales) {
      final l10n = await AppLocalizations.delegate.load(locale);
      final tag = locale.toLanguageTag();

      // Her metin dolu olmalı — eksik çeviri boş string döndürür
      for (final value in <String>[
        l10n.howManyPlayers,
        l10n.howManyWinners,
        l10n.howManyLosers,
        l10n.getReady,
        l10n.choosing,
        l10n.playAgain,
        l10n.changeSettings,
        l10n.modePick,
        l10n.modeWinners,
        l10n.modeLosers,
        l10n.modeTeams,
        l10n.modeOrder,
        l10n.putFingers(3),
        l10n.moreFingers(1),
        l10n.moreFingers(2),
        l10n.winnerBanner(1),
        l10n.winnerBanner(2),
        l10n.loserBanner(1),
        l10n.loserBanner(2),
        l10n.teamsBanner,
        l10n.orderBanner,
        l10n.gameInfo(4, 2),
        l10n.gameInfoLosers(4, 2),
        l10n.gameInfoTeams(4, 2),
        l10n.gameInfoOrder(4),
      ]) {
        expect(value.trim(), isNotEmpty, reason: '$tag için boş metin');
      }

      // Sayı içeren metinlerde placeholder gerçekten yerine konmuş olmalı
      expect(l10n.putFingers(3), contains('3'), reason: '$tag putFingers');
      expect(
        l10n.moreFingers(2),
        isNot(contains('{')),
        reason: '$tag işlenmemiş ICU placeholder',
      );
      for (final info in <String>[
        l10n.gameInfo(4, 2),
        l10n.gameInfoLosers(4, 2),
        l10n.gameInfoTeams(4, 2),
        l10n.gameInfoOrder(4),
      ]) {
        expect(info, contains('4'), reason: '$tag bilgi etiketi: $info');
        expect(info, isNot(contains('{')), reason: '$tag işlenmemiş: $info');
      }
    }
  });
}
