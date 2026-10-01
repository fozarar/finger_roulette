import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finger_roulette/services/share_service.dart';

/// Verilen boyutta düz renkli bir görsel — yakalanmış ekranın yerine
Future<ui.Image> _solid(int width, int height) async {
  final recorder = ui.PictureRecorder();
  Canvas(recorder).drawRect(
    Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
    Paint()..color = const Color(0xFFFF8A65),
  );
  final picture = recorder.endRecording();
  final image = await picture.toImage(width, height);
  picture.dispose();
  return image;
}

void main() {
  group('captureScale', () {
    test('uzun ekran yüksekliğe göre sığar', () {
      const screen = Size(390, 844);
      final scale = ShareService.captureScale(screen);
      expect(screen.height * scale, closeTo(ShareService.contentArea.height, 0.01));
      expect(screen.width * scale, lessThanOrEqualTo(ShareService.contentArea.width));
    });

    test('kısa alan genişliğe göre sığar', () {
      const area = Size(390, 400);
      final scale = ShareService.captureScale(area);
      expect(area.width * scale, closeTo(ShareService.contentArea.width, 0.01));
      expect(area.height * scale, lessThanOrEqualTo(ShareService.contentArea.height));
    });
  });

  testWidgets('kart hikâye boyutunda bir PNG üretir', (tester) async {
    final bytes = await tester.runAsync(() async {
      final content = await _solid(700, 1520);
      final png = await ShareService.composeCard(content: content);
      content.dispose();
      return png;
    });

    // PNG imzası
    expect(bytes!.sublist(0, 8), [137, 80, 78, 71, 13, 10, 26, 10]);

    final size = await tester.runAsync(() async {
      final codec = await ui.instantiateImageCodec(bytes);
      final image = (await codec.getNextFrame()).image;
      final size = Size(image.width.toDouble(), image.height.toDouble());
      image.dispose();
      return size;
    });
    expect(size, ShareService.cardSize);
  });

  testWidgets('sığmayan içerik küçültülerek yine de karta çizilir',
      (tester) async {
    final bytes = await tester.runAsync(() async {
      final content = await _solid(2000, 3000);
      final png = await ShareService.composeCard(content: content);
      content.dispose();
      return png;
    });
    expect(bytes, isNotEmpty);
  });
}
