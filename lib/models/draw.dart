import 'dart:math';

import 'game_mode.dart';

/// Bir turun çekilmiş sonucu.
///
/// Katılımcılar sıralı kimliklerle temsil edilir: parmak oyununda pointer
/// ID'leri, isim listesinde satır indeksleri. Çekiliş bu yüzden iki girdi
/// biçiminde de aynı koddur — [GameMode] neyin çekileceğine, burası nasıl
/// çekileceğine karar verir.
class Draw {
  /// Seç modunda seçilenler (kazananlar ya da kaybedenler)
  final List<int> picked;

  /// Takım modunda her katılımcının takım indeksi (0 = A takımı)
  final Map<int, int> teams;

  /// Sıra modunda katılımcılar sırasıyla; ilk eleman 1. sırada
  final List<int> ranked;

  const Draw({
    this.picked = const [],
    this.teams = const {},
    this.ranked = const [],
  });

  /// Çekilişi yapar. [random] dışarıdan verilir ki testler belirli kalsın.
  factory Draw.of({
    required List<int> participants,
    required GameMode mode,
    required int pickCount,
    required int teamCount,
    required Random random,
  }) {
    // Her mod karıştırılmış listeden okur — herkesin şansı eşit
    final shuffled = List.of(participants)..shuffle(random);

    return switch (mode) {
      // Seçilecek sayı: istenen değer ile katılımcı sayısının küçüğü
      GameMode.pick => Draw(
          picked: shuffled.take(min(pickCount, shuffled.length)).toList(),
        ),
      // Sırayla dağıtmak takımları dengeler: boyutlar en fazla 1 farklı
      GameMode.teams => Draw(
          teams: {
            for (var i = 0; i < shuffled.length; i++) shuffled[i]: i % teamCount,
          },
        ),
      GameMode.order => Draw(ranked: shuffled),
    };
  }

  /// Dönen ışının (ya da çarkın) üstünde duracağı katılımcı: seç modunda
  /// seçilenlerin ilki, sıra modunda birinci. Takım modunda kimse öne
  /// çıkmadığı için null.
  int? get spinTarget => picked.isNotEmpty
      ? picked.first
      : (ranked.isNotEmpty ? ranked.first : null);
}
