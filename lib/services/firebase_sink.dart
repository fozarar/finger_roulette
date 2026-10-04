import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'stats_service.dart';

/// Geliştirme derlemeleri veri göndermez; raporlar yalnızca gerçek
/// kullanıcıları göstersin. Denemek için:
/// `flutter run --dart-define=ANALYTICS=true`
const bool analyticsEnabled =
    kReleaseMode || bool.fromEnvironment('ANALYTICS');

/// Firebase'i başlatır ve olayları Analytics'e taşıyan fonksiyonu döndürür.
///
/// Başlatılamazsa null döner ve [StatsService] olayları yutar: oyun analitik
/// olmadan da, internet olmadan da oynanabilir olmalı. Olaylar cihazda
/// biriktirilip bağlantı gelince gönderildiği için çağrı hiç beklemez.
Future<AnalyticsSink?> connectFirebaseAnalytics() async {
  if (!analyticsEnabled) return null;
  try {
    // Timeout: başlatma takılırsa splash'te sonsuza dek asılı kalmayalım
    await Firebase.initializeApp().timeout(const Duration(seconds: 3));
    return _FirebaseSink(FirebaseAnalytics.instance);
  } catch (e) {
    debugPrint('Analytics: Firebase başlatılamadı, olay gönderilmeyecek ($e)');
    return null;
  }
}

class _FirebaseSink implements AnalyticsSink {
  _FirebaseSink(this._analytics);

  final FirebaseAnalytics _analytics;

  @override
  void log(String name, Map<String, Object> params) {
    unawaited(
      _analytics.logEvent(name: name, parameters: params).catchError(
        (Object e) => debugPrint('Analytics: $name gönderilemedi ($e)'),
      ),
    );
  }

  @override
  Future<void> setEnabled(bool enabled) async {
    try {
      await _analytics.setAnalyticsCollectionEnabled(enabled);
    } catch (e) {
      debugPrint('Analytics: toplama ayarı uygulanamadı ($e)');
    }
  }
}
