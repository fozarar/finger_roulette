// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get howManyPlayers => 'Bao nhiêu người chơi?';

  @override
  String get howManyWinners => 'Bao nhiêu người thắng?';

  @override
  String putFingers(int count) {
    return 'Đặt $count ngón tay';
  }

  @override
  String moreFingers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Thêm $count ngón tay...',
      one: 'Thêm 1 ngón tay...',
    );
    return '$_temp0';
  }

  @override
  String get getReady => 'Sẵn sàng...';

  @override
  String get choosing => 'Đang chọn...';

  @override
  String winnerBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Người thắng!',
      one: 'Người thắng!',
    );
    return '$_temp0';
  }

  @override
  String gameInfo(int players, int winners) {
    String _temp0 = intl.Intl.pluralLogic(
      winners,
      locale: localeName,
      other: '$winners người thắng',
      one: '1 người thắng',
    );
    return '$players người chơi · $_temp0';
  }

  @override
  String get playAgain => 'Chơi lại';

  @override
  String get changeSettings => 'Đổi cài đặt';
}
