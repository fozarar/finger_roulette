import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/game_mode.dart';
import '../models/game_phase.dart';
import '../services/review_service.dart';
import '../services/sound_service.dart';
import '../services/stats_service.dart';

/// Tüm oyun mantığını ve durumunu yönetir.
///
/// [ChangeNotifier] arayüzü üzerinden UI katmanına değişiklik bildirir.
/// Animasyon controller'ları vsync gerektirdiğinden widget katmanında kalır;
/// bu sınıf yalnızca oyun iş mantığından sorumludur.
class GameController extends ChangeNotifier {
  // ── Sonuç renkleri ────────────────────────────────────────────────────────

  /// Takım renkleri: sırayla A ve B takımı. Mavi/turuncu çifti renk
  /// körlüğünde de ayırt edilir; daireler ayrıca takım harfini gösterir.
  static const List<Color> teamColors = [
    Color(0xFF4FC3F7),
    Color(0xFFFF8A65),
  ];

  /// Kaybeden seçildiğinde dairenin aldığı renk
  static const Color loserColor = Color(0xFFFF5252);

  /// Takım modunda kurulan takım sayısı. En fazla 5 parmakla üçüncü bir
  /// takım tek kişilik kalacağından şimdilik seçtirilmiyor.
  static const int teamCount = 2;

  /// Parmaklar kilitlendikten sonra sonucun açıklanmasına kadar geçen süre.
  /// Rulet ışını da tam bu sürede döner — [HomeScreen] animasyonun süresini
  /// buradan okur, yoksa ışın hedefe inmeden sonuç açıklanır.
  static const Duration spinDuration = Duration(seconds: 2);

  // ── Seçim durumu ──────────────────────────────────────────────────────────

  /// Oyunun hangi soruya cevap verdiği; ayarlar değişse de korunur
  GameMode mode = GameMode.pick;

  /// Seç modunda seçilenler kazanan mı kaybeden mi; ayarlar değişse de korunur
  PickOutcome outcome = PickOutcome.winners;

  /// Oyuncu sayısı seçildi, kaç kişi seçileceği henüz belirlenmedi
  int? pendingPlayerCount;

  /// Onaylanan oyuncu sayısı (seçim tamamlandıktan sonra set edilir)
  int? selectedPlayerCount;

  /// Onaylanan kazanan ya da kaybeden sayısı; takım ve sıra modlarında null
  int? selectedPickCount;

  // ── Oyun durumu ───────────────────────────────────────────────────────────

  GamePhase phase = GamePhase.setup;

  /// Aktif parmaklar: pointerId → ekrandaki konum
  final Map<int, Offset> activePointers = {};

  /// Her pointer için rastgele atanmış pastel renk. Sonuç açıklanınca
  /// takım ve kaybeden renkleri bunun üzerine yazılır.
  final Map<int, Color> pointerColors = {};

  /// 800ms sonra kilitlenen katılımcı pointer listesi
  List<int> lockedPointerIds = [];

  /// True olduğunda "Play Again" / "Change Settings" butonları gösterilir
  bool showReset = false;

  // ── Sonuç — moda göre yalnızca biri dolar ─────────────────────────────────

  /// Seç modunda seçilen pointer ID'leri (kazananlar ya da kaybedenler)
  List<int> pickedPointerIds = [];

  /// Takım modunda her pointer'ın takım indeksi (0 = A takımı)
  Map<int, int> teamOfPointer = {};

  /// Sıra modunda pointer'lar sırasıyla; ilk eleman 1. sırada
  List<int> rankedPointerIds = [];

  // ── Çekilmiş ama henüz açıklanmamış sonuç ────────────────────────────────

  /// Çekiliş parmaklar kilitlenirken yapılır, sonuç 2 saniye sonra açıklanır:
  /// ışının nereye ineceğinin dönüş başlamadan belli olması gerekir. Sonuç o
  /// arada burada bekler; yukarıdaki alanlar boş kaldığı için UI erken
  /// açıklama yapmaz.
  List<int> _drawnPickedIds = [];
  Map<int, int> _drawnTeams = {};
  List<int> _drawnRankedIds = [];

  /// Işının üstünde duracağı parmak: seç modunda seçilenlerin ilki, sıra
  /// modunda birinci. Takım modunda kimse öne çıkmadığı için null — ışın
  /// kimseyi işaret etmeden başladığı yerde durur.
  int? spinTargetPointerId;

