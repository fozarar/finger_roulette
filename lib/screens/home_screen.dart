import 'package:flutter/material.dart';

import '../controllers/game_controller.dart';
import '../models/game_phase.dart';
import '../models/spin_beam.dart';
import '../services/review_service.dart';
import '../services/stats_service.dart';
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
  final StatsService stats;
  final ReviewService review;

  const HomeScreen({super.key, required this.stats, required this.review});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // ── Controller ────────────────────────────────────────────────────────────

  late final GameController _controller;

  // ── Animasyonlar ──────────────────────────────────────────────────────────

  /// Öne çıkan dairelerin scale animasyonu: 1.0 → 1.4, elastic overshoot
  late AnimationController _winnerScaleController;
  late Animation<double> _winnerScaleAnimation;

  /// Öne çıkan dairelerin nabız gibi parlayan glow animasyonu: 0.35 → 1.0
  late AnimationController _winnerGlowController;
  late Animation<double> _winnerGlowAnimation;

  /// Sonuç açıklandığında ekranı kısaca beyaza yakın flash yapan animasyon
  late AnimationController _flashController;
  late Animation<double> _flashAnimation;

  /// Rulet ışınının dönüşü. Süresi [GameController.spinDuration] ile aynı
  /// olmak zorunda: ışın tam sonuç açıklanırken hedefin üstünde durmalı.
  late AnimationController _beamController;

  /// Kare başına bir kez hesaplanan ışın geometrisi. Hem çizim hem de tik
  /// sesi bunu okur; iki yerde ayrı hesaplansaydı ses ile görüntü ayrışırdı.
  final ValueNotifier<SpinBeam?> _beam = ValueNotifier(null);

  /// Işının en son hangi parmağı gösterdiği; değiştiği karede tik çalar
  int _lastBeamIndex = -1;

  /// Bir önceki bildirimde sonuç açıklanmış mıydı — animasyon tetikleme için
  bool _wasRevealed = false;

  /// Bir önceki bildirimde ışın dönüyor muydu
  bool _wasSpinning = false;

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

    _beamController = AnimationController(
      vsync: this,
      duration: GameController.spinDuration,
    )..addListener(_updateBeam);

    _controller = GameController(stats: widget.stats, review: widget.review);
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
    _beamController
      ..removeListener(_updateBeam)
      ..dispose();
    _beam.dispose();
    super.dispose();
  }

  // ── Animasyon tetikleyici ──────────────────────────────────────────────────

  /// Controller her bildirim gönderdiğinde çağrılır.
  /// Sonuç açıklanınca animasyonları başlatır; oyun sıfırlanınca durdurur.
  void _onControllerChanged() {
    final isRevealed = _controller.phase == GamePhase.revealed;
    final isSpinning = _controller.phase == GamePhase.locked;

    if (!_wasSpinning && isSpinning) {
      // Parmaklar kilitlendi — ışın dönmeye başlasın
      _lastBeamIndex = -1;
      _beamController.forward(from: 0);
    } else if (_wasSpinning && !isSpinning) {
      _beamController.stop();
      _beam.value = null;
    }
    _wasSpinning = isSpinning;

    if (!_wasRevealed && isRevealed) {
      // Sonuç yeni açıklandı — animasyonları başlat
      _winnerScaleController.forward();
      _winnerGlowController.repeat(reverse: true);
      _flashController.forward(from: 0);
    } else if (_wasRevealed && !isRevealed) {
      // Oyun sıfırlandı — animasyonları durdur
      _winnerScaleController.reset();
      _winnerGlowController
        ..stop()
        ..reset();
      _flashController.reset();
    }

    _wasRevealed = isRevealed;
  }

  // ── Işın geometrisi ────────────────────────────────────────────────────────

  /// Işın animasyonunun her karesinde çağrılır: geometriyi yeniden hesaplar
  /// ve ışın yeni bir parmağın üstüne geçtiyse tik sesini tetikler.
  ///
  /// Tik'i zamanlayıcıyla üretmek yerine gerçek geçişi kullanmak sesi
  /// görüntüye bağlar: ışın yavaşladıkça tik'ler kendiliğinden seyrekleşir.
  void _updateBeam() {
    if (_controller.phase != GamePhase.locked) {
      _beam.value = null;
      return;
    }

    final beam = SpinBeam.of(
      lockedPointerIds: _controller.lockedPointerIds,
      positions: _controller.activePointers,
      targetPointerId: _controller.spinTargetPointerId,
      t: _beamController.value,
    );

    if (beam != null && beam.highlightIndex != _lastBeamIndex) {
      _lastBeamIndex = beam.highlightIndex;
      _controller.playSpinTick();
    }
    _beam.value = beam;
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
          beam: _beam,
          winnerScaleAnimation: _winnerScaleAnimation,
          winnerGlowAnimation: _winnerGlowAnimation,
          flashAnimation: _flashAnimation,
        );
      },
    );
  }
}
