import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/name_list.dart';
import '../services/names_service.dart';

/// Kayıtlı isim listeleri arasında geçiş: her liste bir sekme, sonda "+".
///
/// Açık sekmenin yanında kalem durur; ona dokunmak adını değiştirme ve silme
/// sayfasını açar. Diğer sekmelere dokunmak o listeye geçer.
class NameListTabs extends StatelessWidget {
  final List<NameList> lists;
  final int activeIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onAdd;
  final ValueChanged<String> onRename;
  final VoidCallback onDelete;

  const NameListTabs({
    super.key,
    required this.lists,
    required this.activeIndex,
    required this.onSelect,
    required this.onAdd,
    required this.onRename,
    required this.onDelete,
  });

  /// Sekmeye sığan üst sınır
  static const int maxTitleLength = 16;

  /// Adı olmayan liste sırasına göre adlandırılır: "Liste 2"
  static String titleOf(AppLocalizations l10n, List<NameList> lists, int i) =>
      lists[i].title.isEmpty ? l10n.listDefaultName(i + 1) : lists[i].title;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        children: [
          for (var i = 0; i < lists.length; i++) ...[
            _Tab(
              label: titleOf(l10n, lists, i),
              active: i == activeIndex,
              onTap: i == activeIndex
                  ? () => _ListEditSheet.show(
                        context,
                        title: lists[i].title,
                        onRename: onRename,
                        onDelete: onDelete,
                      )
                  : () => onSelect(i),
            ),
            const SizedBox(width: 8),
          ],
          if (lists.length < NamesService.maxLists)
            IconButton(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              color: Colors.white70,
              iconSize: 20,
              tooltip: l10n.newList,
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _Tab({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: active,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: active ? Colors.white : Colors.white24,
              width: active ? 1.5 : 1,
            ),
            color: Colors.white.withValues(alpha: active ? 0.16 : 0.04),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: active ? Colors.white : Colors.white70,
                  fontSize: 14,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
              if (active) ...[
                const SizedBox(width: 6),
                const Icon(Icons.edit_outlined, size: 14, color: Colors.white70),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Açık listenin adını değiştirme ve silme sayfası.
///
/// Ad yazıldıkça kaydedilir; ayrı bir "kaydet" adımı yok. Silme iki
/// dokunuş ister: yirmi ismi yanlışlıkla silmek geri alınamıyor.
class _ListEditSheet extends StatefulWidget {
  final String title;
  final ValueChanged<String> onRename;
  final VoidCallback onDelete;

  const _ListEditSheet({
    required this.title,
    required this.onRename,
    required this.onDelete,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required ValueChanged<String> onRename,
    required VoidCallback onDelete,
  }) =>
      showModalBottomSheet<void>(
        context: context,
        // Klavye açılınca sayfa onun üstüne çıkabilsin
        isScrollControlled: true,
        backgroundColor: const Color(0xFF1C1C1C),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (_) => _ListEditSheet(
          title: title,
          onRename: onRename,
          onDelete: onDelete,
        ),
      );

  @override
  State<_ListEditSheet> createState() => _ListEditSheetState();
}

class _ListEditSheetState extends State<_ListEditSheet> {
  late final TextEditingController _field =
      TextEditingController(text: widget.title);
  bool _confirmingDelete = false;

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  void _delete() {
    if (!_confirmingDelete) {
      setState(() => _confirmingDelete = true);
      return;
    }
    widget.onDelete();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          22,
          24,
          16 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _field,
              maxLength: NameListTabs.maxTitleLength,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
              onChanged: widget.onRename,
              onSubmitted: (_) => Navigator.of(context).pop(),
              style: const TextStyle(color: Colors.white, fontSize: 18),
              decoration: InputDecoration(
                hintText: l10n.listNameHint,
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
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline, size: 18),
              label: Text(
                _confirmingDelete ? l10n.deleteListConfirm : l10n.deleteList,
              ),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFFF5252),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
