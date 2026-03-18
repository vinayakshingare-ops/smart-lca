import 'package:flutter/material.dart';

class TranslationProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;
  bool get isHindi => _locale.languageCode == 'hi';

  void toggleLanguage() {
    if (_locale.languageCode == 'en') {
      _locale = const Locale('hi');
    } else {
      _locale = const Locale('en');
    }
    notifyListeners();
  }

  void setLocale(Locale newLocale) {
    if (newLocale != _locale) {
      _locale = newLocale;
      notifyListeners();
    }
  }
}
