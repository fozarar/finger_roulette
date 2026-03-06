import 'package:flutter/material.dart';

import '../controllers/game_controller.dart';
import '../widgets/option_button.dart';

/// Oyun başlamadan önce oyuncu ve kazanan sayısının seçildiği ekran.
///
/// Oyuncu seçilince kazanan seçimi animasyonla açılır.
/// Her iki seçim tamamlanınca [GameController] otomatik olarak
/// [GamePhase.waiting] fazına geçer ve [HomeScreen] oyun ekranını gösterir.
class SelectionScreen extends StatelessWidget {
  final GameController controller;

  const SelectionScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final playersSelected = controller.pendingPlayerCount != null;
    final maxWinners = (controller.pendingPlayerCount ?? 2) - 1;

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
                'ROULETTE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w200,
                  letterSpacing: 12,
                ),
              ),
              const SizedBox(height: 72),

              // ── Oyuncu sayısı seçimi ────────────────────────────────────
              const Text(
                'How many players?',
                style: TextStyle(
                  color: Color(0xAAFFFFFF),
                  fontSize: 16,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [2, 3, 4, 5]
                    .map(
                      (n) => OptionButton(
                        label: '$n',
                        isSelected: controller.pendingPlayerCount == n,
                        onTap: () => controller.selectPlayerCount(n),
                      ),
                    )
                    .toList(),
              ),

              // ── Kazanan sayısı seçimi (oyuncu seçildikten sonra görünür) ─
              AnimatedOpacity(
                opacity: playersSelected ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOut,
                child: AnimatedSlide(
                  offset:
                      playersSelected ? Offset.zero : const Offset(0, 0.25),
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOut,
                  child: IgnorePointer(
                    ignoring: !playersSelected,
                    child: Column(
                      children: [
                        const SizedBox(height: 48),
                        const Text(
                          'How many winners?',
                          style: TextStyle(
                            color: Color(0xAAFFFFFF),
                            fontSize: 16,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(maxWinners, (i) => i + 1)
                              .map(
                                (n) => OptionButton(
                                  label: '$n',
                                  // Kazanan seçimi anında oyun ekranına geçtiği
                                  // için seçili görsel durumu gerekmez
                                  isSelected: false,
                                  onTap: () => controller.selectWinnerCount(n),
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
    );
  }
}
