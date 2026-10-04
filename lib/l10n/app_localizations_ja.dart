// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get howManyPlayers => 'プレイヤーは何人？';

  @override
  String get howManyWinners => '当たりは何人？';

  @override
  String putFingers(int count) {
    return '指を$count本置いてください';
  }

  @override
  String moreFingers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'あと$count本...',
      one: 'あと1本...',
    );
    return '$_temp0';
  }

  @override
  String get getReady => '準備して...';

  @override
  String get choosing => '選んでいます...';

  @override
  String winnerBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '当たり！',
      one: '当たり！',
    );
    return '$_temp0';
  }

  @override
  String gameInfo(int players, int winners) {
    String _temp0 = intl.Intl.pluralLogic(
      winners,
      locale: localeName,
      other: '当たり$winners人',
      one: '当たり1人',
    );
    return '$players人 · $_temp0';
  }

  @override
  String get playAgain => 'もう一度';

  @override
  String get changeSettings => '設定を変更';

  @override
  String get modeWinners => '当たり';

  @override
  String get modeLosers => 'ハズレ';

  @override
  String get modeTeams => 'チーム分け';

  @override
  String get modeOrder => '順番';

  @override
  String get howManyLosers => 'ハズレは何人？';

  @override
  String loserBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ハズレ！',
      one: 'ハズレ！',
    );
    return '$_temp0';
  }

  @override
  String get teamsBanner => 'チーム決定！';

  @override
  String get orderBanner => '順番決定！';

  @override
  String gameInfoLosers(int players, int losers) {
    String _temp0 = intl.Intl.pluralLogic(
      losers,
      locale: localeName,
      other: 'ハズレ$losers人',
      one: 'ハズレ1人',
    );
    return '$players人 · $_temp0';
  }

  @override
  String gameInfoTeams(int players, int teams) {
    return '$players人 · $teamsチーム';
  }

  @override
  String gameInfoOrder(int players) {
    return '$players人 · 順番決め';
  }

  @override
  String get modePick => '選ぶ';

  @override
  String get inputFingers => '指';

  @override
  String get inputNames => '名前';

  @override
  String get addName => '名前を追加';

  @override
  String get nameHint => '名前';

  @override
  String get spin => '回す';

  @override
  String get spinAgain => 'もう一度回す';

  @override
  String get needTwoNames => '名前を2つ以上追加してください';

  @override
  String get continueLabel => '次へ';

  @override
  String get share => '共有';

  @override
  String get shareMessage => 'Finger Chooserで決めました';

  @override
  String get settings => '設定';

  @override
  String get usageStats => '匿名の利用統計';

  @override
  String get usageStatsHint => 'アプリの改善に役立ちます。名前や結果は送信されません。';
}
