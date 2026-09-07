// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get howManyPlayers => 'How many players?';

  @override
  String get howManyWinners => 'How many winners?';

  @override
  String putFingers(int count) {
    return 'Put $count fingers';
  }

  @override
  String moreFingers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more fingers...',
      one: '1 more finger...',
    );
    return '$_temp0';
  }

  @override
  String get getReady => 'Get ready...';

  @override
  String get choosing => 'Choosing...';

  @override
  String winnerBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Winners!',
      one: 'Winner!',
    );
    return '$_temp0';
  }

  @override
  String gameInfo(int players, int winners) {
    String _temp0 = intl.Intl.pluralLogic(
      winners,
      locale: localeName,
      other: '$winners winners',
      one: '1 winner',
    );
    return '$players players · $_temp0';
  }

  @override
  String get playAgain => 'Play Again';

  @override
  String get changeSettings => 'Change Settings';
}
