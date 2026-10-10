import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../l10n/app_localizations.dart';
import '../services/share_service.dart';

/// Paylaşım menüsü kapanınca çağrılır: [status] `success` ya da `dismissed`,
/// [method] iOS'un bildirdiği hedef (boşsa null)
typedef ShareCallback = void Function(String status, String? method);

/// Sonuç ekranında "tekrar oyna"nın hemen altındaki yazılı paylaş butonu.
/// Köşedeki küçük bir simgeyken 250 turda iki kez dokunulmuştu; gözün ve
/// başparmağın zaten durduğu yere, adıyla birlikte indi.
///
/// [captureKey] ekranın paylaşılacak kısmını saran [RepaintBoundary]'nin
/// anahtarı; butonlar onun dışında kaldığı için görsele girmez.
class ShareButton extends StatefulWidget {
  final GlobalKey captureKey;
  final ShareService service;
  final ShareCallback? onShared;

  /// Butonun sabit yüksekliği; çark ekranı buton alanını buna göre ayırıyor
  static const double height = 44;

  ShareButton({
    super.key,
    required this.captureKey,
    this.onShared,
    ShareService? service,
  }) : service = service ?? ShareService();

  @override
  State<ShareButton> createState() => _ShareButtonState();
}

class _ShareButtonState extends State<ShareButton> {
  /// Görsel hazırlanırken ikinci dokunuş ikinci bir menü açmasın
  bool _busy = false;

  Future<void> _share() async {
    final boundary = widget.captureKey.currentContext?.findRenderObject();
    if (_busy || boundary is! RenderRepaintBoundary) return;
    final message = AppLocalizations.of(context).shareMessage;
    final box = context.findRenderObject() as RenderBox?;
    final origin =
        box == null ? null : box.localToGlobal(Offset.zero) & box.size;

    setState(() => _busy = true);
    try {
      final result = await widget.service.shareResult(
        boundary: boundary,
        message: message,
        origin: origin,
      );
      widget.onShared?.call(
        result.status.name,
        result.raw.isEmpty ? null : result.raw,
      );
    } catch (e) {
      // Paylaşım menüsü açılamadıysa oyun etkilenmesin
      debugPrint('Paylaşım başarısız: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        onPressed: _busy ? null : _share,
        icon: const Icon(Icons.ios_share, size: 18),
        label: Text(
          AppLocalizations.of(context).share,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white38,
          // Parmak ekranında buton bir dairenin üstüne denk gelebiliyor;
          // koyu zemin olmadan yazı parlak dairede kayboluyor
          backgroundColor: const Color(0xCC111111),
          side: const BorderSide(color: Color(0x66FFFFFF)),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          minimumSize: const Size(0, ShareButton.height),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      );
}
