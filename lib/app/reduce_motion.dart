import 'package:flutter/widgets.dart';

/// Kullanıcı sistemden hareketin azaltılmasını istedi mi.
///
/// iOS'un "Hareketi Azalt" ayarı [MediaQuery]'ye yansımıyor: oradaki
/// `disableAnimations` yalnızca Android'in "Animasyonları kaldır" ayarı. O
/// yüzden ikisi de doğrudan platformdan okunuyor.
///
/// Değer değişince kimseye haber verilmez; ekranlar her turda yeniden
/// kurulduğu için ayar bir sonraki açıklamada kendiliğinden geçerli olur.
bool reduceMotionOf(BuildContext context) {
  final features = View.of(context).platformDispatcher.accessibilityFeatures;
  return features.reduceMotion || features.disableAnimations;
}
