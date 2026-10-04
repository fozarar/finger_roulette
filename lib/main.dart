import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'app/app.dart';
import 'services/firebase_sink.dart';
import 'services/names_service.dart';
import 'services/review_service.dart';
import 'services/stats_service.dart';

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  // Native splash'i Flutter hazır olana kadar tut, sonra kaldır
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  // Tam ekran mod — sistem çubuklarını gizle
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Kalıcı depolamayı ilk frame'den önce hazırla; böylece oyun akışı
  // sırasında async bekleme olmaz. Hepsi hata durumunda sessizce devre
  // dışı kalır — oyun her hâlükârda oynanabilir. Analitik de böyle:
  // Firebase başlamazsa olaylar yutulur.
  final stats = StatsService(sink: await connectFirebaseAnalytics());
  final review = ReviewService();
  final nameStore = NamesService();
  await stats.init();
  await review.init();
  await nameStore.init();

  runApp(FingerRouletteApp(stats: stats, review: review, nameStore: nameStore));
  // İlk frame çizildikten sonra splash'i kaldır — erken kaldırınca siyah ekran çıkar
  WidgetsBinding.instance.addPostFrameCallback((_) {
    FlutterNativeSplash.remove();
  });
}
