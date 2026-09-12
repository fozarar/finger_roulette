// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get howManyPlayers => 'ผู้เล่นกี่คน?';

  @override
  String get howManyWinners => 'ผู้ชนะกี่คน?';

  @override
  String putFingers(int count) {
    return 'วาง $count นิ้ว';
  }

  @override
  String moreFingers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'อีก $count นิ้ว...',
      one: 'อีก 1 นิ้ว...',
    );
    return '$_temp0';
  }

  @override
  String get getReady => 'เตรียมตัว...';

  @override
  String get choosing => 'กำลังเลือก...';

  @override
  String winnerBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ผู้ชนะ!',
      one: 'ผู้ชนะ!',
    );
    return '$_temp0';
  }

  @override
  String gameInfo(int players, int winners) {
    String _temp0 = intl.Intl.pluralLogic(
      winners,
      locale: localeName,
      other: 'ผู้ชนะ $winners คน',
      one: 'ผู้ชนะ 1 คน',
    );
    return '$players ผู้เล่น · $_temp0';
  }

  @override
  String get playAgain => 'เล่นอีกครั้ง';

  @override
  String get changeSettings => 'เปลี่ยนการตั้งค่า';

  @override
  String get modeWinners => 'ผู้ชนะ';

  @override
  String get modeLosers => 'ผู้แพ้';

  @override
  String get modeTeams => 'แบ่งทีม';

  @override
  String get modeOrder => 'ลำดับ';

  @override
  String get howManyLosers => 'ผู้แพ้กี่คน?';

  @override
  String loserBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ผู้แพ้!',
      one: 'ผู้แพ้!',
    );
    return '$_temp0';
  }

  @override
  String get teamsBanner => 'แบ่งทีมเรียบร้อย!';

  @override
  String get orderBanner => 'ได้ลำดับแล้ว!';

  @override
  String gameInfoLosers(int players, int losers) {
    String _temp0 = intl.Intl.pluralLogic(
      losers,
      locale: localeName,
      other: 'ผู้แพ้ $losers คน',
      one: 'ผู้แพ้ 1 คน',
    );
    return '$players ผู้เล่น · $_temp0';
  }

  @override
  String gameInfoTeams(int players, int teams) {
    return '$players ผู้เล่น · $teams ทีม';
  }

  @override
  String gameInfoOrder(int players) {
    return '$players ผู้เล่น · ลำดับการเล่น';
  }

  @override
  String get modePick => 'เลือก';
}
