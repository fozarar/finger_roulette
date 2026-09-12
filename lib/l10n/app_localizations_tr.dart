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

  @override
  String get modeWinners => 'Kazanan';

  @override
  String get modeLosers => 'Kaybeden';

  @override
  String get modeTeams => 'Takım';

  @override
  String get modeOrder => 'Sıra';

  @override
  String get howManyLosers => 'Kaç kaybeden?';

  @override
  String loserBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kaybedenler!',
      one: 'Kaybeden!',
    );
    return '$_temp0';
  }

  @override
  String get teamsBanner => 'Takımlar hazır!';

  @override
  String get orderBanner => 'Sıra belli!';

  @override
  String gameInfoLosers(int players, int losers) {
    String _temp0 = intl.Intl.pluralLogic(
      losers,
      locale: localeName,
      other: '$losers kaybeden',
      one: '1 kaybeden',
    );
    return '$players oyuncu · $_temp0';
  }

  @override
  String gameInfoTeams(int players, int teams) {
    return '$players oyuncu · $teams takım';
  }

  @override
  String gameInfoOrder(int players) {
    return '$players oyuncu · sıralama';
  }

  @override
  String get modePick => 'Seç';
}
