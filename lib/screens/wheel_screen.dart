import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../controllers/game_controller.dart';
import '../l10n/app_localizations.dart';
import '../models/game_mode.dart';
import '../models/game_phase.dart';
import '../models/wheel_spin.dart';
import '../painters/wheel_painter.dart';
import '../widgets/particle_overlay.dart';
import '../widgets/share_button.dart';
import 'game_text.dart';

/// İsim listesiyle oynanan ekran.
///
/// Parmak ekranının ([GameScreen]) karşılığı ve aynı fazları kullanır:
/// waiting'de çark durur, locked'da döner, revealed'da sonuç açıklanır.
/// Seç modunda sonuç çarkın üstünde kalır — ibrenin kazananı göstermesi
/// açıklamanın kendisidir. Takım ve sıra tek bir dilimi işaret etmediği için
/// çark yerini listeye bırakır.
class WheelScreen extends StatelessWidget {
  final GameController controller;

  /// Çarkın o anki dönüşü; her karede [HomeScreen] günceller
  final ValueListenable<WheelSpin> wheel;

  /// Sonuç açıklandığında ekranı kısaca aydınlatan flash
  final Animation<double> flashAnimation;

  /// Paylaşılacak görselin sınırı: çark ya da liste ve yazılar, butonlar hariç
  final GlobalKey captureKey;

  const WheelScreen({
    super.key,
    required this.controller,
    required this.wheel,
    required this.flashAnimation,
    required this.captureKey,
  });

