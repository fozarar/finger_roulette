import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// `flutter drive` sürücüsü: testin çektiği ekran görüntülerini diske yazar.
Future<void> main() => integrationDriver(
      onScreenshot: (name, bytes, [args]) async {
        final dir =
            Platform.environment['SCREENSHOT_DIR'] ?? 'build/screenshots';
        final file = File('$dir/$name.png');
        await file.create(recursive: true);
        await file.writeAsBytes(bytes);
        return true;
      },
    );
