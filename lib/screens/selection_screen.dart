import 'dart:math';

import 'package:flutter/material.dart';

import '../controllers/game_controller.dart';
import '../l10n/app_localizations.dart';
import '../models/game_mode.dart';
import '../models/input_source.dart';
import '../widgets/mode_selector.dart';
import '../widgets/name_list_editor.dart';
import '../widgets/option_button.dart';
import '../widgets/segmented_pill.dart';
import 'game_text.dart';

/// Oyun başlamadan önce girdinin, modun ve sayıların seçildiği ekran.
///
/// İki eksen var ve birbirinden bağımsız: katılımcılar nereden geliyor
/// (parmak / isim) ve ne çekiliyor (seç / takım / sıra). Seçimler tamamlanınca
/// [GameController] [GamePhase.waiting] fazına geçer; [HomeScreen] parmak
/// akışında oyun ekranını, isim akışında çarkı gösterir.
class SelectionScreen extends StatelessWidget {
  final GameController controller;

  const SelectionScreen({super.key, required this.controller});

  /// İsim listesinde kaç kazanan seçilebileceğinin üst sınırı. Liste 20 kişiye
  /// kadar çıkabiliyor ama 19 düğmelik bir satırın kimseye faydası yok.
  static const int _maxPickOptions = 5;

  static const Map<InputSource, IconData> _inputIcons = {
    InputSource.fingers: Icons.touch_app_outlined,
    InputSource.names: Icons.format_list_bulleted_rounded,
  };

  static const Map<PickOutcome, IconData> _outcomeIcons = {
    PickOutcome.winners: Icons.emoji_events_outlined,
    PickOutcome.losers: Icons.sentiment_very_dissatisfied_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final mode = controller.mode;
    final isNames = controller.input == InputSource.names;
    final enoughNames = controller.names.length >= 2;

    // İkinci soru: parmakta oyuncu seçilince, isimde liste dolunca açılır
    final showPickQuestion = mode.picksSubset &&
        (isNames ? enoughNames : controller.pendingPlayerCount != null);
    final maxPicks = isNames
        ? min(controller.names.length - 1, _maxPickOptions)
        : (controller.pendingPlayerCount ?? 2) - 1;

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SafeArea(
        // Klavye açıldığında ya da liste uzadığında taşmasın
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Başlık ──────────────────────────────────────────────────
              const Text(
                'FINGER',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 9,
                ),
              ),
              const Text(
                'CHOOSER',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w200,
                  letterSpacing: 11,
                ),
              ),
              const SizedBox(height: 26),

              // ── Katılımcılar nereden geliyor ────────────────────────────
              SegmentedPill<InputSource>(
                values: InputSource.values,
                selected: controller.input,
                iconFor: (value) => _inputIcons[value]!,
                labelFor: (value) => inputLabelFor(l10n, value),
                onSelected: controller.selectInput,
              ),
              const SizedBox(height: 22),

              // ── Ne çekiliyor ────────────────────────────────────────────
              ModeSelector(selected: mode, onSelected: controller.selectMode),
              const SizedBox(height: 18),

              // ── Seçilenler ne oluyor (yalnızca seç modunda) ─────────────
              AnimatedOpacity(
                opacity: mode.picksSubset ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                child: IgnorePointer(
                  ignoring: !mode.picksSubset,
                  child: SegmentedPill<PickOutcome>(
                    values: PickOutcome.values,
                    selected: controller.outcome,
                    iconFor: (value) => _outcomeIcons[value]!,
                    labelFor: (value) => outcomeLabelFor(l10n, value),
                    onSelected: controller.selectOutcome,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // ── Katılımcılar ────────────────────────────────────────────
              if (isNames)
                NameListEditor(
                  names: controller.names,
                  onChanged: controller.setNames,
                )
              else ...[
                _question(l10n.howManyPlayers),
                const SizedBox(height: 22),
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
              ],

              // ── Kaç kişi seçilecek ──────────────────────────────────────
              if (showPickQuestion) ...[
                const SizedBox(height: 34),
                _question(pickCountQuestionFor(l10n, controller.outcome)),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(maxPicks, (i) => i + 1)
                      .map(
                        (n) => OptionButton(
                          label: '$n',
                          // Seçim anında oyun başladığı için seçili hali gerekmez
                          isSelected: false,
                          onTap: () => controller.selectPickCount(n),
                        ),
                      )
                      .toList(),
                ),
              ],

              // ── Takım ve sırada sorulacak bir şey yok; doğrudan devam ───
              if (isNames && !mode.picksSubset) ...[
                const SizedBox(height: 34),
                ElevatedButton(
                  onPressed: enoughNames ? controller.confirmNames : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: Colors.white24,
                    disabledForegroundColor: Colors.white38,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 46,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  child: Text(
                    l10n.continueLabel,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _question(String text) => Text(
        text,
        style: const TextStyle(
          color: Color(0xAAFFFFFF),
          fontSize: 16,
          letterSpacing: 1.5,
        ),
      );
}
