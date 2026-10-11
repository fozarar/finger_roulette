import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/names_service.dart';

/// Çarkın katılımcılarını yazdığın liste.
///
/// Alan her eklemeden sonra odakta kalır: insanlar isimleri arka arkaya
/// yazıyor, her seferinde alana dönmek zorunda kalmasınlar. İsimler
/// [NamesService] ile saklandığı için liste bir sonraki açılışta yerinde olur.
class NameListEditor extends StatefulWidget {
  final List<String> names;
  final ValueChanged<List<String>> onChanged;

  const NameListEditor({
    super.key,
    required this.names,
    required this.onChanged,
  });

  /// Çarkta okunabilir kalan üst sınır; uzun isimler dilime sığmıyor
  static const int maxNameLength = 14;

  @override
  State<NameListEditor> createState() => _NameListEditorState();
}

class _NameListEditorState extends State<NameListEditor> {
  final TextEditingController _field = TextEditingController();
  final FocusNode _focus = FocusNode();

  @override
  void dispose() {
    _field.dispose();
    _focus.dispose();
    super.dispose();
  }

  bool get _isFull => widget.names.length >= NamesService.maxNames;

  void _add() {
    final value = _field.text.trim();
    if (value.isEmpty || _isFull) return;
    widget.onChanged([...widget.names, value]);
    _field.clear();
    _focus.requestFocus();
  }

  void _remove(int index) {
    widget.onChanged([...widget.names]..removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _field,
                  focusNode: _focus,
                  enabled: !_isFull,
                  maxLength: NameListEditor.maxNameLength,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _add(),
                  style: const TextStyle(color: Colors.white, fontSize: 17),
                  decoration: InputDecoration(
                    hintText: l10n.nameHint,
                    hintStyle: const TextStyle(color: Colors.white38),
                    counterText: '',
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white70),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                onPressed: _isFull ? null : _add,
                icon: const Icon(Icons.add_rounded),
                color: Colors.white,
                disabledColor: Colors.white24,
                tooltip: l10n.addName,
              ),
            ],
          ),
          // Satır aralığı Wrap'te değil çiplerin içinde (bkz. _NameChip);
          // üstteki ve alttaki boşluk o yüzden 4'er pt eksik yazılı
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            children: [
              for (var i = 0; i < widget.names.length; i++)
                _NameChip(
                  name: widget.names[i],
                  onRemove: () => _remove(i),
                ),
            ],
          ),
          if (widget.names.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '${widget.names.length}/${NamesService.maxNames}',
              style: const TextStyle(color: Color(0x66FFFFFF), fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

class _NameChip extends StatelessWidget {
  final String name;
  final VoidCallback onRemove;

  const _NameChip({required this.name, required this.onRemove});

  /// Silme çarpısının dokunma alanının genişliği. Çarpı 15 pt çiziliyor ama
  /// parmağın bulabilmesi için alan en az 44 pt olmalı.
  static const double _tapTarget = 44;

  /// Çip satırları arasındaki boşluk. Yarısı çipin üstünde, yarısı altında
  /// duruyor ki dokunma alanı onu da kullanıp 44 pt'yi geçsin; Wrap'in kendi
  /// satır aralığı olsaydı alan çizilen çipin 39 pt'sinde kalırdı.
  static const double _rowGap = 8;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: _rowGap / 2),
          child: Container(
            padding: const EdgeInsetsDirectional.only(
              start: 14,
              end: 6,
              top: 7,
              bottom: 7,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24),
              color: Colors.white.withValues(alpha: 0.06),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
                const SizedBox(width: 2),
                const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.close_rounded,
                    size: 15,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Çarpının olduğu uç; sağdan sola dillerde solda kalıyor. İsmin son
        // harflerinin üstüne taşıyor, orada dokunulacak başka bir şey yok.
        PositionedDirectional(
          top: 0,
          bottom: 0,
          end: 0,
          width: _tapTarget,
          child: Semantics(
            button: true,
            label: l10n.removeName(name),
            child: GestureDetector(
              onTap: onRemove,
              behavior: HitTestBehavior.opaque,
            ),
          ),
        ),
      ],
    );
  }
}
