// ignore_for_file: unused_field, unnecessary_import
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  String _languageCode = 'id';
  String _currency = 'IDR';

  ThemeMode get themeMode => _themeMode;
  String get languageCode => _languageCode;
  String get currency => _currency;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  SettingsProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final themeStr = prefs.getString('theme_mode') ?? 'system';
    if (themeStr == 'dark') {
      _themeMode = ThemeMode.dark;
    } else if (themeStr == 'light') {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.system;
    }

    _languageCode = prefs.getString('language_code') ?? 'id';
    _currency = prefs.getString('currency') ?? 'IDR';
    notifyListeners();
  }

  Future<void> toggleDarkMode(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', isDark ? 'dark' : 'light');
  }

  Future<void> setLanguage(String langCode) async {
    _languageCode = langCode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', langCode);
  }

  Future<void> setCurrency(String newCurrency) async {
    _currency = newCurrency;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', newCurrency);
  }
}
