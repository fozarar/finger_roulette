/// Oyunun hangi soruya cevap verdiğini belirler.
///
/// Tüm modlar aynı parmak mekaniğini kullanır — parmaklar kilitlenir, döngü
/// döner — yalnızca açıklanan sonuç değişir. [GameController] seçili modu
/// tutar; UI katmanı metinleri ve görselleri buna göre seçer.
enum GameMode {
  /// Parmakların bir kısmı seçilir; seçilenlerin kazanan mı kaybeden mi
  /// olduğunu [PickOutcome] belirler
  pick,

  /// Tüm parmaklar dengeli takımlara dağıtılır
  teams,

  /// Tüm parmaklara sıra numarası verilir: kim başlar, kim ikinci
  order;

  /// Seç modu parmakların bir kısmını seçer ve kaç kişi seçileceğini sorar.
  /// Takım ve sıra modları ise her parmağa bir sonuç verir.
  bool get picksSubset => this == pick;

  /// Seçim ekranında sunulan oyuncu sayıları.
  /// İki kişiyi takımlara bölmek anlamsız olduğundan takım modu 3'ten başlar.
  List<int> get playerCounts =>
      this == teams ? const [3, 4, 5] : const [2, 3, 4, 5];
}

/// Seç modunda seçilenlerin ne olduğu.
///
/// Çekiliş iki durumda da birebir aynı; değişen yalnızca çerçeve. Kazananlar
/// kutlanır, kaybedenler hesabı öder — insanların uygulamayı açma sebebi
/// çoğu zaman ikincisi.
enum PickOutcome { winners, losers }
