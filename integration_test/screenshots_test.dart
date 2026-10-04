import 'package:finger_roulette/app/app.dart';
import 'package:finger_roulette/services/names_service.dart';
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
      FingerRouletteApp(
        stats: StatsService(),
        review: ReviewService(),
        nameStore: NamesService(),
      ),
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

  testWidgets('isim listesi ve çark', (tester) async {
    if (_locale.isNotEmpty) {
      binding.platformDispatcher.localesTestValue = [Locale(_locale)];
    }
    await tester.pumpWidget(
      FingerRouletteApp(
        stats: StatsService(),
        review: ReviewService(),
        nameStore: NamesService(),
      ),
    );
    await settle(tester);

    // İsim alanı odaktayken imleç yanıp söndüğü için kare akışı hiç durulmaz;
    // bu bölümde pumpAndSettle yerine sabit süreli pump kullanılıyor.
    Future<void> tapAndPump(Finder finder) async {
      await tester.tap(finder);
      await tester.pump(const Duration(milliseconds: 350));
    }

    // Girdiyi isim listesine çevir ve kadroyu yaz
    await tapAndPump(find.byIcon(Icons.format_list_bulleted_rounded));
    // Her dilde doğal duran kısa isimler: görseller tek setten üretiliyor
    for (final name in const ['Alex', 'Sam', 'Mia', 'Leo', 'Zoe', 'Max']) {
      await tester.enterText(find.byType(TextField), name);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump(const Duration(milliseconds: 250));
    }
    // Görüntüde imleç durmasın
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump(const Duration(milliseconds: 400));
    await shot(tester, '5_names_select');

    // Kaç kazanan → çark ekranı
    await tapAndPump(find.text('1'));
    await shot(tester, '6_wheel_idle');

    // Çevir: dönüşün ortası ve sonucu
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump(const Duration(milliseconds: 900));
    await shot(tester, '7_wheel_spinning');
    await tester.pump(const Duration(milliseconds: 1600));
    await shot(tester, '8_wheel_revealed');
    await tester.pump(const Duration(milliseconds: 1800));
    await shot(tester, '9_wheel_buttons');

    // Sıra modu aynı listeyle: çark durunca ekranı listeye bırakıyor. Hizalama
    // bir kez tam burada bozulmuştu — seç modunda çark tam genişlik olduğu için
    // görünmüyordu, liste görünümünde sütun sola yapışıyordu.
    await tapAndPump(find.byType(TextButton));
    await tapAndPump(find.byIcon(Icons.format_list_numbered_rounded));
    await tapAndPump(find.byType(ElevatedButton));
    await tester.tap(find.byType(ElevatedButton));
    // Dönüş bitince çark seçilen ismi gösteriyor; liste butonlarla birlikte
    // iki saniye sonra geliyor, kare ondan sonra alınmalı
    await tester.pump(const Duration(milliseconds: 2400));
    await shot(tester, '10_order_names_selected');
    await tester.pump(const Duration(milliseconds: 2200));
    await shot(tester, '11_order_names_list');

    // Takım modu aynı listeyle: altı isim üç takıma yetiyor, soru çıkmalı
    await tapAndPump(find.byType(TextButton));
    await tapAndPump(find.byIcon(Icons.groups_outlined));
    await shot(tester, '12_teams_names_select');
    await tapAndPump(find.text('3'));
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump(const Duration(milliseconds: 4600));
    await shot(tester, '13_teams_names_three');

    // Sekiz isimle dört takım: sonuç 2×2 diziliyor
    await tapAndPump(find.byType(TextButton));
    for (final name in const ['Ava', 'Eli']) {
      await tester.enterText(find.byType(TextField), name);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump(const Duration(milliseconds: 250));
    }
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump(const Duration(milliseconds: 400));
    await tapAndPump(find.text('4'));
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump(const Duration(milliseconds: 4600));
    await shot(tester, '14_teams_names_four');
    // Kazanma sesi bitsin: audioplayers'ın kare geri çağrısı test sonrasına
    // taşarsa çerçeve "animasyon hâlâ çalışıyor" diye testi düşürüyor
    await tester.pump(const Duration(seconds: 2));
  });
}
