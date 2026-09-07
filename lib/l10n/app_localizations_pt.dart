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
}
