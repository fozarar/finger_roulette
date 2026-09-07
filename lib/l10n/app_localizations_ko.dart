// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get howManyPlayers => '플레이어는 몇 명?';

  @override
  String get howManyWinners => '당첨자는 몇 명?';

  @override
  String putFingers(int count) {
    return '손가락 $count개를 올리세요';
  }

  @override
  String moreFingers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개 더...',
      one: '1개 더...',
    );
    return '$_temp0';
  }

  @override
  String get getReady => '준비...';

  @override
  String get choosing => '고르는 중...';

  @override
  String winnerBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '당첨!',
      one: '당첨!',
    );
    return '$_temp0';
  }

  @override
  String gameInfo(int players, int winners) {
    String _temp0 = intl.Intl.pluralLogic(
      winners,
      locale: localeName,
      other: '당첨 $winners명',
      one: '당첨 1명',
    );
    return '$players명 · $_temp0';
  }

  @override
  String get playAgain => '다시 하기';

  @override
  String get changeSettings => '설정 변경';
}
