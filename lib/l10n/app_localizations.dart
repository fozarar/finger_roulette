import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_id.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_ms.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_th.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('id'),
    Locale('ja'),
    Locale('ko'),
    Locale('ms'),
    Locale('pt'),
    Locale('ru'),
    Locale('th'),
    Locale('tr'),
    Locale('vi'),
    Locale('zh'),
  ];

  /// Selection screen: player count prompt
  ///
  /// In en, this message translates to:
  /// **'How many players?'**
  String get howManyPlayers;

  /// Selection screen: winner count prompt
  ///
  /// In en, this message translates to:
  /// **'How many winners?'**
  String get howManyWinners;

  /// Waiting phase, no fingers on screen yet
  ///
  /// In en, this message translates to:
  /// **'Put {count} fingers'**
  String putFingers(int count);

  /// Waiting phase, some fingers already down
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 more finger...} other{{count} more fingers...}}'**
  String moreFingers(int count);

  /// All fingers detected, lock countdown running
  ///
  /// In en, this message translates to:
  /// **'Get ready...'**
  String get getReady;

  /// Cycle animation is running
  ///
  /// In en, this message translates to:
  /// **'Choosing...'**
  String get choosing;

  /// Shown when winners are revealed
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Winner!} other{Winners!}}'**
  String winnerBanner(int count);

  /// Small label at the top of the game screen
  ///
  /// In en, this message translates to:
  /// **'{players} players · {winners, plural, =1{1 winner} other{{winners} winners}}'**
  String gameInfo(int players, int winners);

  /// Button: restart with the same settings
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get playAgain;

  /// Button: go back to the selection screen
  ///
  /// In en, this message translates to:
  /// **'Change Settings'**
  String get changeSettings;

  /// Selection screen: the picked fingers win. Half of a two-part toggle, keep it short
  ///
  /// In en, this message translates to:
  /// **'Winner'**
  String get modeWinners;

  /// Selection screen: the picked fingers lose (who pays the bill, who does the dishes). Half of a two-part toggle, keep it short
  ///
  /// In en, this message translates to:
  /// **'Loser'**
  String get modeLosers;

  /// Selection screen: mode tile. All fingers are split into teams. One or two words
  ///
  /// In en, this message translates to:
  /// **'Teams'**
  String get modeTeams;

  /// Selection screen: mode tile. Every finger gets a turn number (who goes first). One or two words
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get modeOrder;

  /// Selection screen: loser count prompt
  ///
  /// In en, this message translates to:
  /// **'How many losers?'**
  String get howManyLosers;

  /// Shown when losers are revealed
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Loser!} other{Losers!}}'**
  String loserBanner(int count);

  /// Shown when teams are revealed; each circle shows its team letter
  ///
  /// In en, this message translates to:
  /// **'Teams are set!'**
  String get teamsBanner;

  /// Shown when the turn order is revealed; each circle shows its number
  ///
  /// In en, this message translates to:
  /// **'Here’s the order!'**
  String get orderBanner;

  /// Small label at the top of the game screen in loser mode
  ///
  /// In en, this message translates to:
  /// **'{players} players · {losers, plural, =1{1 loser} other{{losers} losers}}'**
  String gameInfoLosers(int players, int losers);

  /// Small label at the top of the game screen in team mode
  ///
  /// In en, this message translates to:
  /// **'{players} players · {teams} teams'**
  String gameInfoTeams(int players, int teams);

  /// Small label at the top of the game screen in turn order mode
  ///
  /// In en, this message translates to:
  /// **'{players} players · turn order'**
  String gameInfoOrder(int players);

  /// Selection screen: mode tile. Some of the fingers get picked. One or two words, the tile is narrow
  ///
  /// In en, this message translates to:
  /// **'Pick'**
  String get modePick;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'id',
    'ja',
    'ko',
    'ms',
    'pt',
    'ru',
    'th',
    'tr',
    'vi',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'id':
      return AppLocalizationsId();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'ms':
      return AppLocalizationsMs();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'th':
      return AppLocalizationsTh();
    case 'tr':
      return AppLocalizationsTr();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
