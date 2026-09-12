import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/game_mode.dart';
import '../screens/game_text.dart';

/// Seçim ekranının üstündeki mod seçici: Seç / Takım / Sıra.
///
/// Üç eşit genişlikte kutu. Uzun çeviriler kutuya sığana kadar küçülür,
/// böylece 16 dilin hiçbirinde satır taşmaz.
class ModeSelector extends StatelessWidget {
  final GameMode selected;
  final ValueChanged<GameMode> onSelected;

  const ModeSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  static const Map<GameMode, IconData> _icons = {
    GameMode.pick: Icons.adjust,
    GameMode.teams: Icons.groups_outlined,
    GameMode.order: Icons.format_list_numbered_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          for (final mode in GameMode.values)
            Expanded(
              child: _ModeTile(
                icon: _icons[mode]!,
                label: modeLabelFor(l10n, mode),
                isSelected: mode == selected,
                onTap: () => onSelected(mode),
              ),
            ),
        ],
      ),
    );
  }
}

/// Tek bir mod kutusu. Seçili durumu [OptionButton] ile aynı dili konuşur:
/// kalın beyaz kenarlık ve hafif dolgu.
class _ModeTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeTile({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = isSelected ? Colors.white : Colors.white60;
    return Semantics(
      button: true,
      selected: isSelected,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? Colors.white : Colors.white24,
              width: isSelected ? 2.0 : 1.0,
            ),
            color: isSelected
                ? Colors.white.withAlpha(45)
                : Colors.white.withAlpha(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: foreground, size: 26),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
