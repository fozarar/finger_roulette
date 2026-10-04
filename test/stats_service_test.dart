import 'package:finger_roulette/models/game_mode.dart';
import 'package:finger_roulette/models/input_source.dart';
import 'package:finger_roulette/services/stats_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gönderilen olayları ve açma/kapama çağrılarını biriktiren sahte uç
class _RecordingSink implements AnalyticsSink {
  final List<(String, Map<String, Object>)> sent = [];
  final List<bool> enabledCalls = [];

  @override
  void log(String name, Map<String, Object> params) => sent.add((name, params));

  @override
  Future<void> setEnabled(bool enabled) async => enabledCalls.add(enabled);
}

void main() {
  late _RecordingSink sink;
  late List<(String, Map<String, Object>)> sent;
  late StatsService stats;

  setUp(() {
    sink = _RecordingSink();
    sent = sink.sent;
    // init() çağrılmadı: depolama yok, yalnızca olay akışı sınanıyor
    stats = StatsService(sink: sink);
  });

  test('sink verilmezse olaylar sessizce yutulur', () {
    expect(() => StatsService().logEvent('x', {'a': 1}), returnsNormally);
  });

  test('biten oyun mod, girdi ve oyuncu sayısıyla gönderilir', () async {
    await stats.recordGameCompleted(
      mode: GameMode.pick,
      input: InputSource.fingers,
      playerCount: 4,
      outcome: PickOutcome.losers,
      pickCount: 1,
    );

    expect(sent.single.$1, 'game_completed');
    expect(sent.single.$2, {
      'mode': 'pick',
      'input': 'fingers',
      'outcome': 'losers',
      'players': 4,
      'picks': 1,
      'total_games': 1,
    });
  });

  test('takım modunda olmayan alanlar hiç gönderilmez', () async {
    await stats.recordGameCompleted(
      mode: GameMode.teams,
      input: InputSource.names,
      playerCount: 6,
    );

    expect(sent.single.$2.keys, isNot(contains('outcome')));
    expect(sent.single.$2.keys, isNot(contains('picks')));
  });

  test('ekran değişimi screen_view olarak gönderilir', () {
    stats.logScreen('wheel');

    expect(sent.single.$1, 'screen_view');
    expect(sent.single.$2, {'screen_name': 'wheel'});
  });

  test('paylaşım, hedefi bilinmiyorsa method olmadan gönderilir', () {
    stats.recordShare(
      mode: GameMode.order,
      input: InputSource.names,
      status: 'dismissed',
    );

    expect(sent.single.$1, 'share');
    expect(sent.single.$2, {
      'content_type': 'result_card',
      'mode': 'order',
      'input': 'names',
      'status': 'dismissed',
    });
  });

  group('kullanım istatistiklerini kapatma', () {
    test('varsayılan açık', () {
      expect(stats.analyticsEnabled, isTrue);
    });

    test('kapatınca olay gitmez ve servise de bildirilir', () async {
      await stats.setAnalyticsEnabled(false);
      stats.logScreen('wheel');
      await stats.recordGameCompleted(
        mode: GameMode.teams,
        input: InputSource.fingers,
        playerCount: 4,
      );

      expect(sent, isEmpty);
      expect(sink.enabledCalls, [false]);
    });

    test('yeniden açınca olaylar tekrar gider', () async {
      await stats.setAnalyticsEnabled(false);
      await stats.setAnalyticsEnabled(true);
      stats.logScreen('select');

      expect(sent, hasLength(1));
    });

    test('tercih saklanır ve sonraki açılışta servise uygulanır', () async {
      SharedPreferences.setMockInitialValues({});
      final first = StatsService(sink: _RecordingSink());
      await first.init();
      await first.setAnalyticsEnabled(false);

      final nextSink = _RecordingSink();
      final next = StatsService(sink: nextSink);
      await next.init();

      expect(next.analyticsEnabled, isFalse);
      expect(nextSink.enabledCalls, [false]);
      next.logScreen('select');
      expect(nextSink.sent, isEmpty);
    });

    test('kapalıyken oyun sayacı yine artar', () async {
      SharedPreferences.setMockInitialValues({});
      final local = StatsService(sink: _RecordingSink());
      await local.init();
      await local.setAnalyticsEnabled(false);

      final count = await local.recordGameCompleted(
        mode: GameMode.order,
        input: InputSource.names,
        playerCount: 3,
      );

      // Puan isteme bu sayaca bağlı; analitik kapalı diye durmamalı
      expect(count, 1);
    });
  });

  test('değerler yalnızca metin ya da sayı', () async {
    await stats.recordGameCompleted(
      mode: GameMode.pick,
      input: InputSource.fingers,
      playerCount: 3,
      outcome: PickOutcome.winners,
      pickCount: 1,
    );
    stats.recordShare(
      mode: GameMode.pick,
      input: InputSource.fingers,
      status: 'success',
      method: 'com.apple.UIKit.activity.SaveToCameraRoll',
    );

    for (final (_, params) in sent) {
      for (final value in params.values) {
        expect(value, anyOf(isA<String>(), isA<num>()));
      }
    }
  });
}
