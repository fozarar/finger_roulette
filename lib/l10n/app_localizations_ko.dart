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

  @override
  String get modeWinners => '당첨';

  @override
  String get modeLosers => '꽝';

  @override
  String get modeTeams => '팀 나누기';

  @override
  String get modeOrder => '순서';

  @override
  String get howManyLosers => '꽝은 몇 명?';

  @override
  String loserBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '꽝!',
      one: '꽝!',
    );
    return '$_temp0';
  }

  @override
  String get teamsBanner => '팀 완성!';

  @override
  String get orderBanner => '순서 결정!';

  @override
  String gameInfoLosers(int players, int losers) {
    String _temp0 = intl.Intl.pluralLogic(
      losers,
      locale: localeName,
      other: '꽝 $losers명',
      one: '꽝 1명',
    );
    return '$players명 · $_temp0';
  }

  @override
  String gameInfoTeams(int players, int teams) {
    return '$players명 · $teams팀';
  }

  @override
  String gameInfoOrder(int players) {
    return '$players명 · 순서 정하기';
  }

  @override
  String get modePick => '뽑기';

  @override
  String get inputFingers => '손가락';

  @override
  String get inputNames => '이름';

  @override
  String get addName => '이름 추가';

  @override
  String get nameHint => '이름';

  @override
  String get spin => '돌리기';

  @override
  String get spinAgain => '다시 돌리기';

  @override
  String get needTwoNames => '이름을 2개 이상 추가하세요';

  @override
  String get continueLabel => '계속';

  @override
  String get share => '공유';

  @override
  String get shareMessage => 'Finger Chooser로 결정했어요';

  @override
  String get settings => '설정';

  @override
  String get usageStats => '익명 사용 통계';

  @override
  String get usageStatsHint => '앱 개선에 도움이 됩니다. 이름과 결과는 전송되지 않습니다.';

  @override
  String get howManyTeams => '몇 팀으로 나눌까요?';
}
