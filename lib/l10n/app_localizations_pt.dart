// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get howManyPlayers => 'Quantos jogadores?';

  @override
  String get howManyWinners => 'Quantos vencedores?';

  @override
  String putFingers(int count) {
    return 'Coloque $count dedos';
  }

  @override
  String moreFingers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mais $count dedos...',
      one: 'Mais 1 dedo...',
    );
    return '$_temp0';
  }

  @override
  String get getReady => 'Preparar...';

  @override
  String get choosing => 'Escolhendo...';

  @override
  String winnerBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vencedores!',
      one: 'Vencedor!',
    );
    return '$_temp0';
  }

  @override
  String gameInfo(int players, int winners) {
    String _temp0 = intl.Intl.pluralLogic(
      winners,
      locale: localeName,
      other: '$winners vencedores',
      one: '1 vencedor',
    );
    return '$players jogadores · $_temp0';
  }

  @override
  String get playAgain => 'Jogar de novo';

  @override
  String get changeSettings => 'Mudar configurações';

  @override
  String get modeWinners => 'Vencedor';

  @override
  String get modeLosers => 'Perdedor';

  @override
  String get modeTeams => 'Times';

  @override
  String get modeOrder => 'Ordem';

  @override
  String get howManyLosers => 'Quantos perdedores?';

  @override
  String loserBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Perdedores!',
      one: 'Perdedor!',
    );
    return '$_temp0';
  }

  @override
  String get teamsBanner => 'Times formados!';

  @override
  String get orderBanner => 'Esta é a ordem!';

  @override
  String gameInfoLosers(int players, int losers) {
    String _temp0 = intl.Intl.pluralLogic(
      losers,
      locale: localeName,
      other: '$losers perdedores',
      one: '1 perdedor',
    );
    return '$players jogadores · $_temp0';
  }

  @override
  String gameInfoTeams(int players, int teams) {
    return '$players jogadores · $teams times';
  }

  @override
  String gameInfoOrder(int players) {
    return '$players jogadores · ordem de jogada';
  }

  @override
  String get modePick => 'Escolher';
}
