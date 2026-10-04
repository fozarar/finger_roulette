import 'package:finger_roulette/l10n/app_localizations.dart';
import 'package:finger_roulette/services/stats_service.dart';
import 'package:finger_roulette/widgets/settings_sheet.dart';
import 'package:flutter/material.dart';
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

  Future<void> pumpSheet(WidgetTester tester) => tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: SettingsSheet(stats: stats)),
        ),
      );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sink = _RecordingSink();
    stats = StatsService(sink: sink);
    await stats.init();
    sink.enabledCalls.clear();
  });

  testWidgets('anahtar açık başlar', (tester) async {
    await pumpSheet(tester);

    expect(tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
        isTrue);
  });

  testWidgets('kapatınca tercih saklanır ve olaylar durur', (tester) async {
    await pumpSheet(tester);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
        isFalse);
    expect(stats.analyticsEnabled, isFalse);
    expect(sink.enabledCalls, [false]);
    stats.logScreen('select');
    expect(sink.sent, isEmpty);
  });

  testWidgets('kapalı tercih sayfa yeniden açıldığında kapalı görünür',
      (tester) async {
    await stats.setAnalyticsEnabled(false);

    await pumpSheet(tester);

    expect(tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
        isFalse);
  });

  testWidgets('yeniden açınca olaylar tekrar gider', (tester) async {
    await stats.setAnalyticsEnabled(false);
    await pumpSheet(tester);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(stats.analyticsEnabled, isTrue);
    stats.logScreen('select');
    expect(sink.sent, ['screen_view']);
  });
}
