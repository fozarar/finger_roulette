import 'package:flutter/material.dart';

import '../controllers/game_controller.dart';
import '../models/game_phase.dart';
import '../painters/finger_painter.dart';
import '../widgets/particle_overlay.dart';

/// Oyunun oynandığı ekran.
///
/// Parmak dokunuşlarını [Listener] ile yakalar ve [GameController]'a iletir.
/// Parmak dairelerini [FingerPainter] üzerinden çizer.
/// Geri butonu [Listener]'ın dışında konumlanır — her zaman dokunulabilir.
class GameScreen extends StatelessWidget {
  final GameController controller;
  final Animation<double> winnerScaleAnimation;
  final Animation<double> winnerGlowAnimation;
  final Animation<double> flashAnimation;

  const GameScreen({
    super.key,
    required this.controller,
    required this.winnerScaleAnimation,
    required this.winnerGlowAnimation,
    required this.flashAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final isLocked = controller.phase == GamePhase.locked ||
        controller.phase == GamePhase.revealed;

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: Stack(
        children: [
          // ── Oyun alanı — dokunuş olaylarını dinler ───────────────────────
          Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: controller.handlePointerDown,
            onPointerMove: controller.handlePointerMove,
            onPointerUp: controller.handlePointerUp,
            onPointerCancel: controller.handlePointerCancel,
            child: SizedBox.expand(
              child: Stack(
                children: [
                  // ── Parmak daireleri ──────────────────────────────────────
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      winnerScaleAnimation,
                      winnerGlowAnimation,
                    ]),
                    builder: (context, _) => CustomPaint(
                      painter: FingerPainter(
                        activePointers: Map.of(controller.activePointers),
                        pointerColors: Map.of(controller.pointerColors),
                        lockedPointerIds:
                            List.of(controller.lockedPointerIds),
                        winnerPointerIds:
                            List.of(controller.winnerPointerIds),
                        highlightIndex: controller.highlightIndex,
                        isLocked: isLocked,
                        winnerScale: winnerScaleAnimation.value,
                        winnerGlow: winnerGlowAnimation.value,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),

                  // ── Oyun bilgisi (üst orta) ───────────────────────────────
                  Positioned(
                    top: 52,
                    left: 0,
                    right: 0,
                    child: IgnorePointer(
                      child: Center(
                        child: Text(
                          controller.gameInfoLabel,
                          style: const TextStyle(
                            color: Color(0x55FFFFFF),
                            fontSize: 13,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Ortada durum yazısı ───────────────────────────────────
                  Center(
                    child: IgnorePointer(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 280),
                        transitionBuilder: (child, animation) =>
                            FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: Tween<double>(begin: 0.85, end: 1.0)
                                .animate(animation),
                            child: child,
                          ),
                        ),
                        child: Text(
                          controller.statusText,
                          key: ValueKey(controller.statusText),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xBBFFFFFF),
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                            shadows: [
                              Shadow(
                                blurRadius: 10,
                                color: Colors.black54,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Arka plan flash efekti ────────────────────────────────
                  AnimatedBuilder(
                    animation: flashAnimation,
                    builder: (context, _) => IgnorePointer(
                      child: Container(
                        color: Colors.white
                            .withAlpha((flashAnimation.value * 255).round()),
                      ),
                    ),
                  ),

                  // ── Konfeti parçacıkları ──────────────────────────────────
                  if (controller.winnerPointerIds.isNotEmpty)
                    ParticleOverlay(
                      key: const ValueKey('particles'),
                      origins: controller.winnerPointerIds
                          .map(
                            (id) =>
                                controller.activePointers[id] ?? Offset.zero,
                          )
                          .toList(),
                      colors: controller.winnerPointerIds
                          .map(
                            (id) =>
                                controller.pointerColors[id] ?? Colors.white,
                          )
                          .toList(),
                    ),

                  // ── Reset butonları ───────────────────────────────────────
                  if (controller.showReset)
                    Positioned(
                      bottom: 64,
                      left: 0,
                      right: 0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Aynı ayarlarla tekrar oyna
                          ElevatedButton(
                            onPressed: controller.resetGame,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 48,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                              elevation: 10,
                              shadowColor: Colors.white30,
                            ),
                            child: const Text(
                              'Play Again',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Oyuncu/kazanan sayısını değiştir
                          TextButton(
                            onPressed: controller.changeSettings,
                            child: const Text(
                              'Change Settings',
                              style: TextStyle(
                                color: Color(0x88FFFFFF),
                                fontSize: 15,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Geri butonu — Listener'ın dışında, her zaman dokunulabilir ───
          // Sol üst köşe; handlePointerDown bu alanı (dx<80, dy<80) yoksayar
          SafeArea(
            child: Align(
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
          ),
        ],
      ),
    );
  }
}
