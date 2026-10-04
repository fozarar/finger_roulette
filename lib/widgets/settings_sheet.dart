import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/sound_service.dart';
import '../services/stats_service.dart';

/// Seçim ekranından açılan ayarlar sayfası.
///
/// İki ayar var, ikisi de varsayılan olarak açık: ses efektleri ve anonim
/// kullanım istatistikleri. Tercihleri servisler saklar; bu widget yalnızca
/// anahtarın o anki konumunu tutar.
class SettingsSheet extends StatefulWidget {
  final StatsService stats;
  final SoundService sound;

  const SettingsSheet({super.key, required this.stats, required this.sound});

  static Future<void> show(
    BuildContext context, {
    required StatsService stats,
    required SoundService sound,
  }) =>
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: const Color(0xFF1C1C1C),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (_) => SettingsSheet(stats: stats, sound: sound),
      );

  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  late bool _sound = widget.sound.enabled;
  late bool _usageStats = widget.stats.analyticsEnabled;

  void _setSound(bool value) {
    setState(() => _sound = value);
    widget.sound.setEnabled(value);
  }

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
            _SettingSwitch(
              key: const ValueKey('setting-sound'),
              title: l10n.soundEffects,
              hint: l10n.soundEffectsHint,
              value: _sound,
              onChanged: _setSound,
            ),
            const SizedBox(height: 6),
            _SettingSwitch(
              key: const ValueKey('setting-usage-stats'),
              title: l10n.usageStats,
              hint: l10n.usageStatsHint,
              value: _usageStats,
              onChanged: _setUsageStats,
            ),
          ],
        ),
      ),
    );
  }
}

/// Başlığı, açıklaması ve anahtarı olan tek bir ayar satırı
class _SettingSwitch extends StatelessWidget {
  final String title;
  final String hint;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingSwitch({
    super.key,
    required this.title,
    required this.hint,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => SwitchListTile(
        contentPadding: EdgeInsets.zero,
        value: value,
        onChanged: onChanged,
        activeThumbColor: Colors.black,
        activeTrackColor: Colors.white,
        inactiveThumbColor: Colors.white54,
        inactiveTrackColor: Colors.white12,
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            hint,
            style: const TextStyle(
              color: Color(0x99FFFFFF),
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ),
      );
}
