import '../controllers/game_controller.dart';
import '../l10n/app_localizations.dart';
import '../models/game_mode.dart';
import '../models/game_phase.dart';

/// Oyun durumunu ekranda gösterilecek yerelleştirilmiş metne çevirir.
///
/// Bu eşleme [GameController]'da değil UI katmanında yaşar: lokalizasyon
/// [BuildContext] gerektirir, controller ise saf oyun mantığı olarak kalmalı.

/// Ekranın ortasındaki büyük durum yazısı
String statusTextFor(AppLocalizations l10n, GameController c) =>
    switch (c.phase) {
      GamePhase.revealed => _resultText(l10n, c),
      GamePhase.choosing || GamePhase.locked => l10n.choosing,
      GamePhase.waiting => _waitingText(l10n, c),
      GamePhase.setup => '',
    };

String _waitingText(AppLocalizations l10n, GameController c) {
  final count = c.activePointers.length;
  final target = c.selectedPlayerCount ?? 0;
  if (count == 0) return l10n.putFingers(target);
  final needed = target - count;
  if (needed <= 0) return l10n.getReady;
  return l10n.moreFingers(needed);
}

/// Sonuç açıklandığında ortada görünen başlık
String _resultText(AppLocalizations l10n, GameController c) {
  // Katılımcı sayısı seçilen sayıdan azsa gerçek sayı kazanır
  final picked = c.pickedPointerIds.isNotEmpty
      ? c.pickedPointerIds.length
      : (c.selectedPickCount ?? 1);
  return switch (c.mode) {
    GameMode.pick => switch (c.outcome) {
        PickOutcome.winners => l10n.winnerBanner(picked),
        PickOutcome.losers => l10n.loserBanner(picked),
      },
    GameMode.teams => l10n.teamsBanner,
    GameMode.order => l10n.orderBanner,
  };
}

/// Oyun ekranının üstündeki küçük bilgi etiketi
String gameInfoLabelFor(AppLocalizations l10n, GameController c) {
  final players = c.selectedPlayerCount ?? 0;
  final picks = c.selectedPickCount ?? 1;
  return switch (c.mode) {
    GameMode.pick => c.outcome == PickOutcome.winners
        ? l10n.gameInfo(players, picks)
        : l10n.gameInfoLosers(players, picks),
    GameMode.teams => l10n.gameInfoTeams(players, GameController.teamCount),
    GameMode.order => l10n.gameInfoOrder(players),
  };
}

/// Seçim ekranındaki mod kutusunun adı
String modeLabelFor(AppLocalizations l10n, GameMode mode) => switch (mode) {
      GameMode.pick => l10n.modePick,
      GameMode.teams => l10n.modeTeams,
      GameMode.order => l10n.modeOrder,
    };

/// Seç modundaki kazanan/kaybeden düğmesinin adı
String outcomeLabelFor(AppLocalizations l10n, PickOutcome outcome) =>
    switch (outcome) {
      PickOutcome.winners => l10n.modeWinners,
      PickOutcome.losers => l10n.modeLosers,
    };

/// Seçim ekranındaki ikinci soru: kaç kazanan ya da kaç kaybeden
String pickCountQuestionFor(AppLocalizations l10n, PickOutcome outcome) =>
    outcome == PickOutcome.losers ? l10n.howManyLosers : l10n.howManyWinners;

/// Açıklamada dairelerin ortasına yazılan etiketler: takım harfi (A, B) ya da
/// sıra numarası (1, 2, 3...). Seç modunda etiket yok.
Map<int, String> resultLabelsFor(GameController c) => switch (c.mode) {
      GameMode.teams => {
          for (final MapEntry(key: id, value: team) in c.teamOfPointer.entries)
            id: String.fromCharCode(0x41 + team),
        },
      GameMode.order => {
          for (var i = 0; i < c.rankedPointerIds.length; i++)
            c.rankedPointerIds[i]: '${i + 1}',
        },
      GameMode.pick => const {},
    };
