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
      players,
      locale: localeName,
      other: '$players игроков',
      few: '$players игрока',
    );
    String _temp1 = intl.Intl.pluralLogic(
      winners,
      locale: localeName,
      other: '$winners победителей',
      few: '$winners победителя',
      one: '1 победитель',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get playAgain => 'Играть снова';

  @override
  String get changeSettings => 'Изменить настройки';

  @override
  String get modeWinners => 'Победитель';

  @override
  String get modeLosers => 'Проигравший';

  @override
  String get modeTeams => 'Команды';

  @override
  String get modeOrder => 'Порядок';

  @override
  String get howManyLosers => 'Сколько проигравших?';

  @override
  String loserBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Проигравшие!',
      one: 'Проигравший!',
    );
    return '$_temp0';
  }

  @override
  String get teamsBanner => 'Команды готовы!';

  @override
  String get orderBanner => 'Порядок определён!';

  @override
  String gameInfoLosers(int players, int losers) {
    String _temp0 = intl.Intl.pluralLogic(
      players,
      locale: localeName,
      other: '$players игроков',
      few: '$players игрока',
    );
    String _temp1 = intl.Intl.pluralLogic(
      losers,
      locale: localeName,
      other: '$losers проигравших',
      one: '1 проигравший',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String gameInfoTeams(int players, int teams) {
    String _temp0 = intl.Intl.pluralLogic(
      players,
      locale: localeName,
      other: '$players игроков',
      few: '$players игрока',
    );
    String _temp1 = intl.Intl.pluralLogic(
      teams,
      locale: localeName,
      other: '$teams команд',
      few: '$teams команды',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String gameInfoOrder(int players) {
    String _temp0 = intl.Intl.pluralLogic(
      players,
      locale: localeName,
      other: '$players игроков',
      few: '$players игрока',
    );
    return '$_temp0 · очерёдность';
  }

  @override
  String get modePick => 'Выбор';
}
