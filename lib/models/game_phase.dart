/// Oyunun hangi aşamasında olduğunu temsil eder.
/// [GameController] tarafından set edilir; UI katmanı buna göre render eder.
enum GamePhase {
  /// Seçim ekranı: oyuncu ve kazanan sayısı henüz seçilmedi
  setup,

  /// Oyun ekranı: hedef sayıda parmak bekleniyor
  waiting,

  /// Hedef sayıda parmak algılandı; 800ms kilit sayacı çalışıyor
  choosing,

  /// Pointer listesi kilitlendi; döngü animasyonu aktif
  locked,

  /// Kazanan(lar) seçildi ve açıklandı
  revealed,
}
