import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_mode.dart';
import '../models/input_source.dart';

/// Kalıcı kullanım sayaçlarını tutar.
///
/// İki işi var:
///  1. [gamesPlayed] sayacını saklar — [ReviewService] puan isteme anını
///     buna göre belirler.
///  2. [logEvent] ile tek bir analitik dikiş noktası sunar. Olaylar
///     [AnalyticsSink]'e gider; onu `main()` Firebase Analytics'e bağlar.
///     Bu sınıf Firebase'i tanımaz, böylece testler platform kanalına
///     dokunmadan çalışır.
///
/// [init] uygulama açılışında bir kez çağrılmalıdır; sonrasında tüm okumalar
/// senkrondur, böylece oyun akışı `await` beklemez.
class StatsService {
  /// [sink] verilmezse olaylar hiçbir yere gitmez: testlerde ve ekran
  /// görüntüsü üretiminde istenen de bu.
  StatsService({AnalyticsSink? sink}) : _sink = sink;

  final AnalyticsSink? _sink;

  static const String _kGamesPlayed = 'stats_games_played';
  static const String _kLaunchCount = 'stats_launch_count';
  static const String _kFirstLaunchMs = 'stats_first_launch_ms';

  SharedPreferences? _prefs;

  /// Uygulama açılışında bir kez çağrılır. Depolama erişilemezse sessizce
  /// devre dışı kalır — oyun her hâlükârda oynanabilir olmalı.
  Future<void> init() async {
    try {
      // Timeout: depolama takılırsa splash'te sonsuza dek asılı kalmayalım
      _prefs = await SharedPreferences.getInstance()
          .timeout(const Duration(seconds: 2));
    } catch (e) {
      debugPrint('StatsService: depolama açılamadı, sayaçlar devre dışı ($e)');
      return;
    }
    final prefs = _prefs!;
    await prefs.setInt(_kLaunchCount, (prefs.getInt(_kLaunchCount) ?? 0) + 1);
    if (prefs.getInt(_kFirstLaunchMs) == null) {
      await prefs.setInt(
        _kFirstLaunchMs,
        DateTime.now().millisecondsSinceEpoch,
      );
    }
  }

  /// Bugüne kadar sonuna kadar oynanmış oyun sayısı
  int get gamesPlayed => _prefs?.getInt(_kGamesPlayed) ?? 0;

  /// Uygulamanın kaç kez açıldığı
  int get launchCount => _prefs?.getInt(_kLaunchCount) ?? 0;

  /// Bir oyunun sonucu açıklanınca çağrılır; sayacı artırıp yeni değeri döner.
  /// [outcome] ve [pickCount] yalnızca seç modunda anlamlı.
  Future<int> recordGameCompleted({
    required GameMode mode,
    required InputSource input,
    required int playerCount,
    PickOutcome? outcome,
    int? pickCount,
  }) async {
    final next = gamesPlayed + 1;
    await _prefs?.setInt(_kGamesPlayed, next);
    logEvent('game_completed', {
      'mode': mode.name,
      'input': input.name,
      'outcome': ?outcome?.name,
      'players': playerCount,
      'picks': ?pickCount,
      'total_games': next,
    });
    return next;
  }

  /// Hangi ekranın açıldığını bildirir. Uygulama tek sayfa üzerinde
  /// çalıştığı için Firebase ekran değişimini kendi göremez; ekran başına
  /// geçirilen süreyi bu olaydan hesaplar.
  void logScreen(String screenName) =>
      logEvent('screen_view', {'screen_name': screenName});

  /// Paylaşım menüsü kapanınca çağrılır. [status] kullanıcının paylaşıp
  /// paylaşmadığı, [method] iOS'un bildirdiği hedef (ör. fotoğraflara kayıt).
  void recordShare({
    required GameMode mode,
    required InputSource input,
    required String status,
    String? method,
  }) {
    logEvent('share', {
      'content_type': 'result_card',
      'mode': mode.name,
      'input': input.name,
      'status': status,
      'method': ?method,
    });
  }

  /// Analitik dikiş noktası: tüm olaylar buradan geçer
  void logEvent(String name, [Map<String, Object?> params = const {}]) {
    if (kDebugMode) {
      debugPrint('[analytics] $name $params');
    }
    _sink?.call(name, {
      for (final MapEntry(:key, :value) in params.entries) key: ?value,
    });
  }
}

/// Olayları gerçek analitik servisine taşıyan fonksiyon. Değerler yalnızca
/// metin ya da sayı olmalı — Firebase başka tür kabul etmiyor.
typedef AnalyticsSink = void Function(String name, Map<String, Object> params);