  // ── Zamanlayıcılar ────────────────────────────────────────────────────────

  Timer? _lockTimer;
  Timer? _pickTimer;
  Timer? _resetTimer;

  final Random _random;
  final SoundService _sound;
  final StatsService _stats;
  final ReviewService _review;

  /// Sonuç açıklandığında başlayan sayaç güncellemesi.
  /// Puan isteme anında beklenir; böylece güncel oyun sayısıyla karar verilir.
  Future<int>? _pendingGameCount;

  bool _disposed = false;

  /// Servisler dışarıdan verilebilir — testlerde sahte implementasyonlar için
  GameController({
    Random? random,
    SoundService? sound,
    StatsService? stats,
    ReviewService? review,
  })  : _random = random ?? Random(),
        _sound = sound ?? SoundService(),
        _stats = stats ?? StatsService(),
        _review = review ?? ReviewService();

  /// Açıklamada öne çıkan pointer'lar: büyür, parlar, konfeti onlardan çıkar.
  /// Takım modunda herkes bir takıma düştüğü için hepsi, sıra modunda birinci.
  /// Sonuç açıklanmadan önce boştur.
  List<int> get spotlightPointerIds => switch (mode) {
        GameMode.pick => pickedPointerIds,
        GameMode.teams => teamOfPointer.keys.toList(),
        GameMode.order => rankedPointerIds.take(1).toList(),
      };

  // ── Seçim aksiyonları ─────────────────────────────────────────────────────

  /// Oyun modunu değiştirir. Oyuncu seçenekleri moda göre değiştiği için
  /// yarım kalan seçim sıfırlanır.
  void selectMode(GameMode newMode) {
    if (newMode == mode) return;
    mode = newMode;
    pendingPlayerCount = null;
    selectedPickCount = null;
    notifyListeners();
  }

  /// Seçilenlerin kazanan mı kaybeden mi olduğunu değiştirir.
  /// Çekiliş değişmediği için yarım kalan seçim korunur.
  void selectOutcome(PickOutcome newOutcome) {
    if (newOutcome == outcome) return;
    outcome = newOutcome;
    notifyListeners();
  }

  /// Oyuncu sayısını seçer; sorulacak başka soru yoksa oyun ekranına geçer
  void selectPlayerCount(int count) {
    pendingPlayerCount = count;
    // Takım ve sıra modları herkese bir sonuç verir, başka soru sormaz
    if (!mode.picksSubset) {
      _confirmSelection(pickCount: null);
      return;
    }
    // Seçilecek kişi sayısı geçersiz hale geldiyse temizle
    if (selectedPickCount != null && selectedPickCount! >= count) {
      selectedPickCount = null;
    }
    // 2 oyuncuda seçilecek kişi zaten 1, seçim ekranını atla
    if (count == 2) {
      selectPickCount(1);
      return;
    }
    notifyListeners();
  }

  /// Kaç kişinin seçileceğini belirler ve oyun ekranına geçer
  void selectPickCount(int count) => _confirmSelection(pickCount: count);

  void _confirmSelection({required int? pickCount}) {
    final playerCount = pendingPlayerCount;
    if (playerCount == null) return;
    selectedPlayerCount = playerCount;
    selectedPickCount = pickCount;
    phase = GamePhase.waiting;
    notifyListeners();
  }

  /// Her şeyi sıfırlar ve seçim ekranına döner — mod ve kazanan/kaybeden korunur
  void changeSettings() {
    _clearRound();
    phase = GamePhase.setup;
    pendingPlayerCount = null;
    selectedPlayerCount = null;
    selectedPickCount = null;
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
    // Sonucu şimdi çek: ışın hedefini bilmeden dönemez
    _drawResult();
    phase = GamePhase.locked;
    notifyListeners();

    _pickTimer = Timer(spinDuration, _reveal);
  }

