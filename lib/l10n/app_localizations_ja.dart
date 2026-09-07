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
}
