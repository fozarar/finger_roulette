import 'dart:math';

import 'package:finger_roulette/models/draw.dart';
import 'package:finger_roulette/models/game_mode.dart';
import 'package:flutter_test/flutter_test.dart';

/// Çekiliş parmak ID'lerini de isim listesi indekslerini de aynı şekilde
/// görür; testler bu yüzden düz kimlik listeleriyle çalışıyor.
void main() {
  Draw draw(
    GameMode mode, {
    int participants = 5,
    int pickCount = 1,
    int teamCount = 2,
    int seed = 7,
  }) =>
      Draw.of(
        participants: List.generate(participants, (i) => i),
        mode: mode,
        pickCount: pickCount,
        teamCount: teamCount,
        random: Random(seed),
      );

  group('seç', () {
    test('istenen sayıda ve tekil seçer', () {
      final d = draw(GameMode.pick, participants: 5, pickCount: 2);
      expect(d.picked.length, 2);
      expect(d.picked.toSet().length, 2);
      expect(d.teams, isEmpty);
      expect(d.ranked, isEmpty);
    });

    test('katılımcıdan fazla seçilemez', () {
      final d = draw(GameMode.pick, participants: 3, pickCount: 9);
      expect(d.picked.length, 3);
    });

    test('hedef seçilenlerin ilki', () {
      final d = draw(GameMode.pick, participants: 5, pickCount: 3);
      expect(d.spinTarget, d.picked.first);
    });
  });

  group('takım', () {
    test('herkes bir takıma düşer ve takımlar dengelidir', () {
      for (final n in [3, 4, 5, 14]) {
        final d = draw(GameMode.teams, participants: n);
        expect(d.teams.length, n, reason: '$n katılımcı');
        final sizes = List.filled(2, 0);
        for (final team in d.teams.values) {
          sizes[team]++;
        }
        expect(sizes.reduce(max) - sizes.reduce(min), lessThanOrEqualTo(1),
            reason: '$n katılımcı: $sizes');
      }
    });

    test('üç takıma da bölünebilir', () {
      final d = draw(GameMode.teams, participants: 12, teamCount: 3);
      final sizes = List.filled(3, 0);
      for (final team in d.teams.values) {
        sizes[team]++;
      }
      expect(sizes, [4, 4, 4]);
    });

    test('takım modunda öne çıkan kimse yok', () {
      expect(draw(GameMode.teams).spinTarget, isNull);
    });
  });

  group('sıra', () {
    test('herkes tam bir kez sıraya girer', () {
      final d = draw(GameMode.order, participants: 5);
      expect(d.ranked.toSet(), {0, 1, 2, 3, 4});
      expect(d.ranked.length, 5);
      expect(d.spinTarget, d.ranked.first);
    });
  });

  test('aynı tohum aynı sonucu verir, farklı tohum farklıyı', () {
    final a = draw(GameMode.order, participants: 20, seed: 1);
    final b = draw(GameMode.order, participants: 20, seed: 1);
    final c = draw(GameMode.order, participants: 20, seed: 2);
    expect(a.ranked, b.ranked);
    expect(a.ranked, isNot(c.ranked));
  });
}
