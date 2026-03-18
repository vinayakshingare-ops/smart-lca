// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'SmartLCA Mine';

  @override
  String get tabHome => 'Home';

  @override
  String get tabScanner => 'Scanner';

  @override
  String get tabStore => 'Store';

  @override
  String get tabMap => 'Map';

  @override
  String get tabProfile => 'Profile';

  @override
  String get homeEcoScore => 'Eco Score';

  @override
  String get homeMiningAlert => 'Mining Alert';

  @override
  String get homeTopAlternative => 'Top Alternative';

  @override
  String get homeTopAlternativeSubtitle => 'Bamboo Bottle: -2kg CO2';

  @override
  String get homeQuickScanner => 'Quick Scanner';

  @override
  String get homeQuickScannerSubtitle => 'Scan any product barcode';

  @override
  String get homeFindAction => 'Find recycling bins near you';

  @override
  String get storeTitle => 'Eco-Friendly Products';

  @override
  String get storeSearchHint => 'Search products...';

  @override
  String get storeBuyNow => 'Buy Now';

  @override
  String get scannerTitle => 'Product Scanner';

  @override
  String get scannerDetecting => 'Detecting...';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileRank => 'Rank';

  @override
  String get profileSettings => 'Settings';

  @override
  String get profileLanguage => 'Language';

  @override
  String get profileDarkMode => 'Dark Mode';

  @override
  String get profileLeaderboard => 'Leaderboard';

  @override
  String get mapMiningMonitor => 'Mining Monitor';

  @override
  String get mapVegetationAlert =>
      'Vegetation Alert:\nZone C NDVI dropped -0.15';

  @override
  String get mapRecyclingCenters => 'Recycling Centers';
}
