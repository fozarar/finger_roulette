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
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < widget.names.length; i++)
                _NameChip(
                  name: widget.names[i],
                  onRemove: () => _remove(i),
                ),
            ],
          ),
          if (widget.names.isNotEmpty) ...[
            const SizedBox(height: 12),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 14, right: 6, top: 7, bottom: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
        color: Colors.white.withValues(alpha: 0.06),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(name, style: const TextStyle(color: Colors.white, fontSize: 15)),
          const SizedBox(width: 2),
          GestureDetector(
            onTap: onRemove,
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.close_rounded, size: 15, color: Colors.white54),
            ),
          ),
        ],
      ),
    );
  }
}
