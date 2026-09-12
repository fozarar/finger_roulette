// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get howManyPlayers => '¿Cuántos jugadores?';

  @override
  String get howManyWinners => '¿Cuántos ganadores?';

  @override
  String putFingers(int count) {
    return 'Pon $count dedos';
  }

  @override
  String moreFingers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dedos más...',
      one: '1 dedo más...',
    );
    return '$_temp0';
  }

  @override
  String get getReady => 'Preparados...';

  @override
  String get choosing => 'Eligiendo...';

  @override
  String winnerBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '¡Ganadores!',
      one: '¡Ganador!',
    );
    return '$_temp0';
  }

  @override
  String gameInfo(int players, int winners) {
    String _temp0 = intl.Intl.pluralLogic(
      winners,
      locale: localeName,
      other: '$winners ganadores',
      one: '1 ganador',
    );
    return '$players jugadores · $_temp0';
  }

  @override
  String get playAgain => 'Jugar de nuevo';

  @override
  String get changeSettings => 'Cambiar ajustes';

  @override
  String get modeWinners => 'Ganador';

  @override
  String get modeLosers => 'Perdedor';

  @override
  String get modeTeams => 'Equipos';

  @override
  String get modeOrder => 'Orden';

  @override
  String get howManyLosers => '¿Cuántos perdedores?';

  @override
  String loserBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '¡Perdedores!',
      one: '¡Perdedor!',
    );
    return '$_temp0';
  }

  @override
  String get teamsBanner => '¡Equipos listos!';

  @override
  String get orderBanner => '¡Este es el orden!';

  @override
  String gameInfoLosers(int players, int losers) {
    String _temp0 = intl.Intl.pluralLogic(
      losers,
      locale: localeName,
      other: '$losers perdedores',
      one: '1 perdedor',
    );
    return '$players jugadores · $_temp0';
  }

  @override
  String gameInfoTeams(int players, int teams) {
    return '$players jugadores · $teams equipos';
  }

  @override
  String gameInfoOrder(int players) {
    return '$players jugadores · orden de turnos';
  }

  @override
  String get modePick => 'Elegir';
}
