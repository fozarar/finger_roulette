import 'dart:math';

import 'package:finger_roulette/controllers/game_controller.dart';
import 'package:finger_roulette/l10n/app_localizations.dart';
import 'package:finger_roulette/l10n/app_localizations_en.dart';
import 'package:finger_roulette/l10n/app_localizations_tr.dart';
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
  int players = 3,
  int winners = 1,
  int fingersDown = 0,
  List<int> winnerIds = const [],
}) {
  final c = GameController(random: Random(1), sound: _SilentSound())
    ..selectedPlayerCount = players
    ..selectedWinnerCount = winners
    ..phase = phase
    ..winnerPointerIds = List.of(winnerIds);
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
        winners: 1,
        winnerIds: [1],
      );
      expect(statusTextFor(l10n, single), 'Winner!');

      final multi = controllerIn(
        phase: GamePhase.revealed,
        winners: 2,
        winnerIds: [1, 2],
      );
      expect(statusTextFor(l10n, multi), 'Winners!');
    });

    test('bilgi etiketi oyuncu ve kazanan sayısını içerir', () {
      final c = controllerIn(phase: GamePhase.waiting, players: 5, winners: 2);
      expect(gameInfoLabelFor(l10n, c), '5 players · 2 winners');
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
        winners: 2,
        winnerIds: [1, 2],
      );
      expect(statusTextFor(l10n, revealed), 'Kazananlar!');
    });
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
        l10n.getReady,
        l10n.choosing,
        l10n.playAgain,
        l10n.changeSettings,
        l10n.putFingers(3),
        l10n.moreFingers(1),
        l10n.moreFingers(2),
        l10n.winnerBanner(1),
        l10n.winnerBanner(2),
        l10n.gameInfo(4, 2),
      ]) {
        expect(value.trim(), isNotEmpty, reason: '$tag için boş metin');
      }

      // Sayı içeren metinlerde placeholder gerçekten yerine konmuş olmalı
      expect(l10n.putFingers(3), contains('3'), reason: '$tag putFingers');
      expect(l10n.gameInfo(4, 2), contains('4'), reason: '$tag gameInfo');
      expect(
        l10n.moreFingers(2),
        isNot(contains('{')),
        reason: '$tag işlenmemiş ICU placeholder',
      );
    }
  });
}
