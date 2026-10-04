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

  @override
  String get modeWinners => 'Gagnant';

  @override
  String get modeLosers => 'Perdant';

  @override
  String get modeTeams => 'Équipes';

  @override
  String get modeOrder => 'Ordre';

  @override
  String get howManyLosers => 'Combien de perdants ?';

  @override
  String loserBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Perdants !',
      one: 'Perdant !',
    );
    return '$_temp0';
  }

  @override
  String get teamsBanner => 'Les équipes sont faites !';

  @override
  String get orderBanner => 'Voici l’ordre !';

  @override
  String gameInfoLosers(int players, int losers) {
    String _temp0 = intl.Intl.pluralLogic(
      losers,
      locale: localeName,
      other: '$losers perdants',
      one: '1 perdant',
    );
    return '$players joueurs · $_temp0';
  }

  @override
  String gameInfoTeams(int players, int teams) {
    return '$players joueurs · $teams équipes';
  }

  @override
  String gameInfoOrder(int players) {
    return '$players joueurs · ordre de passage';
  }

  @override
  String get modePick => 'Choisir';

  @override
  String get inputFingers => 'Doigts';

  @override
  String get inputNames => 'Noms';

  @override
  String get addName => 'Ajouter un nom';

  @override
  String get nameHint => 'Nom';

  @override
  String get spin => 'Tourner';

  @override
  String get spinAgain => 'Tourner encore';

  @override
  String get needTwoNames => 'Ajoutez au moins 2 noms';

  @override
  String get continueLabel => 'Continuer';

  @override
  String get share => 'Partager';

  @override
  String get shareMessage => 'Décidé avec Finger Chooser';

  @override
  String get settings => 'Réglages';

  @override
  String get usageStats => 'Statistiques d’utilisation anonymes';

  @override
  String get usageStatsHint =>
      'Aident à améliorer l’app. Les noms et les résultats ne sont jamais envoyés.';
}
