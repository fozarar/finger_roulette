/// Katılımcıların nereden geldiği.
///
/// Mod ekseninden (Seç / Takım / Sıra) bağımsızdır: her mod iki girdiyle de
/// çalışır. Parmak girişi telefonun aynı anda algıladığı dokunuş sayısıyla
/// sınırlı; isim listesi kalabalık grupların yolu ve tek başına da kullanılır.
enum InputSource {
  /// Ekrana konan parmaklar
  fingers,

  /// Kullanıcının yazdığı isimler; seç modunda sonuç çarkla açıklanır
  names,
}
