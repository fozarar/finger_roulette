import 'dart:math';

import 'spin_curve.dart';

/// Çarkın bir andaki dönüşü.
///
/// Hız eğrisini ışınla paylaşır ([spinFraction]): birkaç tur sabit hız, sonra
/// yavaşlayarak hedefin tam üstünde durma. İkisi de aynı süreyi doldurduğu
/// için parmak akışıyla isim akışı aynı ritimde hissedilir.
///
/// Geometri saf Dart ve kare başına bir kez hesaplanır; hem çizim hem tik
/// sesi aynı nesneden okur, böylece ses ile görüntü ayrışmaz.
class WheelSpin {
  /// Çarkın başlangıç konumuna göre döndüğü açı (radyan, saat yönü)
  final double angle;

  /// İbrenin şu an gösterdiği dilim
  final int indexUnderPointer;

  const WheelSpin({required this.angle, required this.indexUnderPointer});

  /// İbre saat 12 yönünde sabittir; dönen çarkın kendisidir.
  /// Dilim 0 da hiç dönmemişken buradan başlar.
  static const double startAngle = -pi / 2;

  /// Kaç tam tur atılacağı. Işındaki 3 turun karşılığı; çark daha büyük bir
  /// nesne olduğu için bir tur fazlası dönüşü hızlı değil, görkemli gösteriyor.
  static const int turns = 4;

  /// [count] dilimli çarkta bir dilimin açısı
  static double segment(int count) => 2 * pi / count;

  /// Hedefin ibrenin altına gelmesi için dönülmesi gereken toplam açı.
  ///
  /// Dilim [targetIndex] merkezinin ibreye oturduğu yer: tam turlardan geriye
  /// o dilimin merkez açısı düşülür. Dönüş her zaman pozitif kalır.
  static double sweepTo({required int targetIndex, required int count}) =>
      turns * 2 * pi - (targetIndex + 0.5) * segment(count);

  /// Verilen an için çarkı hesaplar. [t] 0 → 1 arası ham animasyon değeri.
  ///
  /// [targetIndex] null ise (henüz çekilmemişse) çark durur.
  static WheelSpin of({
    required int count,
    required int? targetIndex,
    required double t,
  }) {
    if (count <= 0) return const WheelSpin(angle: 0, indexUnderPointer: 0);
    if (targetIndex == null) {
      return WheelSpin(angle: 0, indexUnderPointer: indexAt(0, count));
    }

    final angle = sweepTo(targetIndex: targetIndex, count: count) *
        spinFraction(t);
    return WheelSpin(angle: angle, indexUnderPointer: indexAt(angle, count));
  }

  /// Çark [angle] kadar dönmüşken ibrenin altında kalan dilim
  static int indexAt(double angle, int count) {
    final seg = segment(count);
    // Çark saat yönünde dönerken ibrenin altındaki dilim geriye doğru kayar
    final under = (-angle) % (2 * pi);
    return (under / seg).floor() % count;
  }
}
