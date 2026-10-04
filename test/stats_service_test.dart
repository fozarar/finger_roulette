import 'package:finger_roulette/models/game_mode.dart';
import 'package:finger_roulette/models/input_source.dart';
import 'package:finger_roulette/services/stats_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late List<(String, Map<String, Object>)> sent;
  late StatsService stats;

  setUp(() {
    sent = [];
    // init() çağrılmadı: depolama yok, yalnızca olay akışı sınanıyor
    stats = StatsService(sink: (name, params) => sent.add((name, params)));
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
