import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Settings Provider - Central state management for app settings
/// Handles theme, language, currency, and notification preferences
class SettingsProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _localeKey = 'locale';
  static const String _currencyKey = 'currency';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _biometricKey = 'biometric_enabled';
  static const String _dailyReminderKey = 'daily_reminder';
  static const String _reminderTimeKey = 'reminder_time';
  static const String _dateFormatKey = 'date_format';

  // State variables
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('id', 'ID');
  CurrencyModel _currency = CurrencyModel.defaultCurrency;
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;
  bool _dailyReminder = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);
  String _dateFormat = 'dd/MM/yyyy';
  bool _isLoading = false;
  bool _isInitialized = false;

  // Getters
  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  CurrencyModel get currency => _currency;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get biometricEnabled => _biometricEnabled;
  bool get dailyReminder => _dailyReminder;
  TimeOfDay get reminderTime => _reminderTime;
  String get dateFormat => _dateFormat;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  String get currencySymbol => _currency.symbol;
  String get currencyCode => _currency.code;

  /// Initialize settings from local storage
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load theme
      final themeString = prefs.getString(_themeKey);
      if (themeString != null) {
        _themeMode = ThemeMode.values.firstWhere(
          (e) => e.name == themeString,
          orElse: () => ThemeMode.system,
        );
      }

      // Load locale
      final localeString = prefs.getString(_localeKey);
      if (localeString != null) {
        final parts = localeString.split('_');
        _locale = Locale(parts[0], parts.length > 1 ? parts[1] : '');
      }

      // Load currency
      final currencyCode = prefs.getString(_currencyKey);
      if (currencyCode != null) {
        _currency = CurrencyModel.getByCode(currencyCode) ?? CurrencyModel.defaultCurrency;
      }

      // Load other settings
      _notificationsEnabled = prefs.getBool(_notificationsKey) ?? true;
      _biometricEnabled = prefs.getBool(_biometricKey) ?? false;
      _dailyReminder = prefs.getBool(_dailyReminderKey) ?? true;

      final reminderTimeString = prefs.getString(_reminderTimeKey);
      if (reminderTimeString != null) {
        final parts = reminderTimeString.split(':');
        _reminderTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 20,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }

      _dateFormat = prefs.getString(_dateFormatKey) ?? 'dd/MM/yyyy';
      
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing settings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, mode.name);
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }

  /// Toggle dark mode
  Future<void> toggleDarkMode() async {
    if (_themeMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }

  /// Set locale
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    
    _locale = locale;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final localeString = locale.countryCode != null 
          ? '${locale.languageCode}_${locale.countryCode}'
          : locale.languageCode;
      await prefs.setString(_localeKey, localeString);
    } catch (e) {
      debugPrint('Error saving locale: $e');
    }
  }

  /// Set currency
  Future<void> setCurrency(CurrencyModel currency) async {
    if (_currency == currency) return;
    
    _currency = currency;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currencyKey, currency.code);
    } catch (e) {
      debugPrint('Error saving currency: $e');
    }
  }

  /// Set notifications enabled
  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationsKey, enabled);
    } catch (e) {
      debugPrint('Error saving notifications setting: $e');
    }
  }

  /// Set biometric enabled
  Future<void> setBiometricEnabled(bool enabled) async {
    _biometricEnabled = enabled;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_biometricKey, enabled);
    } catch (e) {
      debugPrint('Error saving biometric setting: $e');
    }
  }

  /// Set daily reminder
  Future<void> setDailyReminder(bool enabled) async {
    _dailyReminder = enabled;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_dailyReminderKey, enabled);
    } catch (e) {
      debugPrint('Error saving daily reminder setting: $e');
    }
  }

  /// Set reminder time
  Future<void> setReminderTime(TimeOfDay time) async {
    _reminderTime = time;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_reminderTimeKey, '${time.hour}:${time.minute}');
    } catch (e) {
      debugPrint('Error saving reminder time: $e');
    }
  }

  /// Set date format
  Future<void> setDateFormat(String format) async {
    _dateFormat = format;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_dateFormatKey, format);
    } catch (e) {
      debugPrint('Error saving date format: $e');
    }
  }

  /// Export settings as JSON
  Map<String, dynamic> toJson() {
    return {
      'theme_mode': _themeMode.name,
      'locale': '${_locale.languageCode}_${_locale.countryCode ?? ''}',
      'currency': _currency.toJson(),
      'notifications_enabled': _notificationsEnabled,
      'biometric_enabled': _biometricEnabled,
      'daily_reminder': _dailyReminder,
      'reminder_time': '${_reminderTime.hour}:${_reminderTime.minute}',
      'date_format': _dateFormat,
    };
  }

  /// Import settings from JSON
  Future<void> fromJson(Map<String, dynamic> json) async {
    if (json['theme_mode'] != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (e) => e.name == json['theme_mode'],
        orElse: () => ThemeMode.system,
      );
    }

    if (json['locale'] != null) {
      final parts = json['locale'].toString().split('_');
      _locale = Locale(parts[0], parts.length > 1 ? parts[1] : '');
    }

    if (json['currency'] != null) {
      _currency = CurrencyModel.fromJson(json['currency']);
    }

    _notificationsEnabled = json['notifications_enabled'] ?? true;
    _biometricEnabled = json['biometric_enabled'] ?? false;
    _dailyReminder = json['daily_reminder'] ?? true;

    if (json['reminder_time'] != null) {
      final parts = json['reminder_time'].toString().split(':');
      _reminderTime = TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 20,
        minute: int.tryParse(parts[1]) ?? 0,
      );
    }

    _dateFormat = json['date_format'] ?? 'dd/MM/yyyy';
    
    notifyListeners();
  }

  /// Reset all settings to defaults
  Future<void> resetToDefaults() async {
    _themeMode = ThemeMode.system;
    _locale = const Locale('id', 'ID');
    _currency = CurrencyModel.defaultCurrency;
    _notificationsEnabled = true;
    _biometricEnabled = false;
    _dailyReminder = true;
    _reminderTime = const TimeOfDay(hour: 20, minute: 0);
    _dateFormat = 'dd/MM/yyyy';
    
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      debugPrint('Error resetting settings: $e');
    }
  }
}

