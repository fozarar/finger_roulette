// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get howManyPlayers => 'कितने खिलाड़ी?';

  @override
  String get howManyWinners => 'कितने विजेता?';

  @override
  String putFingers(int count) {
    return '$count उंगलियाँ रखें';
  }

  @override
  String moreFingers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count उंगलियाँ और...',
      one: '1 उंगली और...',
    );
    return '$_temp0';
  }

  @override
  String get getReady => 'तैयार हो जाइए...';

  @override
  String get choosing => 'चुना जा रहा है...';

  @override
  String winnerBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'विजेता!',
      one: 'विजेता!',
    );
    return '$_temp0';
  }

  @override
  String gameInfo(int players, int winners) {
    String _temp0 = intl.Intl.pluralLogic(
      winners,
      locale: localeName,
      other: '$winners विजेता',
      one: '1 विजेता',
    );
    return '$players खिलाड़ी · $_temp0';
  }

  @override
  String get playAgain => 'फिर से खेलें';

  @override
  String get changeSettings => 'सेटिंग्स बदलें';

  @override
  String get modeWinners => 'विजेता';

  @override
  String get modeLosers => 'हारने वाला';

  @override
  String get modeTeams => 'टीम';

  @override
  String get modeOrder => 'क्रम';

  @override
  String get howManyLosers => 'कितने हारने वाले?';

  @override
  String loserBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'हारने वाले!',
      one: 'हारने वाला!',
    );
    return '$_temp0';
  }

  @override
  String get teamsBanner => 'टीमें तैयार!';

  @override
  String get orderBanner => 'क्रम तय हो गया!';

  @override
  String gameInfoLosers(int players, int losers) {
    String _temp0 = intl.Intl.pluralLogic(
      losers,
      locale: localeName,
      other: '$losers हारने वाले',
      one: '1 हारने वाला',
    );
    return '$players खिलाड़ी · $_temp0';
  }

  @override
  String gameInfoTeams(int players, int teams) {
    return '$players खिलाड़ी · $teams टीमें';
  }

  @override
  String gameInfoOrder(int players) {
    return '$players खिलाड़ी · बारी का क्रम';
  }

  @override
  String get modePick => 'चुनें';
}
