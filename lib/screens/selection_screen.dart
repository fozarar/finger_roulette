import 'dart:math';

import 'package:flutter/material.dart';

import '../app/tablet_scale.dart';
import '../controllers/game_controller.dart';
import '../l10n/app_localizations.dart';
import '../models/game_mode.dart';
import '../models/input_source.dart';
import '../services/sound_service.dart';
import '../services/stats_service.dart';
import '../widgets/mode_selector.dart';
import '../widgets/name_list_editor.dart';
import '../widgets/name_list_tabs.dart';
import '../widgets/option_button.dart';
import '../widgets/segmented_pill.dart';
import '../widgets/settings_sheet.dart';
import 'game_text.dart';

/// Oyun başlamadan önce girdinin, modun ve sayıların seçildiği ekran.
///
/// İki eksen var ve birbirinden bağımsız: katılımcılar nereden geliyor
/// (parmak / isim) ve ne çekiliyor (seç / takım / sıra). Seçimler tamamlanınca
/// [GameController] [GamePhase.waiting] fazına geçer; [HomeScreen] parmak
/// akışında oyun ekranını, isim akışında çarkı gösterir.
class SelectionScreen extends StatelessWidget {
  final GameController controller;

  /// Ayarlar sayfası tercihleri bu iki servisten okur ve onlara yazar
  final StatsService stats;
  final SoundService sound;

  const SelectionScreen({
    super.key,
    required this.controller,
    required this.stats,
    required this.sound,
  });

  /// Kaç kazanan seçilebileceğinin üst sınırı. Liste 20 kişiye, tablette
  /// parmaklar 10'a kadar çıkabiliyor ama 19 düğmelik bir satırın kimseye
  /// faydası yok.
  static const int _maxPickOptions = 5;

  /// İçeriğin en fazla genişliği: tablette mod kutuları ve isim alanı ekranın
  /// bir ucundan öbürüne uzamasın
  static const double _maxContentWidth = 560;

  /// Bir satırdaki en fazla sayı düğmesi. Tabletteki dokuz oyuncu seçeneği
  /// tek satıra sığmıyor; beşerli bölününce 5 + 4 dengeli duruyor.
  static const int _optionsPerRow = 5;

  /// Bu pencerede parmakla en fazla kaç kişi oynanabilir. Cihaza değil
  /// pencerenin gerçek boyutuna bakılıyor: on parmak yer ister, iPad'de
  /// daraltılmış bir pencere de telefon kadar dar.
  static int maxPlayersFor(Size screen) => TabletScale.isTablet(screen)
      ? GameMode.tabletMaxPlayers
      : GameMode.phoneMaxPlayers;

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
    // Takım sayısı yalnızca liste ikiden fazla takıma yetiyorsa sorulur;
    // yetmiyorsa soru yerine doğrudan "devam" çıkar
    final showTeamQuestion = isNames &&
        mode == GameMode.teams &&
        enoughNames &&
        controller.maxTeamCount > 2;
    final maxPicks = min(
      (isNames ? controller.names.length : controller.pendingPlayerCount ?? 2) -
          1,
      _maxPickOptions,
    );
    final playerCounts = mode.playerCounts(
      maxPlayers: maxPlayersFor(TabletScale.realSizeOf(context)),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SafeArea(
        // Klavye açıldığında ya da liste uzadığında taşmasın
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 20),
          // passthrough: sütun ekran genişliğini alsın. Aksi halde Stack
          // çocuğunu serbest bırakıyor, sütun en geniş çocuğu kadar daralıyor.
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              // Ortala ve genişliği sınırla; telefonda sınır ekrandan geniş
              // olduğu için hiçbir şey değişmiyor
              Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(maxWidth: _maxContentWidth),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 20),
                      // ── Başlık ─────────────────────────────────────────────────
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

                      // ── Katılımcılar nereden geliyor ───────────────────────────
                      SegmentedPill<InputSource>(
                        values: InputSource.values,
                        selected: controller.input,
                        iconFor: (value) => _inputIcons[value]!,
                        labelFor: (value) => inputLabelFor(l10n, value),
                        onSelected: controller.selectInput,
                      ),
                      const SizedBox(height: 22),

                      // ── Ne çekiliyor ───────────────────────────────────────────
                      ModeSelector(
                        selected: mode,
                        onSelected: controller.selectMode,
                      ),
                      const SizedBox(height: 18),

                      // ── Seçilenler ne oluyor (yalnızca seç modunda) ────────────
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

                      // ── Katılımcılar ───────────────────────────────────────────
                      if (isNames) ...[
                        NameListTabs(
                          lists: controller.lists,
                          activeIndex: controller.activeListIndex,
                          onSelect: controller.selectList,
                          onAdd: controller.addList,
                          onRename: controller.renameActiveList,
                          onDelete: controller.deleteActiveList,
                        ),
                        const SizedBox(height: 14),
                        NameListEditor(
                          names: controller.names,
                          onChanged: controller.setNames,
                        ),
                      ] else ...[
                        _question(l10n.howManyPlayers),
                        const SizedBox(height: 22),
                        for (var i = 0;
                            i < playerCounts.length;
                            i += _optionsPerRow) ...[
                          if (i > 0) const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (final n
                                  in playerCounts.skip(i).take(_optionsPerRow))
                                OptionButton(
                                  label: '$n',
                                  isSelected:
                                      controller.pendingPlayerCount == n,
                                  onTap: () => controller.selectPlayerCount(n),
                                ),
                            ],
                          ),
                        ],
                      ],

                      // ── Kaç kişi seçilecek ─────────────────────────────────────
                      if (showPickQuestion) ...[
                        const SizedBox(height: 34),
                        _question(pickCountQuestionFor(l10n, controller.outcome)),
                        const SizedBox(height: 22),
                        // Beş düğme 320 noktalık en dar telefona sığmıyor;
                        // orada satır küçülerek sığıyor
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (var n = 1; n <= maxPicks; n++)
                                OptionButton(
                                  label: '$n',
                                  // Seçim anında oyun başladığı için seçili
                                  // hali gerekmez
                                  isSelected: false,
                                  onTap: () => controller.selectPickCount(n),
                                ),
                            ],
                          ),
                        ),
                      ],

                      // ── Kaç takım kurulacak ────────────────────────────────────
                      if (showTeamQuestion) ...[
                        const SizedBox(height: 34),
                        _question(l10n.howManyTeams),
                        const SizedBox(height: 22),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (var n = 2; n <= controller.maxTeamCount; n++)
                              OptionButton(
                                label: '$n',
                                // Seçim anında oyun başladığı için seçili hali
                                // gerekmez
                                isSelected: false,
                                onTap: () => controller.selectTeamCount(n),
                              ),
                          ],
                        ),
                      ],

                      // ── Sorulacak bir şey kalmadıysa doğrudan devam ────────────
                      if (isNames && !mode.picksSubset && !showTeamQuestion) ...[
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

              // Ayarlar: oyun ekranlarındaki kapatma butonuyla aynı ölçü ve
              // ton. İçerikle birlikte kayıyor — sabit dursaydı klavye açılıp
              // ekran yukarı kayınca mod kutuları altından geçerdi.
              Positioned(
                top: 8,
                right: 4,
                child: IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  color: Colors.white70,
                  iconSize: 20,
                  tooltip: l10n.settings,
                  onPressed: () => SettingsSheet.show(
                    context,
                    stats: stats,
                    sound: sound,
                  ),
                ),
              ),
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
