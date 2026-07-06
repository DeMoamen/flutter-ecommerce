import 'package:flutter/material.dart';

class AppProvider extends ChangeNotifier {
  // ===== Theme =====
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  // ===== Language =====
  Locale _locale = const Locale('ar');
  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';

  void toggleLanguage() {
    _locale =
        _locale.languageCode == 'ar' ? const Locale('en') : const Locale('ar');
    notifyListeners();
  }
}
