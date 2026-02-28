import 'package:flutter/material.dart';

import '../screens/home_screen.dart';

/// Uygulamanın kök widget'ı — tema ve navigasyon yapılandırması burada
class FingerRouletteApp extends StatelessWidget {
  const FingerRouletteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finger Roulette',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF111111),
        colorScheme: const ColorScheme.dark(),
      ),
      home: const HomeScreen(),
    );
  }
}
