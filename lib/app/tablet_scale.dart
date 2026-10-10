import 'package:flutter/widgets.dart';

/// Tablette arayüzün tamamını büyütür.
///
/// Ekranlar telefon ölçüsüyle tasarlandı; iPad'de aynı ölçülerle çizilince
/// yazılar, butonlar ve parmak daireleri koca ekranda ufacık kalıyor. Her
/// ekranı ayrı ayrı uyarlamak yerine uygulama daha küçük bir mantıksal ekrana
/// çizilip büyütülüyor: iPad büyük bir telefon gibi davranıyor. Telefonda
/// ölçek 1, bu widget hiçbir şey yapmıyor.
///
/// Altındaki her şey — dokunuş konumları, [MediaQuery], alttan açılan
/// sayfalar — mantıksal ölçüyü görür. Pencerenin gerçekte ne kadar büyük
/// olduğunu soran kod [realSizeOf]'a bakar.
class TabletScale extends StatelessWidget {
  final Widget child;

  const TabletScale({super.key, required this.child});

  /// Kısa kenarı en az bu kadar olan pencere tablet sayılır. iPad'de
  /// daraltılmış bir pencere bunun altında kalır ve telefon gibi davranır.
  static const double tabletShortestSide = 600;

  /// Büyütme, mantıksal ekranın kısa kenarını bunun altına indirmez; en
  /// küçük iPad'de de on parmak dairesine yer kalsın.
  static const double _logicalShortestSide = 540;

  /// 13 inçlik iPad'de bile bundan fazla büyütülmez: daireler parmağı
  /// çevrelemeli, avucu değil
  static const double _maxScale = 1.5;

  static bool isTablet(Size screen) =>
      screen.shortestSide >= tabletShortestSide;

  static double scaleFor(Size screen) => isTablet(screen)
      ? (screen.shortestSide / _logicalShortestSide).clamp(1.0, _maxScale)
      : 1.0;

  /// Pencerenin büyütülmemiş boyutu
  static Size realSizeOf(BuildContext context) {
    final view = View.of(context);
    return view.physicalSize / view.devicePixelRatio;
  }

  @override
  Widget build(BuildContext context) {
    final data = MediaQuery.of(context);
    final scale = scaleFor(data.size);
    if (scale == 1.0) return child;

    final logicalSize = data.size / scale;
    return MediaQuery(
      // Klavye ve güvenli alan payları da küçülmeli; yoksa Scaffold klavye
      // için gereğinden fazla yer açar
      data: data.copyWith(
        size: logicalSize,
        devicePixelRatio: data.devicePixelRatio * scale,
        padding: data.padding / scale,
        viewPadding: data.viewPadding / scale,
        viewInsets: data.viewInsets / scale,
        systemGestureInsets: data.systemGestureInsets / scale,
      ),
      child: FittedBox(
        fit: BoxFit.fill,
        child: SizedBox.fromSize(size: logicalSize, child: child),
      ),
    );
  }
}
