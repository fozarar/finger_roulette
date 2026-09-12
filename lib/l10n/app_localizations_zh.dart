// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get howManyPlayers => '几位玩家？';

  @override
  String get howManyWinners => '几位赢家？';

  @override
  String putFingers(int count) {
    return '请放上 $count 根手指';
  }

  @override
  String moreFingers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '还差 $count 根...',
      one: '还差 1 根...',
    );
    return '$_temp0';
  }

  @override
  String get getReady => '准备...';

  @override
  String get choosing => '正在选择...';

  @override
  String winnerBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '赢家！',
      one: '赢家！',
    );
    return '$_temp0';
  }

  @override
  String gameInfo(int players, int winners) {
    String _temp0 = intl.Intl.pluralLogic(
      winners,
      locale: localeName,
      other: '$winners 位赢家',
      one: '1 位赢家',
    );
    return '$players 位玩家 · $_temp0';
  }

  @override
  String get playAgain => '再玩一次';

  @override
  String get changeSettings => '更改设置';

  @override
  String get modeWinners => '赢家';

  @override
  String get modeLosers => '输家';

  @override
  String get modeTeams => '分队';

  @override
  String get modeOrder => '顺序';

  @override
  String get howManyLosers => '几位输家？';

  @override
  String loserBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '输家！',
      one: '输家！',
    );
    return '$_temp0';
  }

  @override
  String get teamsBanner => '分队完成！';

  @override
  String get orderBanner => '顺序已定！';

  @override
  String gameInfoLosers(int players, int losers) {
    String _temp0 = intl.Intl.pluralLogic(
      losers,
      locale: localeName,
      other: '$losers 位输家',
      one: '1 位输家',
    );
    return '$players 位玩家 · $_temp0';
  }

  @override
  String gameInfoTeams(int players, int teams) {
    return '$players 位玩家 · $teams 队';
  }

  @override
  String gameInfoOrder(int players) {
    return '$players 位玩家 · 排顺序';
  }

  @override
  String get modePick => '选人';
}
