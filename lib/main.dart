import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'app/app.dart';

void main() {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  // Native splash'i Flutter hazır olana kadar tut, sonra kaldır
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  // Tam ekran mod — sistem çubuklarını gizle
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const FingerRouletteApp());
  // İlk frame çizildikten sonra splash'i kaldır — erken kaldırınca siyah ekran çıkar
  WidgetsBinding.instance.addPostFrameCallback((_) {
    FlutterNativeSplash.remove();
  });
}
