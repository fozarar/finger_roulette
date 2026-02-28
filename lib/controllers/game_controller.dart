import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/game_phase.dart';
import '../services/sound_service.dart';

/// Tüm oyun mantığını ve durumunu yönetir.
///
/// [ChangeNotifier] arayüzü üzerinden UI katmanına değişiklik bildirir.
/// Animasyon controller'ları vsync gerektirdiğinden widget katmanında kalır;
/// bu sınıf yalnızca oyun iş mantığından sorumludur.
class GameController extends ChangeNotifier {
  // ── Seçim durumu ──────────────────────────────────────────────────────────

  /// Oyuncu sayısı seçildi, kazanan henüz seçilmedi
  int? pendingPlayerCount;

  /// Onaylanan oyuncu sayısı (her iki seçim tamamlandıktan sonra set edilir)
  int? selectedPlayerCount;

  /// Onaylanan kazanan sayısı
  int? selectedWinnerCount;

  // ── Oyun durumu ───────────────────────────────────────────────────────────

  GamePhase phase = GamePhase.setup;

  /// Aktif parmaklar: pointerId → ekrandaki konum
  final Map<int, Offset> activePointers = {};

  /// Her pointer için rastgele atanmış pastel renk
  final Map<int, Color> pointerColors = {};

  /// 800ms sonra kilitlenen katılımcı pointer listesi
  List<int> lockedPointerIds = [];

  /// Seçilen kazanan pointer ID'leri
  List<int> winnerPointerIds = [];

  /// True olduğunda "Play Again" / "Change Settings" butonları gösterilir
  bool showReset = false;

  /// "Choosing..." döngüsünde vurgulanan dairenin indeksi
  int highlightIndex = 0;

  // ── Zamanlayıcılar ────────────────────────────────────────────────────────

  Timer? _lockTimer;
  Timer? _pickTimer;
  Timer? _resetTimer;
  Timer? _cycleTimer;

  /// Döngü animasyonu kaçıncı adımda — hız hesabı için kullanılır
  int _cycleStep = 0;

  final Random _random = Random();
  final SoundService _sound = SoundService();

  // ── Seçim aksiyonları ─────────────────────────────────────────────────────

  /// Oyuncu sayısını seçer; geçersiz hale gelen kazanan seçimini sıfırlar
  void selectPlayerCount(int count) {
    pendingPlayerCount = count;
    // Kazanan sayısı geçersiz hale geldiyse temizle
    if (selectedWinnerCount != null && selectedWinnerCount! >= count) {
      selectedWinnerCount = null;
    }
    notifyListeners();
  }

  /// Kazanan sayısını seçer ve oyun ekranına geçiş yapar
  void selectWinnerCount(int count) {
    final playerCount = pendingPlayerCount;
    if (playerCount == null) return;
    selectedPlayerCount = playerCount;
    selectedWinnerCount = count;
    phase = GamePhase.waiting;
    notifyListeners();
  }

  /// Her şeyi sıfırlar ve seçim ekranına döner
  void changeSettings() {
    _cancelAllTimers();
    activePointers.clear();
    pointerColors.clear();
    lockedPointerIds = [];
    winnerPointerIds = [];
    phase = GamePhase.setup;
    pendingPlayerCount = null;
    selectedPlayerCount = null;
    selectedWinnerCount = null;
    showReset = false;
    highlightIndex = 0;
    notifyListeners();
  }

  // ── Pointer olayları ──────────────────────────────────────────────────────

  void handlePointerDown(PointerDownEvent event) {
    final target = selectedPlayerCount;
    if (target == null) return;
    if (phase == GamePhase.locked ||
        phase == GamePhase.revealed ||
        phase == GamePhase.choosing ||
        showReset) {
      return;
    }
    if (activePointers.length >= target) return;

    // Sol üst köşedeki geri butonu alanına denk gelen dokunuşları yoksay
    final pos = event.localPosition;
    if (pos.dx < 80 && pos.dy < 80) return;

    activePointers[event.pointer] = event.localPosition;
    pointerColors.putIfAbsent(event.pointer, _randomPastelColor);
    notifyListeners();

    if (activePointers.length == target) {
      _startGame();
    }
  }

  void handlePointerMove(PointerMoveEvent event) {
    if (!activePointers.containsKey(event.pointer)) return;
    activePointers[event.pointer] = event.localPosition;
    notifyListeners();
  }

  void handlePointerUp(PointerUpEvent event) => _handleRelease(event.pointer);

  void handlePointerCancel(PointerCancelEvent event) =>
      _handleRelease(event.pointer);

  void _handleRelease(int pointer) {
    final isGameActive =
        phase == GamePhase.locked || phase == GamePhase.revealed;
    // Kilitlenmiş katılımcı parmağı kaldırılsa bile ekranda kalsın
    if (isGameActive && lockedPointerIds.contains(pointer)) return;
    activePointers.remove(pointer);
    if (!isGameActive) pointerColors.remove(pointer);
    notifyListeners();
  }

  // ── Oyun akışı ─────────────────────────────────────────────────────────────

  /// Adım 1 — Hedef sayıda parmak algılandı; 800ms sonra kilitleme başlar
  void _startGame() {
    phase = GamePhase.choosing;
    notifyListeners();
    _lockTimer = Timer(const Duration(milliseconds: 800), _lockPointers);
  }

