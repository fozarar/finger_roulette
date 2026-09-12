import 'package:finger_roulette/app/app.dart';
import 'package:finger_roulette/services/review_service.dart';
import 'package:finger_roulette/services/stats_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Her modu gerçek uygulamada sentetik parmaklarla oynatıp ekran görüntüsü alır.
///
/// Simülatör aynı anda en fazla iki dokunuş verebiliyor; 3+ oyunculu ekranlar
/// ancak böyle görülebilir. App Store görselleri de buradan üretilebilir:
///
///   flutter drive --driver=test_driver/integration_test.dart \
///     --target=integration_test/screenshots_test.dart -d "iPhone 14" \
///     --dart-define=SCREENSHOT_LOCALE=tr
///
/// Dil verilmezse cihazın dili kullanılır. Görseller build/screenshots/
/// altına yazılır (SCREENSHOT_DIR ile değişir).
const _locale = String.fromEnvironment('SCREENSHOT_LOCALE');

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // Animasyonlar ve konfeti gerçek zamanlı aksın; aksi halde yalnızca
  // pump edilen kareler çizilir ve açıklama anı donuk görünür
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  /// Masanın etrafındaki insanlar gibi dağınık parmak konumları
  const fingerSpots = [
    Offset(95, 360),
    Offset(295, 330),
    Offset(320, 560),
    Offset(80, 575),
    Offset(200, 180),
  ];

  Future<void> shot(WidgetTester tester, String name) async {
    await tester.pump();
    await binding.takeScreenshot(name);
  }

  /// Bir şey takılırsa 10 dakika beklemek yerine hemen düşsün
  Future<void> settle(WidgetTester tester) => tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        const Duration(seconds: 15),
      );

  Future<void> choose(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await settle(tester);
  }

  /// [count] parmağı koyar ve iki kare çeker: döngü dönerken ve açıklamadan
  /// hemen sonra. Ardından seçim ekranına döner.
  Future<void> playRound(WidgetTester tester, String name, int count) async {
    final gestures = [
      for (final spot in fingerSpots.take(count))
        await tester.startGesture(spot),
    ];
    // Kilitlenince (800ms) parmaklar kalkabilir, daireler yerinde kalır.
    // Kaldırmak test çerçevesinin dokunuş işaretlerini de görüntüden siler.
    await tester.pump(const Duration(milliseconds: 1000));
    for (final gesture in gestures) {
      await gesture.up();
    }
    // Döngünün ortası
    await tester.pump(const Duration(milliseconds: 700));
    await shot(tester, '${name}_choosing');
    // Açıklama 2800ms'de: büyüme bitmiş, konfeti havada
    await tester.pump(const Duration(milliseconds: 1800));
    await shot(tester, '${name}_revealed');
    // Butonlar gelsin, sonra seçim ekranına dön
    await tester.pump(const Duration(milliseconds: 1800));
    await tester.tap(find.byIcon(Icons.close));
    await settle(tester);
  }

  testWidgets('her modun ekran görüntüleri', (tester) async {
    if (_locale.isNotEmpty) {
      binding.platformDispatcher.localesTestValue = [Locale(_locale)];
    }
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await tester.pumpWidget(
      // init() çağrılmadı: sayaç ve puan isteme sessizce devre dışı
      FingerRouletteApp(stats: StatsService(), review: ReviewService()),
    );
    await settle(tester);
    await shot(tester, '0_select');

    // Seç modu, kazanan: 5 oyuncu, 2 kazanan
    await choose(tester, find.text('5'));
    await shot(tester, '1_winners_select');
    await choose(tester, find.text('2').last);
    await playRound(tester, '1_winners', 5);

    // Aynı mod, kaybeden düğmesi: 4 oyuncu, 1 kaybeden
    await choose(tester, find.byIcon(Icons.sentiment_very_dissatisfied_outlined));
    await choose(tester, find.text('4'));
    await shot(tester, '2_losers_select');
    await choose(tester, find.text('1'));
    await playRound(tester, '2_losers', 4);

    // Takım: 5 oyuncu
    await choose(tester, find.byIcon(Icons.groups_outlined));
    await shot(tester, '3_teams_select');
    await choose(tester, find.text('5'));
    await playRound(tester, '3_teams', 5);

    // Sıra: 4 oyuncu
    await choose(tester, find.byIcon(Icons.format_list_numbered_rounded));
    await shot(tester, '4_order_select');
    await choose(tester, find.text('4'));
    await playRound(tester, '4_order', 4);
  });
}
