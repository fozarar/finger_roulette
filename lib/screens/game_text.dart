import '../controllers/game_controller.dart';
import '../l10n/app_localizations.dart';
import '../models/game_phase.dart';

/// Oyun durumunu ekranda gösterilecek yerelleştirilmiş metne çevirir.
///
/// Bu eşleme [GameController]'da değil UI katmanında yaşar: lokalizasyon
/// [BuildContext] gerektirir, controller ise saf oyun mantığı olarak kalmalı.

/// Ekranın ortasındaki büyük durum yazısı
String statusTextFor(AppLocalizations l10n, GameController c) =>
    switch (c.phase) {
      GamePhase.revealed => l10n.winnerBanner(
          // Katılımcı sayısı seçilen kazanan sayısından azsa gerçek sayı kazanır
          c.winnerPointerIds.isNotEmpty
              ? c.winnerPointerIds.length
              : (c.selectedWinnerCount ?? 1),
        ),
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

/// Oyun ekranının üstündeki küçük bilgi etiketi
String gameInfoLabelFor(AppLocalizations l10n, GameController c) =>
    l10n.gameInfo(c.selectedPlayerCount ?? 0, c.selectedWinnerCount ?? 1);
