// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get howManyPlayers => 'Berapa pemain?';

  @override
  String get howManyWinners => 'Berapa pemenang?';

  @override
  String putFingers(int count) {
    return 'Letakkan $count jari';
  }

  @override
  String moreFingers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jari lagi...',
      one: '1 jari lagi...',
    );
    return '$_temp0';
  }

  @override
  String get getReady => 'Bersiap...';

  @override
  String get choosing => 'Memilih...';

  @override
  String winnerBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Pemenang!',
      one: 'Pemenang!',
    );
    return '$_temp0';
  }

  @override
  String gameInfo(int players, int winners) {
    String _temp0 = intl.Intl.pluralLogic(
      winners,
      locale: localeName,
      other: '$winners pemenang',
      one: '1 pemenang',
    );
    return '$players pemain · $_temp0';
  }

  @override
  String get playAgain => 'Main Lagi';

  @override
  String get changeSettings => 'Ubah Pengaturan';
}
