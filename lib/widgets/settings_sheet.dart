import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/stats_service.dart';

/// Seçim ekranından açılan ayarlar sayfası.
///
/// Şimdilik tek ayarı var: anonim kullanım istatistikleri. Varsayılan açık;
/// kapatıldığında hem bizim olaylarımız hem de analitik servisinin kendi
/// topladıkları durur.
class SettingsSheet extends StatefulWidget {
  final StatsService stats;

  const SettingsSheet({super.key, required this.stats});

  static Future<void> show(BuildContext context, StatsService stats) =>
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: const Color(0xFF1C1C1C),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (_) => SettingsSheet(stats: stats),
      );

  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  late bool _usageStats = widget.stats.analyticsEnabled;

  void _setUsageStats(bool value) {
    setState(() => _usageStats = value);
    widget.stats.setAnalyticsEnabled(value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.settings,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _usageStats,
              onChanged: _setUsageStats,
              activeThumbColor: Colors.black,
              activeTrackColor: Colors.white,
              inactiveThumbColor: Colors.white54,
              inactiveTrackColor: Colors.white12,
              title: Text(
                l10n.usageStats,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  l10n.usageStatsHint,
                  style: const TextStyle(
                    color: Color(0x99FFFFFF),
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
