import 'package:flutter/material.dart';

import '../controllers/game_controller.dart';
import '../models/game_phase.dart';
import 'game_screen.dart';
import 'selection_screen.dart';

/// Uygulamanın tek ekranı — seçim ve oyun görünümleri arasında köprü kurar.
///
/// Animasyon controller'ları burada yaşar çünkü [TickerProviderStateMixin]
/// gerektirirler ve bir widget'a bağlı olmaları gerekir.
///
/// [GameController] dinlenerek phase değişimlerinde animasyonlar tetiklenir;
/// böylece iş mantığı controller'da, animasyon mantığı widget'ta kalır.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // ── Controller ────────────────────────────────────────────────────────────

  late final GameController _controller;

  // ── Animasyonlar ──────────────────────────────────────────────────────────

  /// Kazanan dairenin scale animasyonu: 1.0 → 1.4, elastic overshoot
  late AnimationController _winnerScaleController;
  late Animation<double> _winnerScaleAnimation;

  /// Kazanan dairenin nabız gibi parlayan glow animasyonu: 0.35 → 1.0
  late AnimationController _winnerGlowController;
  late Animation<double> _winnerGlowAnimation;

  /// Kazanan açıklandığında ekranı kısaca beyaza yakın flash yapan animasyon
  late AnimationController _flashController;
  late Animation<double> _flashAnimation;

  /// Bir önceki frame'deki kazanan listesi — animasyon tetikleme için
  bool _hadWinners = false;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    _winnerScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _winnerScaleAnimation = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(
        parent: _winnerScaleController,
        curve: Curves.elasticOut,
      ),
    );

    _winnerGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _winnerGlowAnimation = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(parent: _winnerGlowController, curve: Curves.easeInOut),
    );

    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _flashAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.3), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.3, end: 0.0), weight: 70),
    ]).animate(_flashController);

    _controller = GameController();
    // Controller değiştiğinde animasyon durumunu güncelle
    _controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onControllerChanged)
      ..dispose();
    _winnerScaleController.dispose();
    _winnerGlowController.dispose();
    _flashController.dispose();
    super.dispose();
  }

  // ── Animasyon tetikleyici ──────────────────────────────────────────────────

  /// Controller her bildirim gönderdiğinde çağrılır.
  /// Kazanan listesi boştan dolmaya geçince animasyonları başlatır;
  /// tersine geçince durdurur.
  void _onControllerChanged() {
    final hasWinners = _controller.winnerPointerIds.isNotEmpty;

    if (!_hadWinners && hasWinners) {
      // Kazanan(lar) yeni seçildi — animasyonları başlat
      _winnerScaleController.forward();
      _winnerGlowController.repeat(reverse: true);
      _flashController.forward(from: 0);
    } else if (_hadWinners && !hasWinners) {
      // Oyun sıfırlandı — animasyonları durdur
      _winnerScaleController.reset();
      _winnerGlowController
        ..stop()
        ..reset();
      _flashController.reset();
    }

    _hadWinners = hasWinners;
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        // Seçim tamamlanmadan oyun ekranına geçme
        if (_controller.phase == GamePhase.setup) {
          return SelectionScreen(controller: _controller);
        }
        return GameScreen(
          controller: _controller,
          winnerScaleAnimation: _winnerScaleAnimation,
          winnerGlowAnimation: _winnerGlowAnimation,
          flashAnimation: _flashAnimation,
        );
      },
    );
  }
}
