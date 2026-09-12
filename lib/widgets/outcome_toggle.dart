import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/game_mode.dart';
import '../screens/game_text.dart';

/// Seç modunda seçilenlerin kazanan mı kaybeden mi olduğunu belirleyen düğme.
///
/// Çekiliş iki durumda da aynı; değişen yalnızca kutlamanın kime yapıldığı.
/// Oyuncu sayısının üstünde durur: 2 oyuncuda sayı sorusu atlanıp oyun hemen
/// başladığı için bu karar ondan önce verilebilmeli.
class OutcomeToggle extends StatelessWidget {
  final PickOutcome selected;
  final ValueChanged<PickOutcome> onSelected;

  const OutcomeToggle({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  static const Map<PickOutcome, IconData> _icons = {
    PickOutcome.winners: Icons.emoji_events_outlined,
    PickOutcome.losers: Icons.sentiment_very_dissatisfied_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Uzun çevirilerde (örneğin Rusça "Проигравший") dar ekranlarda küçülsün
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white24),
          color: Colors.white.withAlpha(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final outcome in PickOutcome.values)
              _OutcomeSegment(
                icon: _icons[outcome]!,
                label: outcomeLabelFor(l10n, outcome),
                isSelected: outcome == selected,
                onTap: () => onSelected(outcome),
              ),
          ],
        ),
      ),
    );
  }
}

/// Düğmenin tek bir yarısı
class _OutcomeSegment extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _OutcomeSegment({
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
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: isSelected ? Colors.white.withAlpha(45) : Colors.transparent,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: foreground),
              const SizedBox(width: 7),
              Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  color: foreground,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
