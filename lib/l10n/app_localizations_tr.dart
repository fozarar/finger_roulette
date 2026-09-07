// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get howManyPlayers => 'Kaç oyuncu?';

  @override
  String get howManyWinners => 'Kaç kazanan?';

  @override
  String putFingers(int count) {
    return '$count parmak koyun';
  }

  @override
  String moreFingers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count parmak daha...',
      one: '1 parmak daha...',
    );
    return '$_temp0';
  }

  @override
  String get getReady => 'Hazır olun...';

  @override
  String get choosing => 'Seçiliyor...';

  @override
  String winnerBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kazananlar!',
      one: 'Kazanan!',
    );
    return '$_temp0';
  }

  @override
  String gameInfo(int players, int winners) {
    String _temp0 = intl.Intl.pluralLogic(
      winners,
      locale: localeName,
      other: '$winners kazanan',
      one: '1 kazanan',
    );
    return '$players oyuncu · $_temp0';
  }

  @override
  String get playAgain => 'Tekrar Oyna';

  @override
  String get changeSettings => 'Ayarları Değiştir';
}
