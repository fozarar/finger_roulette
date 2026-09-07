import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App Store puan isteme akışını yönetir.
///
/// Zamanlama kritik: iOS sistem prompt'unu kullanıcı başına yılda en fazla
/// 3 kez gösterir ve gösterileceğinin garantisi yoktur. Bu yüzden istek
/// yalnızca kullanıcının uygulamayı sevdiğine dair sinyal verdiği anda —
/// kazanan açıklandıktan ve en az [_firstPromptAfterGames] oyun
/// tamamlandıktan sonra — yapılır. Oyunun ortasında asla sorulmaz.
class ReviewService {
  static const String _kLastPromptMs = 'review_last_prompt_ms';
  static const String _kPromptCount = 'review_prompt_count';

  /// İlk istek: kullanıcı oyunu gerçekten anladıktan sonra
  static const int _firstPromptAfterGames = 3;

  /// Reddeden/görmeyen kullanıcıya tekrar sorma eşiği
  static const int _repeatPromptEveryGames = 25;

  /// İki istek arasındaki asgari süre — iOS'un yıllık 3 hakkını harcamamak için
  static const Duration _minGapBetweenPrompts = Duration(days: 120);

  /// Toplamda kaç kez sorulacağı (iOS zaten yılda 3 ile sınırlıyor)
  static const int _maxPrompts = 3;

  final InAppReview _inAppReview;
  SharedPreferences? _prefs;

  ReviewService({InAppReview? inAppReview})
      : _inAppReview = inAppReview ?? InAppReview.instance;

  Future<void> init() async {
    try {
      // Timeout: depolama takılırsa splash'te sonsuza dek asılı kalmayalım
      _prefs = await SharedPreferences.getInstance()
          .timeout(const Duration(seconds: 2));
    } catch (e) {
      debugPrint('ReviewService: depolama açılamadı ($e)');
    }
  }

  /// [gamesPlayed] sayısına göre şimdi puan istenmeli mi?
  ///
  /// Saf fonksiyon — test edilebilir olması için ayrı tutuldu.
  @visibleForTesting
  bool shouldPrompt({
    required int gamesPlayed,
    required int promptCount,
    required int? lastPromptMs,
    required DateTime now,
  }) {
    if (promptCount >= _maxPrompts) return false;
    if (gamesPlayed < _firstPromptAfterGames) return false;

    // Hiç sorulmadıysa: eşiği geçtiği ilk anda sor
    if (promptCount == 0) return gamesPlayed >= _firstPromptAfterGames;

    // Daha önce sorulduysa: hem yeterli oyun geçmeli hem yeterli zaman
    if (gamesPlayed < _firstPromptAfterGames +
        _repeatPromptEveryGames * promptCount) {
      return false;
    }
    if (lastPromptMs == null) return true;
    final since =
        now.difference(DateTime.fromMillisecondsSinceEpoch(lastPromptMs));
    return since >= _minGapBetweenPrompts;
  }

  /// Koşullar uygunsa sistem puan prompt'unu gösterir.
  ///
  /// Hiçbir durumda hata fırlatmaz — puan isteme oyunu bozmamalı.
  Future<void> maybeRequestReview(int gamesPlayed) async {
    final prefs = _prefs;
    if (prefs == null) return;

    final promptCount = prefs.getInt(_kPromptCount) ?? 0;
    final lastPromptMs = prefs.getInt(_kLastPromptMs);

    if (!shouldPrompt(
      gamesPlayed: gamesPlayed,
      promptCount: promptCount,
      lastPromptMs: lastPromptMs,
      now: DateTime.now(),
    )) {
      return;
    }

    try {
      if (!await _inAppReview.isAvailable()) return;
      await _inAppReview.requestReview();
      // Prompt gerçekten gösterildi mi bilemeyiz (iOS söylemez); yine de
      // saydırıyoruz ki kullanıcıyı her oyunda yeniden rahatsız etmeyelim.
      await prefs.setInt(_kPromptCount, promptCount + 1);
      await prefs.setInt(
        _kLastPromptMs,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      debugPrint('ReviewService: puan istenemedi ($e)');
    }
  }
}