  /// Adım 2 — Aktif parmak listesini kilitle (800ms sonra)
  void _lockPointers() {
    final currentIds = activePointers.keys.toList();

    if (currentIds.length < 2) {
      resetGame();
      return;
    }

    lockedPointerIds = currentIds;
    phase = GamePhase.locked;
    notifyListeners();

    _startCycleAnimation();
    _pickTimer = Timer(const Duration(seconds: 2), _pickWinners);
  }

  /// "Choosing..." sırasında daireleri sırayla vurgular (gerilim yaratır).
  /// İlk 1500ms hızlı (100ms), son 500ms easeOut ile yavaşlar (100→400ms).
  void _startCycleAnimation() {
    _cycleStep = 0;
    _scheduleCycle(0);
  }

  void _scheduleCycle(int elapsedMs) {
    if (elapsedMs >= 2000) return;

    const int fastPhaseEnd = 1500;
    const int minInterval = 100;
    const int maxInterval = 400;

    final int intervalMs;
    if (elapsedMs < fastPhaseEnd) {
      intervalMs = minInterval;
    } else {
      final double t =
          ((elapsedMs - fastPhaseEnd) / 500.0).clamp(0.0, 1.0);
      // easeOut quad: hızlı başlar, sona doğru yavaşlar
      final double eased = 1.0 - (1.0 - t) * (1.0 - t);
      intervalMs =
          (minInterval + (maxInterval - minInterval) * eased).round();
    }

    _cycleTimer = Timer(Duration(milliseconds: intervalMs), () {
      if (lockedPointerIds.isEmpty) return;
      highlightIndex = _cycleStep % lockedPointerIds.length;
      _cycleStep++;
      _sound.playTick();
      notifyListeners();
      _scheduleCycle(elapsedMs + intervalMs);
    });
  }

  /// Adım 3 — Kilitli listeden rastgele N kazanan seç
  void _pickWinners() {
    _cycleTimer?.cancel();

    if (lockedPointerIds.isEmpty) {
      resetGame();
      return;
    }

    // Seçilecek kazanan sayısı: seçilen değer ile katılımcı sayısının küçüğü
    final count = min(selectedWinnerCount ?? 1, lockedPointerIds.length);

    // Listeyi karıştırarak ilk N tanesini al — adil seçim
    final shuffled = List.of(lockedPointerIds)..shuffle(_random);
    winnerPointerIds = shuffled.take(count).toList();
    phase = GamePhase.revealed;

    // Kazanan anında titreşim + ses geri bildirimi
    HapticFeedback.heavyImpact();
    _sound.playWin();
    notifyListeners();

    // 2 saniye sonra reset butonlarını göster
    _resetTimer = Timer(const Duration(seconds: 2), () {
      showReset = true;
      notifyListeners();
    });
  }

  /// Oyunu sıfırla — seçili oyuncu/kazanan sayısını koru
  void resetGame() {
    _cancelAllTimers();
    activePointers.clear();
    pointerColors.clear();
    lockedPointerIds = [];
    winnerPointerIds = [];
    phase = GamePhase.waiting;
    showReset = false;
    highlightIndex = 0;
    notifyListeners();
  }

  // ── UI metin yardımcıları ─────────────────────────────────────────────────

  /// Oyun aşamasına göre ekran ortasında gösterilecek durum metni
  String get statusText => switch (phase) {
        GamePhase.revealed =>
          (selectedWinnerCount ?? 1) > 1 ? 'Winners!' : 'Winner!',
        GamePhase.choosing || GamePhase.locked => 'Choosing...',
        GamePhase.waiting => _waitingStatusText(),
        GamePhase.setup => '',
      };

  String _waitingStatusText() {
    final count = activePointers.length;
    final target = selectedPlayerCount ?? 0;
    if (count == 0) return 'Put $target fingers';
    final needed = target - count;
    if (needed <= 0) return 'Get ready...';
    return '$needed more finger${needed > 1 ? 's' : ''}...';
  }

  /// Oyun ekranı üst kısmındaki kısa bilgi etiketi
  String get gameInfoLabel {
    final p = selectedPlayerCount ?? 0;
    final w = selectedWinnerCount ?? 1;
    return '$p Players · $w Winner${w > 1 ? 's' : ''}';
  }

  // ── Yardımcılar ───────────────────────────────────────────────────────────

  /// Mevcut renklerden yeterince farklı rastgele bir pastel renk üretir
  Color _randomPastelColor() {
    final usedHues =
        pointerColors.values.map((c) => HSLColor.fromColor(c).hue).toList();
    double hue;
    int tries = 0;
    do {
      hue = _random.nextDouble() * 360;
      tries++;
    } while (usedHues.any((h) => (h - hue).abs() < 40) && tries < 30);
    return HSLColor.fromAHSL(1.0, hue, 0.65, 0.80).toColor();
  }

  void _cancelAllTimers() {
    _lockTimer?.cancel();
    _pickTimer?.cancel();
    _resetTimer?.cancel();
    _cycleTimer?.cancel();
  }

  @override
  void dispose() {
    _cancelAllTimers();
    _sound.dispose();
    super.dispose();
  }
}
