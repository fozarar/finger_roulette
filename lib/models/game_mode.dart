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

  /// Telefonda parmakla oynayabilecek en fazla kişi: iPhone aynı anda beş
  /// dokunuştan fazlasını algılamıyor
  static const int phoneMaxPlayers = 5;

  /// Tablette parmakla oynayabilecek en fazla kişi. iPad 11 dokunuşa kadar
  /// algılıyor; on, masanın etrafına sığan sayı.
  static const int tabletMaxPlayers = 10;

  /// Seçim ekranında sunulan oyuncu sayıları, [maxPlayers]'a kadar.
  /// İki kişiyi takımlara bölmek anlamsız olduğundan takım modu 3'ten başlar.
  List<int> playerCounts({int maxPlayers = phoneMaxPlayers}) =>
      [for (var n = this == teams ? 3 : 2; n <= maxPlayers; n++) n];
}

/// Seç modunda seçilenlerin ne olduğu.
///
/// Çekiliş iki durumda da birebir aynı; değişen yalnızca çerçeve. Kazananlar
/// kutlanır, kaybedenler hesabı öder — insanların uygulamayı açma sebebi
/// çoğu zaman ikincisi.
enum PickOutcome { winners, losers }
