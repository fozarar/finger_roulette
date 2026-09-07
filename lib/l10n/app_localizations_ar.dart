// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get howManyPlayers => 'كم عدد اللاعبين؟';

  @override
  String get howManyWinners => 'كم عدد الفائزين؟';

  @override
  String putFingers(int count) {
    return 'ضع $count أصابع';
  }

  @override
  String moreFingers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count إصبعًا إضافيًا...',
      few: '$count أصابع إضافية...',
      two: 'إصبعان إضافيان...',
      one: 'إصبع واحد إضافي...',
    );
    return '$_temp0';
  }

  @override
  String get getReady => 'استعدوا...';

  @override
  String get choosing => 'جارٍ الاختيار...';

  @override
  String winnerBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'الفائزون!',
      one: 'الفائز!',
    );
    return '$_temp0';
  }

  @override
  String gameInfo(int players, int winners) {
    String _temp0 = intl.Intl.pluralLogic(
      winners,
      locale: localeName,
      other: '$winners فائزًا',
      few: '$winners فائزين',
      two: 'فائزان',
      one: 'فائز واحد',
    );
    return '$players لاعبين · $_temp0';
  }

  @override
  String get playAgain => 'العب مرة أخرى';

  @override
  String get changeSettings => 'تغيير الإعدادات';
}
