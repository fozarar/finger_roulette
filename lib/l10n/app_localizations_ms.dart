// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malay (`ms`).
class AppLocalizationsMs extends AppLocalizations {
  AppLocalizationsMs([String locale = 'ms']) : super(locale);

  @override
  String get howManyPlayers => 'Berapa pemain?';

  @override
  String get howManyWinners => 'Berapa pemenang?';

  @override
  String putFingers(int count) {
    return 'Letak $count jari';
  }

  @override
  String moreFingers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jari lagi...',
      one: '1 jari lagi...',
    );
    return '$_temp0';
  }

  @override
  String get getReady => 'Bersedia...';

  @override
  String get choosing => 'Memilih...';

  @override
  String winnerBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Pemenang!',
      one: 'Pemenang!',
    );
    return '$_temp0';
  }

  @override
  String gameInfo(int players, int winners) {
    String _temp0 = intl.Intl.pluralLogic(
      winners,
      locale: localeName,
      other: '$winners pemenang',
      one: '1 pemenang',
    );
    return '$players pemain · $_temp0';
  }

  @override
  String get playAgain => 'Main Semula';

  @override
  String get changeSettings => 'Tukar Tetapan';

  @override
  String get modeWinners => 'Pemenang';

  @override
  String get modeLosers => 'Yang Kalah';

  @override
  String get modeTeams => 'Pasukan';

  @override
  String get modeOrder => 'Giliran';

  @override
  String get howManyLosers => 'Berapa yang kalah?';

  @override
  String loserBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kalah!',
      one: 'Kalah!',
    );
    return '$_temp0';
  }

  @override
  String get teamsBanner => 'Pasukan sudah dibahagi!';

  @override
  String get orderBanner => 'Ini gilirannya!';

  @override
  String gameInfoLosers(int players, int losers) {
    String _temp0 = intl.Intl.pluralLogic(
      losers,
      locale: localeName,
      other: '$losers kalah',
      one: '1 kalah',
    );
    return '$players pemain · $_temp0';
  }

  @override
  String gameInfoTeams(int players, int teams) {
    return '$players pemain · $teams pasukan';
  }

  @override
  String gameInfoOrder(int players) {
    return '$players pemain · giliran';
  }

  @override
  String get modePick => 'Pilih';
}
