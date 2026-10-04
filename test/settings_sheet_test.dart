import 'package:finger_roulette/l10n/app_localizations.dart';
import 'package:finger_roulette/services/sound_service.dart';
import 'package:finger_roulette/services/stats_service.dart';
import 'package:finger_roulette/widgets/settings_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _RecordingSink implements AnalyticsSink {
  final List<String> sent = [];
  final List<bool> enabledCalls = [];

  @override
  void log(String name, Map<String, Object> params) => sent.add(name);

  @override
  Future<void> setEnabled(bool enabled) async => enabledCalls.add(enabled);
}

void main() {
  late _RecordingSink sink;
  late StatsService stats;
  late SoundService sound;

  final usageTile = find.byKey(const ValueKey('setting-usage-stats'));
  final soundTile = find.byKey(const ValueKey('setting-sound'));

  bool valueOf(WidgetTester tester, Finder tile) => tester
      .widget<SwitchListTile>(
        find.descendant(of: tile, matching: find.byType(SwitchListTile)),
      )
      .value;

  Future<void> toggle(WidgetTester tester, Finder tile) async {
    await tester.tap(find.descendant(of: tile, matching: find.byType(Switch)));
    await tester.pumpAndSettle();
  }

  Future<void> pumpSheet(WidgetTester tester) => tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: SettingsSheet(stats: stats, sound: sound)),
        ),
      );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sink = _RecordingSink();
    stats = StatsService(sink: sink);
    await stats.init();
    sink.enabledCalls.clear();
    sound = SoundService();
    await sound.init();
  });

  group('kullanım istatistikleri', () {
    testWidgets('anahtar açık başlar', (tester) async {
      await pumpSheet(tester);

      expect(valueOf(tester, usageTile), isTrue);
    });

    testWidgets('kapatınca tercih saklanır ve olaylar durur', (tester) async {
      await pumpSheet(tester);

      await toggle(tester, usageTile);

      expect(valueOf(tester, usageTile), isFalse);
      expect(stats.analyticsEnabled, isFalse);
      expect(sink.enabledCalls, [false]);
      stats.logScreen('select');
      expect(sink.sent, isEmpty);
    });

    testWidgets('kapalı tercih sayfa yeniden açıldığında kapalı görünür',
        (tester) async {
      await stats.setAnalyticsEnabled(false);

      await pumpSheet(tester);

      expect(valueOf(tester, usageTile), isFalse);
    });

    testWidgets('yeniden açınca olaylar tekrar gider', (tester) async {
      await stats.setAnalyticsEnabled(false);
      await pumpSheet(tester);

      await toggle(tester, usageTile);

      expect(stats.analyticsEnabled, isTrue);
      stats.logScreen('select');
      expect(sink.sent, ['screen_view']);
    });
  });

  group('ses efektleri', () {
    testWidgets('anahtar açık başlar', (tester) async {
      await pumpSheet(tester);

      expect(valueOf(tester, soundTile), isTrue);
      expect(sound.enabled, isTrue);
    });

    testWidgets('kapatınca ses kapanır, istatistik ayarı değişmez',
        (tester) async {
      await pumpSheet(tester);

      await toggle(tester, soundTile);

      expect(valueOf(tester, soundTile), isFalse);
      expect(sound.enabled, isFalse);
      expect(valueOf(tester, usageTile), isTrue);
      expect(stats.analyticsEnabled, isTrue);
    });

    testWidgets('tercih saklanır: yeni açılışta ses kapalı gelir',
        (tester) async {
      await pumpSheet(tester);
      await toggle(tester, soundTile);

      final next = SoundService();
      await next.init();

      expect(next.enabled, isFalse);
    });

    test('kapalıyken ses çalma çağrıları platforma hiç gitmez', () async {
      // Test ortamında ses eklentisi yok: açıkken çağrı kanala ulaşıp hata
      // fırlatıyor, kapalıyken oraya hiç varmıyor
      await expectLater(sound.playTick(), throwsA(isA<MissingPluginException>()));

      await sound.setEnabled(false);

      await expectLater(sound.playTick(), completes);
      await expectLater(sound.playWin(), completes);
    });
  });
}
