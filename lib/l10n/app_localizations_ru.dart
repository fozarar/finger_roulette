// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get howManyPlayers => 'Сколько игроков?';

  @override
  String get howManyWinners => 'Сколько победителей?';

  @override
  String putFingers(int count) {
    return 'Поставьте $count пальцев';
  }

  @override
  String moreFingers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ещё $count пальцев...',
      few: 'Ещё $count пальца...',
      one: 'Ещё 1 палец...',
    );
    return '$_temp0';
  }

  @override
  String get getReady => 'Приготовьтесь...';

  @override
  String get choosing => 'Выбираем...';

  @override
  String winnerBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Победители!',
      one: 'Победитель!',
    );
    return '$_temp0';
  }

  @override
  String gameInfo(int players, int winners) {
    String _temp0 = intl.Intl.pluralLogic(
      winners,
      locale: localeName,
      other: '$winners победителей',
      few: '$winners победителя',
      one: '1 победитель',
    );
    return '$players игроков · $_temp0';
  }

  @override
  String get playAgain => 'Играть снова';

  @override
  String get changeSettings => 'Изменить настройки';
}
