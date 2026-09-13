import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../screens/home_screen.dart';
import '../services/names_service.dart';
import '../services/review_service.dart';
import '../services/stats_service.dart';

/// Uygulamanın kök widget'ı — tema ve navigasyon yapılandırması burada
class FingerRouletteApp extends StatelessWidget {
  final StatsService stats;
  final ReviewService review;
  final NamesService nameStore;

  const FingerRouletteApp({
    super.key,
    required this.stats,
    required this.review,
    required this.nameStore,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finger Chooser',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF111111),
        colorScheme: const ColorScheme.dark(),
      ),
      home: HomeScreen(stats: stats, review: review, nameStore: nameStore),
    );
  }
}
