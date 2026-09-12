import 'package:flutter/material.dart';

import '../controllers/game_controller.dart';
import '../l10n/app_localizations.dart';
import '../widgets/mode_selector.dart';
import '../widgets/option_button.dart';
import '../widgets/outcome_toggle.dart';
import 'game_text.dart';

/// Oyun başlamadan önce mod, oyuncu ve kazanan sayısının seçildiği ekran.
///
/// Seç modunda kazanan/kaybeden düğmesi ve oyuncu seçildikten sonra kaç kişi
/// seçileceği sorusu görünür; takım ve sıra modları ikisini de sormaz.
/// Seçimler tamamlanınca [GameController] otomatik olarak [GamePhase.waiting]
/// fazına geçer ve [HomeScreen] oyun ekranını gösterir.
class SelectionScreen extends StatelessWidget {
  final GameController controller;

  const SelectionScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final mode = controller.mode;
    // Kazanan/kaybeden yalnızca seç modunda sorulur
    final showOutcome = mode.picksSubset;
    // İkinci soru ayrıca oyuncu sayısının seçilmiş olmasını bekler
    final showPickQuestion = showOutcome && controller.pendingPlayerCount != null;
    final maxPicks = (controller.pendingPlayerCount ?? 2) - 1;

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SafeArea(
        // Küçük ekranda ya da büyük yazı boyutunda taşmasın diye kaydırılabilir
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Başlık ──────────────────────────────────────────────────
                const Text(
                  'FINGER',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 52,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 10,
                  ),
                ),
                const Text(
                  'CHOOSER',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w200,
                    letterSpacing: 12,
                  ),
                ),
                const SizedBox(height: 44),

                // ── Oyun modu ───────────────────────────────────────────────
                ModeSelector(selected: mode, onSelected: controller.selectMode),
                const SizedBox(height: 22),

                // ── Kazanan mı kaybeden mi (yalnızca seç modunda) ───────────
                // Görünmezken de yerini korur; böylece mod değişince düzen
                // zıplamaz.
                AnimatedOpacity(
                  opacity: showOutcome ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  child: IgnorePointer(
                    ignoring: !showOutcome,
                    child: OutcomeToggle(
                      selected: controller.outcome,
                      onSelected: controller.selectOutcome,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // ── Oyuncu sayısı seçimi ────────────────────────────────────
                Text(
                  l10n.howManyPlayers,
                  style: const TextStyle(
                    color: Color(0xAAFFFFFF),
                    fontSize: 16,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: mode.playerCounts
                      .map(
                        (n) => OptionButton(
                          label: '$n',
                          isSelected: controller.pendingPlayerCount == n,
                          onTap: () => controller.selectPlayerCount(n),
                        ),
                      )
                      .toList(),
                ),

                // ── Kaç kişi seçilecek (oyuncu sayısından sonra) ────────────
                AnimatedOpacity(
                  opacity: showPickQuestion ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOut,
                  child: AnimatedSlide(
                    offset: showPickQuestion
                        ? Offset.zero
                        : const Offset(0, 0.25),
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOut,
                    child: IgnorePointer(
                      ignoring: !showPickQuestion,
                      child: Column(
                        children: [
                          const SizedBox(height: 44),
                          Text(
                            pickCountQuestionFor(l10n, controller.outcome),
                            style: const TextStyle(
                              color: Color(0xAAFFFFFF),
                              fontSize: 16,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(maxPicks, (i) => i + 1)
                                .map(
                                  (n) => OptionButton(
                                    label: '$n',
                                    // Seçim anında oyun ekranına geçtiği için
                                    // seçili görsel durumu gerekmez
                                    isSelected: false,
                                    onTap: () => controller.selectPickCount(n),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