  /// Buton alanının sabit yüksekliği — faz değişince düzen zıplamasın.
  /// Açıklamadan sonra üç buton alt alta duruyor (tekrar çevir, paylaş,
  /// ayarları değiştir); ölçü ona göre.
  static const double _buttonAreaHeight = 122 + ShareButton.height + 6;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final revealed = controller.phase == GamePhase.revealed;
    // Dönüş biter bitmez çark ekranda kalıp seçilen ismi gösteriyor; takım ve
    // sıra listesi butonlarla birlikte, o an geçtikten sonra geliyor.
    final showWheel =
        !revealed || controller.mode == GameMode.pick || !controller.showReset;

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SafeArea(
        child: Stack(
          children: [
            // Genişliği zorlamak şart: Stack sol üstten hizalıyor ve serbest
            // bırakılan sütun en geniş çocuğu kadar daralıp sola yapışıyor.
            // Çark varken fark edilmiyordu, çünkü çark zaten tam genişlikti;
            // sıra ve takım sonuçlarında liste sola kayıyordu.
            SizedBox.expand(
              child: Column(
                children: [
                  // Paylaşılan görsel yalnızca bu kısımdan oluşur. Scaffold'un
                  // rengi sınırın dışında kaldığı için arka plan burada da
                  // boyanıyor, yoksa yakalanan görsel şeffaf olur.
                  Expanded(
                    child: RepaintBoundary(
                      key: captureKey,
                      child: ColoredBox(
                        color: const Color(0xFF111111),
                        child: Column(
                          children: [
                            const SizedBox(height: 40),
                            Text(
                              gameInfoLabelFor(l10n, controller),
                              style: const TextStyle(
                                color: Color(0x55FFFFFF),
                                fontSize: 13,
                                letterSpacing: 2,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                child:
                                    showWheel ? _wheelView() : _resultList(),
                              ),
                            ),
                            _status(l10n),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(height: _buttonAreaHeight, child: _buttons(l10n)),
                ],
              ),
            ),

            // ── Açıklama anındaki flash ────────────────────────────────────
            AnimatedBuilder(
              animation: flashAnimation,
              builder: (context, _) => IgnorePointer(
                child: Container(
                  color: Colors.white.withValues(alpha: flashAnimation.value),
                ),
              ),
            ),

            // Konfeti dekoratif: dokunuşu yutarsa altındaki butonlar ölür.
            // CustomPaint'in varsayılanı dokunuşu üstlenmek olduğu için bunu
            // açıkça kapatmak gerekiyor.
            // Konfeti yalnızca çark ekranda kalırken: takım ve sıra sonucunda
            // parçacıklar listenin üstüne biniyor ve isimleri okutmuyor.
            if (revealed && controller.mode == GameMode.pick)
              IgnorePointer(child: _confetti()),

            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, left: 4),
                child: IconButton(
                  icon: const Icon(Icons.close),
                  color: Colors.white70,
                  iconSize: 20,
                  onPressed: controller.changeSettings,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Çark ───────────────────────────────────────────────────────────────────

  Widget _wheelView() {
    final winners =
        controller.mode == GameMode.pick ? controller.pickedIds : const <int>[];
    final spinning = controller.phase == GamePhase.locked;
    final target = controller.spinTargetId;
    // Dururken herkes, açıklamada yalnızca ibrenin gösterdiği isim
    final labelIndices = controller.phase == GamePhase.revealed
        ? (target == null ? const <int>[] : [target])
        : List.generate(controller.names.length, (i) => i);

    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: TweenAnimationBuilder<double>(
          // Dönerken isimler okunmuyor zaten; silinince dönüş temiz görünüyor
          tween: Tween(begin: 1.0, end: spinning ? 0.0 : 1.0),
          duration: Duration(milliseconds: spinning ? 200 : 380),
          curve: Curves.easeOut,
          builder: (context, labelOpacity, _) => TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: winners.isEmpty ? 0.0 : 1.0),
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeOut,
            builder: (context, reveal, _) => ValueListenableBuilder<WheelSpin>(
              valueListenable: wheel,
              builder: (context, spin, _) => CustomPaint(
                painter: WheelPainter(
                  names: controller.names,
                  angle: spin.angle,
                  winners: winners,
                  reveal: reveal,
                  labelOpacity: labelOpacity,
                  labelIndices: labelIndices,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Takım ve sıra sonuçları ────────────────────────────────────────────────

  Widget _resultList() => SingleChildScrollView(
        child: switch (controller.mode) {
          GameMode.teams => _teams(),
          GameMode.order => _order(),
          GameMode.pick => const SizedBox.shrink(),
        },
      );

  /// Takımlar yan yana sütunlar hâlinde. Dört takım tek satıra sığmıyor —
  /// sütunlar isim okunmayacak kadar daralıyor — o yüzden 2×2 diziliyor.
  Widget _teams() {
    final count = controller.teamCount;
    final rows = count == 4
        ? const [
            [0, 1],
            [2, 3],
          ]
        : [List.generate(count, (team) => team)];

    return Column(
      children: [
        for (final (index, row) in rows.indexed) ...[
          if (index > 0) const SizedBox(height: 28),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final team in row) Expanded(child: _teamColumn(team)),
            ],
          ),
        ],
      ],
    );
  }

  Widget _teamColumn(int team) => Column(
        children: [
          Text(
            String.fromCharCode(0x41 + team),
            style: TextStyle(
              color: GameController.teamColors[team],
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          for (final id in controller.teamOfId.entries
              .where((e) => e.value == team)
              .map((e) => e.key))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
              // Üç sütunda uzun bir isim sığmayabiliyor; kesmek yerine
              // küçültülüyor ki kimin hangi takımda olduğu okunabilsin
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  controller.names[id],
                  maxLines: 1,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
        ],
      );

  /// Satırlar tek tek ortalanırsa numaralar birbirini tutmuyor; blok olarak
  /// ortalanıp içeride sola hizalanınca 1, 2, 3 alt alta iniyor.
  Widget _order() => IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var rank = 0; rank < controller.rankedIds.length; rank++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 40,
                      child: Text(
                        '${rank + 1}',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: rank == 0 ? Colors.white : Colors.white54,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      controller.names[controller.rankedIds[rank]],
                      style: TextStyle(
                        color: rank == 0 ? Colors.white : Colors.white70,
                        fontSize: 20,
                        fontWeight: rank == 0 ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );

  // ── Durum yazısı ───────────────────────────────────────────────────────────

  Widget _status(AppLocalizations l10n) {
    final text = switch (controller.phase) {
      GamePhase.locked => l10n.choosing,
      GamePhase.revealed => _revealText(l10n),
      _ => controller.names.length < 2 ? l10n.needTwoNames : '',
    };
    final isName =
        controller.phase == GamePhase.revealed && controller.mode == GameMode.pick;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        child: Text(
          text,
          key: ValueKey(text),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: isName ? Colors.white : const Color(0xBBFFFFFF),
            fontSize: isName ? 30 : 22,
            fontWeight: isName ? FontWeight.w800 : FontWeight.w600,
            letterSpacing: isName ? 0.5 : 1.5,
          ),
        ),
      ),
    );
  }

  /// Açıklamada ne yazacağı: seç modunda kazananın adı — asıl merak edilen
  /// şey o. Takım ve sırada liste zaten altta, başlık yeter.
  String _revealText(AppLocalizations l10n) {
    // Dönüş bittiği an merak edilen tek şey ibrenin nerede durduğu; başlık
    // moda göre değişmeden önce o ismi söylüyor
    final target = controller.spinTargetId;
    if (!controller.showReset && target != null) {
      return controller.names[target];
    }
    return switch (controller.mode) {
      GameMode.pick =>
        controller.pickedIds.map((id) => controller.names[id]).join(' · '),
      GameMode.teams => l10n.teamsBanner,
      GameMode.order => l10n.orderBanner,
    };
  }

  // ── Butonlar ───────────────────────────────────────────────────────────────

  Widget _buttons(AppLocalizations l10n) {
    if (controller.phase == GamePhase.locked) return const SizedBox.shrink();

    if (controller.phase == GamePhase.revealed) {
      if (!controller.showReset) return const SizedBox.shrink();
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _primaryButton(l10n.spinAgain, controller.spinAgain),
          const SizedBox(height: 10),
          ShareButton(
            captureKey: captureKey,
            onShared: controller.recordShare,
          ),
          const SizedBox(height: 2),
          TextButton(
            onPressed: controller.changeSettings,
            child: Text(
              l10n.changeSettings,
              style: const TextStyle(
                color: Color(0x88FFFFFF),
                fontSize: 15,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      );
    }

    // Hizalama olmadan buton alanın sabit yüksekliğine geriliyordu. Üste
    // hizalı: açıklamadan sonraki "tekrar çevir" butonuyla aynı yerde dursun.
    return Align(
      alignment: Alignment.topCenter,
      child: _primaryButton(
        l10n.spin,
        controller.names.length >= 2 ? controller.startNameRound : null,
      ),
    );
  }

  Widget _primaryButton(String label, VoidCallback? onPressed) => ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          disabledBackgroundColor: Colors.white24,
          disabledForegroundColor: Colors.white38,
          padding: const EdgeInsets.symmetric(horizontal: 52, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          elevation: 10,
          shadowColor: Colors.white30,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
      );

  // ── Konfeti ────────────────────────────────────────────────────────────────

  /// Parçacıklar çarkın göbeğinden çıkar. Takım modunda herkes öne çıktığı
  /// için kaynak sayısı sınırlanır; 20 isimde ekran parçacığa boğulmasın.
  Widget _confetti() => LayoutBuilder(
        builder: (context, constraints) {
          final ids = controller.spotlightIds.take(3).toList();
          if (ids.isEmpty) return const SizedBox.shrink();
          final center = Offset(
            constraints.maxWidth / 2,
            constraints.maxHeight / 2,
          );
          return ParticleOverlay(
            key: const ValueKey('wheel-particles'),
            origins: [for (final _ in ids) center],
            colors: [
              for (final id in ids)
                WheelPainter.colorFor(id, controller.names.length),
            ],
          );
        },
      );
}
