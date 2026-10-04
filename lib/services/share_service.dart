import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

/// Sonuç ekranını hikâye boyutunda bir görsele çevirip sistem paylaşım
/// menüsünü açar.
///
/// Ekran görüntüsü olduğu gibi paylaşılsaydı butonlar da görünür ve
/// uygulamanın adı hiçbir yerde geçmezdi. Kart sonucu ortalar, altına ikon ve
/// adı koyar: paylaşılan her görsel uygulamanın reklamı olur.
class ShareService {
  static const String appName = 'Finger Chooser';
  static const String appStoreUrl = 'https://apps.apple.com/app/id6759880651';

  /// Instagram ve WhatsApp hikâyelerinin boyutu (9:16)
  static const Size cardSize = Size(1080, 1920);

  /// Sonucun kartta kapladığı alan; altta ikon ve ad için yer kalır
  static const Rect contentArea = Rect.fromLTWH(60, 100, 960, 1520);

  /// Kartın zemini, ekran panelinden (0xFF111111) bir ton koyu: panel
  /// böylece zeminden ayrılıyor
  static const Color _background = Color(0xFF000000);

  /// [boundary]'yi kartın içine sığacak çözünürlükte yakalar ve paylaşır.
  /// [origin] paylaşım menüsünün çıktığı nokta; iPad'de zorunlu.
  /// Menü kapanınca kullanıcının ne yaptığını döndürür.
  Future<ShareResult> shareResult({
    required RenderRepaintBoundary boundary,
    required String message,
    Rect? origin,
  }) async {
    final content = await boundary.toImage(
      pixelRatio: captureScale(boundary.size),
    );
    final png = await composeCard(content: content, icon: await _loadIcon());
    content.dispose();

    return SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(png, mimeType: 'image/png')],
        fileNameOverrides: const ['finger-chooser.png'],
        text: '$message $appStoreUrl',
        sharePositionOrigin: origin,
      ),
    );
  }

  /// Yakalanan ekranın karta yeniden ölçeklenmeden oturacağı piksel oranı.
  /// Doğrudan bu oranda yakalamak, küçük yakalayıp büyütmekten keskin.
  static double captureScale(Size logical) => min(
        contentArea.width / logical.width,
        contentArea.height / logical.height,
      );

  /// Sonucu kartın ortasına, ikon ile adı altına çizer ve PNG döndürür
  static Future<Uint8List> composeCard({
    required ui.Image content,
    ui.Image? icon,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawRect(Offset.zero & cardSize, Paint()..color = _background);

    // Yakalama zaten doğru ölçekte; yine de sığmayan bir şey gelirse küçült
    final src = Rect.fromLTWH(
      0,
      0,
      content.width.toDouble(),
      content.height.toDouble(),
    );
    final fit = min(
      1.0,
      min(contentArea.width / src.width, contentArea.height / src.height),
    );
    final dst = Rect.fromCenter(
      center: contentArea.center,
      width: src.width * fit,
      height: src.height * fit,
    );
    // Ekran yuvarlak köşeli bir panel olarak çizilir. Kazananın parlaması
    // ekranın kenarına taşınca yakalamanın sınırında kesiliyor; çerçevesiz
    // bir görselde bu, kartın ortasında keskin bir çizgi gibi duruyordu.
    final panel = RRect.fromRectAndRadius(dst, const Radius.circular(44));
    canvas.save();
    canvas.clipRRect(panel);
    canvas.drawImageRect(
      content,
      src,
      dst,
      Paint()..filterQuality = FilterQuality.high,
    );
    canvas.restore();
    canvas.drawRRect(
      panel,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0x22FFFFFF),
    );

    _drawFooter(canvas, icon);

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      cardSize.width.toInt(),
      cardSize.height.toInt(),
    );
    picture.dispose();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return bytes!.buffer.asUint8List();
  }

  /// İkon ve ad yan yana, kartın alt ortasında
  static void _drawFooter(Canvas canvas, ui.Image? icon) {
    const iconSize = 96.0;
    const gap = 28.0;
    final centerY =
        contentArea.bottom + (cardSize.height - contentArea.bottom) / 2;

    final name = TextPainter(
      text: const TextSpan(
        text: appName,
        style: TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 54,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final width = (icon == null ? 0 : iconSize + gap) + name.width;
    var x = (cardSize.width - width) / 2;

    if (icon != null) {
      final rect = Rect.fromLTWH(x, centerY - iconSize / 2, iconSize, iconSize);
      canvas.save();
      // iOS ikonlarının köşe yuvarlaklığına yakın
      canvas.clipRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(iconSize * 0.225)),
      );
      canvas.drawImageRect(
        icon,
        Rect.fromLTWH(0, 0, icon.width.toDouble(), icon.height.toDouble()),
        rect,
        Paint()..filterQuality = FilterQuality.high,
      );
      canvas.restore();
      x += iconSize + gap;
    }

    name.paint(canvas, Offset(x, centerY - name.height / 2));
    name.dispose();
  }

  /// İkon yüklenemezse kart yalnızca adla çizilir; paylaşım yine çalışır
  static Future<ui.Image?> _loadIcon() async {
    try {
      final data = await rootBundle.load('assets/images/share_icon.png');
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      return (await codec.getNextFrame()).image;
    } catch (_) {
      return null;
    }
  }
}