  /// Sonucu çeker ama yayımlamaz — ışın dönerken sonuç zaten bellidir.
  ///
  /// Çekilişin kilitlenme anına alınması rastgeleliği değiştirmez: kilit ile
  /// açıklama arasında yeni parmak kabul edilmediği için aradaki 2 saniyede
  /// sonucu etkileyecek hiçbir şey olmaz.
  void _drawResult() {
    // Her mod karıştırılmış listeden okur — her parmağın şansı eşit
    final shuffled = List.of(lockedPointerIds)..shuffle(_random);

    switch (mode) {
      case GameMode.pick:
        // Seçilecek sayı: seçilen değer ile katılımcı sayısının küçüğü
        final count = min(selectedPickCount ?? 1, shuffled.length);
        _drawnPickedIds = shuffled.take(count).toList();
        // Birden fazla kişi seçildiyse ışın ilkinin üstünde durur, kalanlar
        // onunla birlikte açıklanır
        spinTargetPointerId = _drawnPickedIds.first;
      case GameMode.teams:
        // Sırayla dağıtmak takımları dengeler: boyutlar en fazla 1 farklı
        _drawnTeams = {
          for (var i = 0; i < shuffled.length; i++) shuffled[i]: i % teamCount,
        };
        spinTargetPointerId = null;
      case GameMode.order:
        _drawnRankedIds = shuffled;
        spinTargetPointerId = shuffled.first;
    }
  }

  /// Işın bir parmağın üstünden geçtiğinde UI katmanı tarafından çağrılır.
  ///
  /// Sesi ve titreşimi controller çalar (servisler burada), ama "hangi anda"
  /// sorusunun cevabı geometride: ışının o karede hangi parmağı gösterdiğini
  /// [SpinBeam] hesaplar. Tik'leri ayrı bir zamanlayıcıyla taklit etmek yerine
  /// gerçek geçişi kullanmak sesi görüntüye birebir bağlar.
  void playSpinTick() {
    if (phase != GamePhase.locked) return;
    _sound.playTick();
    HapticFeedback.selectionClick();
  }

  /// Adım 3 — Işın hedefe indi; çekilen sonucu açıkla
  void _reveal() {
    if (lockedPointerIds.isEmpty) {
      resetGame();
      return;
    }

    switch (mode) {
      case GameMode.pick:
        pickedPointerIds = _drawnPickedIds;
        // Kaybedenler kırmızıya döner; kazananlar kendi renginde parlar
        if (outcome == PickOutcome.losers) {
          for (final id in pickedPointerIds) {
            pointerColors[id] = loserColor;
          }
        }
      case GameMode.teams:
        teamOfPointer = _drawnTeams;
        teamOfPointer.forEach((id, team) => pointerColors[id] = teamColors[team]);
      case GameMode.order:
        rankedPointerIds = _drawnRankedIds;
    }
    phase = GamePhase.revealed;

    // Sonuç anında titreşim + ses geri bildirimi
    HapticFeedback.heavyImpact();
    _sound.playWin();
    notifyListeners();

    _pendingGameCount = _stats.recordGameCompleted(
      mode: mode,
      outcome: mode.picksSubset ? outcome : null,
      playerCount: lockedPointerIds.length,
      pickCount: mode.picksSubset ? pickedPointerIds.length : null,
    );

    // 2 saniye sonra reset butonlarını göster
    _resetTimer = Timer(const Duration(seconds: 2), () async {
      if (_disposed) return;
      showReset = true;
      notifyListeners();

      // Puan isteme için doğru an: kutlama bitti, kullanıcı ne yapacağına
      // karar veriyor. Oyunun ortasında asla sorulmaz.
      final played = await _pendingGameCount;
      if (_disposed || played == null) return;
      await _review.maybeRequestReview(played);
    });
  }

  /// Oyunu sıfırla — seçili mod, oyuncu ve kazanan sayısını koru
  void resetGame() {
    _clearRound();
    phase = GamePhase.waiting;
    notifyListeners();
  }

  // ── Yardımcılar ───────────────────────────────────────────────────────────

  /// Parmakları, sonucu ve zamanlayıcıları temizler; seçimlere dokunmaz
  void _clearRound() {
    _cancelAllTimers();
    activePointers.clear();
    pointerColors.clear();
    lockedPointerIds = [];
    pickedPointerIds = [];
    teamOfPointer = {};
    rankedPointerIds = [];
    _drawnPickedIds = [];
    _drawnTeams = {};
    _drawnRankedIds = [];
    spinTargetPointerId = null;
    showReset = false;
  }

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
  }

  @override
  void dispose() {
    _disposed = true;
    _cancelAllTimers();
    _sound.dispose();
    super.dispose();
  }
}
