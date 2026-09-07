// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get howManyPlayers => 'Combien de joueurs ?';

  @override
  String get howManyWinners => 'Combien de gagnants ?';

  @override
  String putFingers(int count) {
    return 'Posez $count doigts';
  }

  @override
  String moreFingers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Encore $count doigts...',
      one: 'Encore 1 doigt...',
    );
    return '$_temp0';
  }

  @override
  String get getReady => 'Prêts...';

  @override
  String get choosing => 'Sélection...';

  @override
  String winnerBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Gagnants !',
      one: 'Gagnant !',
    );
    return '$_temp0';
  }

  @override
  String gameInfo(int players, int winners) {
    String _temp0 = intl.Intl.pluralLogic(
      winners,
      locale: localeName,
      other: '$winners gagnants',
      one: '1 gagnant',
    );
    return '$players joueurs · $_temp0';
  }

  @override
  String get playAgain => 'Rejouer';

  @override
  String get changeSettings => 'Modifier les réglages';
}
