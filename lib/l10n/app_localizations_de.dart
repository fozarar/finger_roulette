// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get howManyPlayers => 'Wie viele Spieler?';

  @override
  String get howManyWinners => 'Wie viele Gewinner?';

  @override
  String putFingers(int count) {
    return 'Legt $count Finger auf';
  }

  @override
  String moreFingers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Noch $count Finger...',
      one: 'Noch 1 Finger...',
    );
    return '$_temp0';
  }

  @override
  String get getReady => 'Bereit machen...';

  @override
  String get choosing => 'Wird gewählt...';

  @override
  String winnerBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Gewinner!',
      one: 'Gewinner!',
    );
    return '$_temp0';
  }

  @override
  String gameInfo(int players, int winners) {
    String _temp0 = intl.Intl.pluralLogic(
      winners,
      locale: localeName,
      other: '$winners Gewinner',
      one: '1 Gewinner',
    );
    return '$players Spieler · $_temp0';
  }

  @override
  String get playAgain => 'Nochmal spielen';

  @override
  String get changeSettings => 'Einstellungen ändern';
}