/// Currency model
class CurrencyModel {
  final String code;
  final String name;
  final String symbol;
  final String locale;
  final int decimalDigits;
  final String thousandSeparator;
  final String decimalSeparator;

  const CurrencyModel({
    required this.code,
    required this.name,
    required this.symbol,
    required this.locale,
    this.decimalDigits = 0,
    this.thousandSeparator = '.',
    this.decimalSeparator = ',',
  });

  static const CurrencyModel defaultCurrency = CurrencyModel(
    code: 'IDR',
    name: 'Indonesian Rupiah',
    symbol: 'Rp',
    locale: 'id_ID',
    decimalDigits: 0,
    thousandSeparator: '.',
    decimalSeparator: ',',
  );

  static const List<CurrencyModel> availableCurrencies = [
    CurrencyModel(
      code: 'IDR',
      name: 'Indonesian Rupiah',
      symbol: 'Rp',
      locale: 'id_ID',
      decimalDigits: 0,
      thousandSeparator: '.',
      decimalSeparator: ',',
    ),
    CurrencyModel(
      code: 'USD',
      name: 'US Dollar',
      symbol: '\$',
      locale: 'en_US',
      decimalDigits: 2,
      thousandSeparator: ',',
      decimalSeparator: '.',
    ),
    CurrencyModel(
      code: 'EUR',
      name: 'Euro',
      symbol: '€',
      locale: 'de_DE',
      decimalDigits: 2,
      thousandSeparator: '.',
      decimalSeparator: ',',
    ),
    CurrencyModel(
      code: 'GBP',
      name: 'British Pound',
      symbol: '£',
      locale: 'en_GB',
      decimalDigits: 2,
      thousandSeparator: ',',
      decimalSeparator: '.',
    ),
    CurrencyModel(
      code: 'JPY',
      name: 'Japanese Yen',
      symbol: '¥',
      locale: 'ja_JP',
      decimalDigits: 0,
      thousandSeparator: ',',
      decimalSeparator: '.',
    ),
    CurrencyModel(
      code: 'KRW',
      name: 'South Korean Won',
      symbol: '₩',
      locale: 'ko_KR',
      decimalDigits: 0,
      thousandSeparator: ',',
      decimalSeparator: '.',
    ),
    CurrencyModel(
      code: 'CNY',
      name: 'Chinese Yuan',
      symbol: '¥',
      locale: 'zh_CN',
      decimalDigits: 2,
      thousandSeparator: ',',
      decimalSeparator: '.',
    ),
    CurrencyModel(
      code: 'MYR',
      name: 'Malaysian Ringgit',
      symbol: 'RM',
      locale: 'ms_MY',
      decimalDigits: 2,
      thousandSeparator: ',',
      decimalSeparator: '.',
    ),
    CurrencyModel(
      code: 'SGD',
      name: 'Singapore Dollar',
      symbol: 'S\$',
      locale: 'en_SG',
      decimalDigits: 2,
      thousandSeparator: ',',
      decimalSeparator: '.',
    ),
    CurrencyModel(
      code: 'AUD',
      name: 'Australian Dollar',
      symbol: 'A\$',
      locale: 'en_AU',
      decimalDigits: 2,
      thousandSeparator: ',',
      decimalSeparator: '.',
    ),
    CurrencyModel(
      code: 'THB',
      name: 'Thai Baht',
      symbol: '฿',
      locale: 'th_TH',
      decimalDigits: 2,
      thousandSeparator: ',',
      decimalSeparator: '.',
    ),
    CurrencyModel(
      code: 'SAR',
      name: 'Saudi Riyal',
      symbol: 'ر.س',
      locale: 'ar_SA',
      decimalDigits: 2,
      thousandSeparator: ',',
      decimalSeparator: '.',
    ),
  ];

