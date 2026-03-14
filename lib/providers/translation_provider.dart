import 'package:flutter/material.dart';

class TranslationProvider extends ChangeNotifier {
  bool _isHindi = false;

  bool get isHindi => _isHindi;

  void toggleLanguage() {
    _isHindi = !_isHindi;
    notifyListeners();
  }

  // Very simple dictionary approach for MVP
  final Map<String, String> _en = {
    'home': 'Home',
    'scanner': 'Scanner',
    'products': 'Products',
    'maps': 'Maps',
    'profile': 'Profile',
    'scan_product': 'Scan Product',
    'eco_products': 'Eco Products',
    'eco_store': 'Eco Store',
    'connect_impact': 'Connect mining impacts to your choices!',
  };

  final Map<String, String> _hi = {
    'home': 'होम',
    'scanner': 'स्कैनर',
    'products': 'प्रोडक्ट्स',
    'maps': 'मैप्स',
    'profile': 'प्रोफाइल',
    'scan_product': 'स्कैन करें',
    'eco_products': 'इको प्रोडक्ट्स',
    'eco_store': 'इको स्टोर',
    'connect_impact': 'खनन के प्रभावों को अपनी पसंद से जोड़ें!',
  };

  String translate(String key) {
    if (_isHindi) {
      return _hi[key] ?? key;
    }
    return _en[key] ?? key;
  }
}

// Extension to make translation easier
extension Translater on BuildContext {
  String tr(String key) {
    // We cannot use Provider.of directly inside an extension method beautifully without passing generic type.
    // So we'll provide access via another way in widgets.
    return key;
  }
}
