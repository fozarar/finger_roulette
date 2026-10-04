import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../l10n/app_localizations.dart';
import '../services/share_service.dart';

/// Paylaşım menüsü kapanınca çağrılır: [status] `success` ya da `dismissed`,
/// [method] iOS'un bildirdiği hedef (boşsa null)
typedef ShareCallback = void Function(String status, String? method);

/// Sonuç ekranının sağ üstündeki paylaş butonu — kapatma butonunun eşi.
///
/// [captureKey] ekranın paylaşılacak kısmını saran [RepaintBoundary]'nin
/// anahtarı; butonlar onun dışında kaldığı için görsele girmez.
class ShareButton extends StatefulWidget {
  final GlobalKey captureKey;
  final ShareService service;
  final ShareCallback? onShared;

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
  Widget build(BuildContext context) => IconButton(
        icon: const Icon(Icons.ios_share),
        color: Colors.white,
        iconSize: 22,
        tooltip: AppLocalizations.of(context).share,
        onPressed: _busy ? null : _share,
      );
}
