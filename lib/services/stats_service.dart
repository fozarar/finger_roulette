import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Kalıcı kullanım sayaçlarını tutar.
///
/// İki işi var:
///  1. [gamesPlayed] sayacını saklar — [ReviewService] puan isteme anını
///     buna göre belirler.
///  2. [logEvent] ile tek bir analitik dikiş noktası sunar. Şu an sadece
///     debug modda log basar; Firebase Analytics eklendiğinde yalnızca bu
///     metodun gövdesi değişir, çağrı yerlerine dokunulmaz.
///
/// [init] uygulama açılışında bir kez çağrılmalıdır; sonrasında tüm okumalar
/// senkrondur, böylece oyun akışı `await` beklemez.
class StatsService {
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

  /// Bir oyun kazananı açıklanınca çağrılır; sayacı artırıp yeni değeri döner
  Future<int> recordGameCompleted({
    required int playerCount,
    required int winnerCount,
  }) async {
    final next = gamesPlayed + 1;
    await _prefs?.setInt(_kGamesPlayed, next);
    logEvent('game_completed', {
      'players': playerCount,
      'winners': winnerCount,
      'total_games': next,
    });
    return next;
  }

  /// Analitik dikiş noktası.
  ///
  /// Firebase Analytics bağlanacağı zaman tek yapılacak, bu gövdeyi
  /// `FirebaseAnalytics.instance.logEvent(...)` ile değiştirmek.
  void logEvent(String name, [Map<String, Object?> params = const {}]) {
    if (kDebugMode) {
      debugPrint('[analytics] $name $params');
    }
  }
}