  static CurrencyModel? getByCode(String code) {
    try {
      return availableCurrencies.firstWhere((c) => c.code == code);
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'symbol': symbol,
      'locale': locale,
      'decimal_digits': decimalDigits,
      'thousand_separator': thousandSeparator,
      'decimal_separator': decimalSeparator,
    };
  }

  factory CurrencyModel.fromJson(Map<String, dynamic> json) {
    return CurrencyModel(
      code: json['code'] ?? 'IDR',
      name: json['name'] ?? 'Indonesian Rupiah',
      symbol: json['symbol'] ?? 'Rp',
      locale: json['locale'] ?? 'id_ID',
      decimalDigits: json['decimal_digits'] ?? 0,
      thousandSeparator: json['thousand_separator'] ?? '.',
      decimalSeparator: json['decimal_separator'] ?? ',',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CurrencyModel && other.code == code;
  }

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => '$name ($code)';
}

/// Supported locales
class AppLocales {
  static const List<Locale> supportedLocales = [
    Locale('id', 'ID'),
    Locale('en', 'US'),
    Locale('en', 'GB'),
    Locale('ja', 'JP'),
    Locale('ko', 'KR'),
    Locale('zh', 'CN'),
    Locale('ms', 'MY'),
  ];

  static String getLanguageName(Locale locale) {
    switch ('${locale.languageCode}_${locale.countryCode ?? ''}') {
      case 'id_ID':
        return 'Bahasa Indonesia';
      case 'en_US':
        return 'English (US)';
      case 'en_GB':
        return 'English (UK)';
      case 'ja_JP':
        return '日本語';
      case 'ko_KR':
        return '한국어';
      case 'zh_CN':
        return '简体中文';
      case 'ms_MY':
        return 'Bahasa Melayu';
      default:
        return locale.languageCode;
    }
  }
}
