import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      // Need a context to know system brightness reliably, but for MVP:
      return false; // Default to light or check elsewhere
    }
    return _themeMode == ThemeMode.dark;
  }

  ThemeProvider() {
    _loadTheme();
  }

  void toggleTheme() async {
    if (_themeMode == ThemeMode.light || _themeMode == ThemeMode.system) {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', _themeMode.toString());
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString('theme_mode');
      if (savedTheme == ThemeMode.dark.toString()) {
        _themeMode = ThemeMode.dark;
      } else if (savedTheme == ThemeMode.light.toString()) {
        _themeMode = ThemeMode.light;
      }
      notifyListeners();
    } catch (e) {
      // SharedPreferences might fail to init if testing, just ignore
    }
  }
}
