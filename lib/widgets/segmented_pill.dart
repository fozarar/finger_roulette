import 'package:flutter/material.dart';

/// İki ya da üç seçenekli, hap biçiminde seçim düğmesi.
///
/// Seçim ekranında iki yerde kullanılıyor: katılımcılar nereden geliyor
/// (parmak / isim) ve seçilenler ne oluyor (kazanan / kaybeden). İkisi de
/// mod kutularının altında duran, kutulardan daha hafif görünmesi gereken
/// ikincil kararlar — bu yüzden aynı biçim.
class SegmentedPill<T> extends StatelessWidget {
  final List<T> values;
  final T selected;
  final IconData Function(T value) iconFor;
  final String Function(T value) labelFor;
  final ValueChanged<T> onSelected;

  const SegmentedPill({
    super.key,
    required this.values,
    required this.selected,
    required this.iconFor,
    required this.labelFor,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Uzun çevirilerde (örneğin Rusça "Проигравший") dar ekranlarda küçülsün
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white24),
          color: Colors.white.withValues(alpha: 0.03),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final value in values)
              _Segment(
                icon: iconFor(value),
                label: labelFor(value),
                isSelected: value == selected,
                onTap: () => onSelected(value),
              ),
          ],
        ),
      ),
    );
  }
}

/// Hapın tek bir bölümü
class _Segment extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _Segment({
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
            color: isSelected
                ? Colors.white.withValues(alpha: 0.18)
                : Colors.transparent,
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
