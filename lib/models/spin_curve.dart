/// Dönen animasyonların ortak hız eğrisi.
///
/// Toplam dönüşün [t] anına kadar tamamlanan oranı — 0'da 0, 1'de tam 1.
/// Hem parmak akışındaki ışın ([SpinBeam]) hem isim akışındaki çark
/// ([WheelSpin]) buradan okur; ikisi aynı ritimde dönsün diye tek yerde durur.
///
/// İlk %75 sabit hızda döner, kalan %25'te hız doğrusal olarak sıfıra iner.
/// Baştan sona yavaşlayan bir eğri (easeOut) ilk karelerde dönüşü okunamaz
/// hale getiriyordu; rulet de zaten bir süre sabit döner, sonra yavaşlar.
///
/// f(1) = 1 olduğu için dönüş hedefin tam üstünde durur, yakınında değil.
double spinFraction(double t) {
  final clamped = t.clamp(0.0, 1.0);

  /// Sabit hız fazının süresi (toplam sürenin oranı)
  const fast = 0.75;

  // Sabit fazda "fast", yavaşlama fazında ortalama yarı hızla "(1-fast)/2"
  // yol alınır; toplam tam 1 etsin diye hız buna göre seçilir.
  const speed = 1 / (fast + (1 - fast) / 2);

  if (clamped <= fast) return speed * clamped;

  final s = (clamped - fast) / (1 - fast);
  // Doğrusal yavaşlamanın yol integrali: s - s²/2
  return speed * fast + speed * (1 - fast) * (s - s * s / 2);
}
