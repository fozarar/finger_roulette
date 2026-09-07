import 'package:finger_roulette/services/review_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// Puan isteme zamanlaması bu uygulamanın en kritik büyüme mantığı:
/// iOS prompt'u yılda 3 kez gösterir, o yüzden erken/sık sorulmamalı.
void main() {
  final service = ReviewService();
  final now = DateTime(2026, 9, 6);

  bool ask({
    required int games,
    int promptCount = 0,
    int? lastPromptMs,
    DateTime? at,
  }) =>
      service.shouldPrompt(
        gamesPlayed: games,
        promptCount: promptCount,
        lastPromptMs: lastPromptMs,
        now: at ?? now,
      );

  group('ilk istek', () {
    test('3 oyundan önce sorulmaz', () {
      expect(ask(games: 0), isFalse);
      expect(ask(games: 1), isFalse);
      expect(ask(games: 2), isFalse);
    });

    test('3. oyunda sorulur', () {
      expect(ask(games: 3), isTrue);
    });

    test('eşik aşıldıysa yine sorulur', () {
      expect(ask(games: 12), isTrue);
    });
  });

  group('tekrar isteme', () {
    final lastPrompt = now.subtract(const Duration(days: 200));
    final lastMs = lastPrompt.millisecondsSinceEpoch;

    test('bir kez soruldan sonra hemen tekrar sorulmaz', () {
      expect(ask(games: 4, promptCount: 1, lastPromptMs: lastMs), isFalse);
    });

    test('yeterli oyun + yeterli zaman geçtiyse tekrar sorulur', () {
      // 3 + 25*1 = 28 oyun eşiği
      expect(ask(games: 28, promptCount: 1, lastPromptMs: lastMs), isTrue);
    });

    test('oyun eşiği tamam ama zaman geçmediyse sorulmaz', () {
      final recent =
          now.subtract(const Duration(days: 10)).millisecondsSinceEpoch;
      expect(ask(games: 28, promptCount: 1, lastPromptMs: recent), isFalse);
    });

    test('ikinci tekrar için eşik daha yüksek', () {
      // 3 + 25*2 = 53 oyun
      expect(ask(games: 52, promptCount: 2, lastPromptMs: lastMs), isFalse);
      expect(ask(games: 53, promptCount: 2, lastPromptMs: lastMs), isTrue);
    });
  });

  test('en fazla 3 kez sorulur, sonra hiç sorulmaz', () {
    final old = now.subtract(const Duration(days: 999)).millisecondsSinceEpoch;
    expect(ask(games: 10000, promptCount: 3, lastPromptMs: old), isFalse);
    expect(ask(games: 10000, promptCount: 9, lastPromptMs: old), isFalse);
  });
}
