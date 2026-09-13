import 'dart:math';
import 'dart:ui' show Offset;

import 'spin_curve.dart';


/// Sonuç açıklanmadan önce parmakların üzerinde dönen rulet ışını.
///
/// Işın, kilitli parmakların ağırlık merkezinden çıkar, birkaç tur döner ve
/// hedefin tam üstünde durur. Hedef, parmaklar kilitlenirken çekilir
/// (`GameController.spinTargetId`) — yani ışın rastgele bir yere değil,
/// gerçekten kazananın üstüne iner.
///
/// Ağırlık merkezi ekranın ortasına tercih edilir: parmaklar bir köşede
/// toplandığında bile aralarındaki açı farkı korunur, ekran ortasından
/// bakıldığında ise iki parmak neredeyse aynı açıya düşebilir.
///
/// Geometri saf Dart ve kare başına bir kez hesaplanır; hem çizim
/// (`FingerPainter`) hem de tik sesi aynı nesneden okur, böylece ses ile
/// görüntü ayrışmaz.
class SpinBeam {
  /// Işının çıktığı nokta — kilitli parmakların ağırlık merkezi
  final Offset center;

  /// Işının o anki açısı; radyan, 0 = sağ, artan değer saat yönü
  final double angle;

  /// Merkezden ışının ucuna uzaklık
  final double reach;

  /// Işının şu an gösterdiği parmağın `lockedPointerIds` içindeki indeksi
  final int highlightIndex;

  const SpinBeam({
    required this.center,
    required this.angle,
    required this.reach,
    required this.highlightIndex,
  });

  /// Kaç tam tur atılacağı. Dönüş hızı buradan gelir: 3 tur / 2 saniye,
  /// sabit hız fazında saniyede ~2 devir. Daha hızlısında 60fps'te tekerlek
  /// geri dönüyormuş gibi görünmeye başlıyor, tik sesleri de birbirine giriyor.
  static const int _turns = 3;

  /// Işının başladığı (ve takım modunda bittiği) açı — saat 12 yönü
  static const double _startAngle = -pi / 2;

  /// En uzak parmağın ötesine taşan pay; ışın dairelerin dışına çıksın
  static const double _reachMargin = 76.0;

  /// Parmaklar birbirine çok yakınken bile ışın görünür uzunlukta kalsın
  static const double _minReach = 170.0;

  /// Verilen an için ışını hesaplar. [t] 0 → 1 arası ham animasyon değeri.
  ///
  /// Geometri kurulamıyorsa (iki parmaktan az, ya da kilitli bir parmağın
  /// konumu yoksa) null döner — o karede ışın çizilmez.
  static SpinBeam? of({
    required List<int> lockedPointerIds,
    required Map<int, Offset> positions,
    required int? targetPointerId,
    required double t,
  }) {
    if (lockedPointerIds.length < 2) return null;

    final points = <Offset>[];
    for (final id in lockedPointerIds) {
      final position = positions[id];
      // Eksik konum indeksleri kaydırır; vurgu yanlış parmağa düşeceğine
      // o kare hiç ışın çizilmesin
      if (position == null) return null;
      points.add(position);
    }

    var sum = Offset.zero;
    for (final point in points) {
      sum += point;
    }
    final center = sum / points.length.toDouble();

    var maxDistance = 0.0;
    for (final point in points) {
      maxDistance = max(maxDistance, (point - center).distance);
    }

    // Hedefin açısı her karede güncel konumdan okunur: parmak dönüş
    // sırasında kayarsa ışın onu takip eder, sonunda yine üstünde durur
    final target = targetPointerId == null ? null : positions[targetPointerId];
    final sweep = target == null
        ? _turns * 2 * pi
        : _turns * 2 * pi + _turn(_startAngle, _angleOf(center, target));

    final angle = _startAngle + sweep * spinFraction(t);

    var highlightIndex = 0;
    var closest = double.infinity;
    for (var i = 0; i < points.length; i++) {
      final distance = _angleGap(angle, _angleOf(center, points[i]));
      if (distance < closest) {
        closest = distance;
        highlightIndex = i;
      }
    }

    return SpinBeam(
      center: center,
      angle: angle,
      reach: max(maxDistance + _reachMargin, _minReach),
      highlightIndex: highlightIndex,
    );
  }


  static double _angleOf(Offset center, Offset point) =>
      atan2(point.dy - center.dy, point.dx - center.dx);

  /// [from] açısından [to] açısına saat yönünde dönüş miktarı — [0, 2π)
  static double _turn(double from, double to) => (to - from) % (2 * pi);

  /// İki açı arasındaki en kısa mesafe — [0, π]
  static double _angleGap(double a, double b) {
    final gap = (a - b).abs() % (2 * pi);
    return gap > pi ? 2 * pi - gap : gap;
  }
}
