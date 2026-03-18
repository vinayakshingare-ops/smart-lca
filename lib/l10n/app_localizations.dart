import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('en'),
    Locale('hi')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'SmartLCA Mine'**
  String get appName;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabScanner.
  ///
  /// In en, this message translates to:
  /// **'Scanner'**
  String get tabScanner;

  /// No description provided for @tabStore.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get tabStore;

  /// No description provided for @tabMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get tabMap;

  /// No description provided for @tabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabProfile;

  /// No description provided for @homeEcoScore.
  ///
  /// In en, this message translates to:
  /// **'Eco Score'**
  String get homeEcoScore;

  /// No description provided for @homeMiningAlert.
  ///
  /// In en, this message translates to:
  /// **'Mining Alert'**
  String get homeMiningAlert;

  /// No description provided for @homeTopAlternative.
  ///
  /// In en, this message translates to:
  /// **'Top Alternative'**
  String get homeTopAlternative;

  /// No description provided for @homeTopAlternativeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Bamboo Bottle: -2kg CO2'**
  String get homeTopAlternativeSubtitle;

  /// No description provided for @homeQuickScanner.
  ///
  /// In en, this message translates to:
  /// **'Quick Scanner'**
  String get homeQuickScanner;

  /// No description provided for @homeQuickScannerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scan any product barcode'**
  String get homeQuickScannerSubtitle;

  /// No description provided for @homeFindAction.
  ///
  /// In en, this message translates to:
  /// **'Find recycling bins near you'**
  String get homeFindAction;

  /// No description provided for @storeTitle.
  ///
  /// In en, this message translates to:
  /// **'Eco-Friendly Products'**
  String get storeTitle;

  /// No description provided for @storeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search products...'**
  String get storeSearchHint;

  /// No description provided for @storeBuyNow.
  ///
  /// In en, this message translates to:
  /// **'Buy Now'**
  String get storeBuyNow;

  /// No description provided for @scannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Product Scanner'**
  String get scannerTitle;

  /// No description provided for @scannerDetecting.
  ///
  /// In en, this message translates to:
  /// **'Detecting...'**
  String get scannerDetecting;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileRank.
  ///
  /// In en, this message translates to:
  /// **'Rank'**
  String get profileRank;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileSettings;

  /// No description provided for @profileLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguage;

  /// No description provided for @profileDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get profileDarkMode;

  /// No description provided for @profileLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get profileLeaderboard;

  /// No description provided for @mapMiningMonitor.
  ///
  /// In en, this message translates to:
  /// **'Mining Monitor'**
  String get mapMiningMonitor;

  /// No description provided for @mapVegetationAlert.
  ///
  /// In en, this message translates to:
  /// **'Vegetation Alert:\nZone C NDVI dropped -0.15'**
  String get mapVegetationAlert;

  /// No description provided for @mapRecyclingCenters.
  ///
  /// In en, this message translates to:
  /// **'Recycling Centers'**
  String get mapRecyclingCenters;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
