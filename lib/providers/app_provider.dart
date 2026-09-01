import 'package:flutter/material.dart';
import 'package:fintrack/services/storage_service.dart';
import 'package:fintrack/models/user_preferences.dart';

/// Application state provider that manages global app state,
/// theme preferences, and initialization across the FinTrack app.
///
/// This provider follows the singleton pattern to ensure
/// a single source of truth for app-wide state.
class AppProvider extends ChangeNotifier {
  static AppProvider? _instance;
  
  /// Singleton instance accessor
  static AppProvider get instance {
    _instance ??= AppProvider._internal();
    return _instance!;
  }

  AppProvider._internal();

  // Storage service reference
  final StorageService _storageService = StorageService.instance;

  // App state flags
  bool _isInitialized = false;
  bool _isLoading = true;
  String? _error;

  // User preferences
  UserPreferences? _userPreferences;

  // Theme state
  ThemeMode _themeMode = ThemeMode.system;
  String _currency = 'USD';
  String _language = 'en';
  String _dateFormat = 'MM/dd/yyyy';

  // App info
  String _appVersion = '1.0.0';
  bool _onboardingCompleted = false;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get error => _error;
  UserPreferences? get userPreferences => _userPreferences;
  ThemeMode get themeMode => _themeMode;
  String get currency => _currency;
  String get language => _language;
  String get dateFormat => _dateFormat;
  String get appVersion => _appVersion;
  bool get onboardingCompleted => _onboardingCompleted;

  /// Returns the display name for the current theme mode
  String get themeModeDisplayName {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System Default';
    }
  }

  /// Returns the actual theme mode based on system brightness
  ThemeMode get effectiveThemeMode {
    if (_themeMode != ThemeMode.system) {
      return _themeMode;
    }
    return ThemeMode.light;
  }

  /// Initializes the app provider by loading stored preferences
  /// and performing necessary setup tasks.
  Future<void> initialize() async {
    if (_isInitialized) return;

    _setLoading(true);
    _clearError();

    try {
      await _storageService.init();
      await _loadPreferences();
      _isInitialized = true;
    } catch (e) {
      _setError('Failed to initialize app: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Loads user preferences from persistent storage
  Future<void> _loadPreferences() async {
    try {
      _userPreferences = await _storageService.getUserPreferences();
      
      if (_userPreferences != null) {
        _themeMode = _themeModeFromString(_userPreferences!.themeMode);
        _currency = _userPreferences!.currency;
        _language = _userPreferences!.language;
        _dateFormat = _userPreferences!.dateFormat;
        _onboardingCompleted = _userPreferences!.onboardingCompleted;
      }
    } catch (e) {
      debugPrint('Error loading preferences: $e');
      // Use defaults on error
    }
  }

  /// Saves current preferences to persistent storage
  Future<bool> _savePreferences() async {
    try {
      final prefs = UserPreferences(
        themeMode: _themeModeToString(_themeMode),
        currency: _currency,
        language: _language,
        dateFormat: _dateFormat,
        onboardingCompleted: _onboardingCompleted,
      );
      
      await _storageService.saveUserPreferences(prefs);
      _userPreferences = prefs;
      return true;
    } catch (e) {
      debugPrint('Error saving preferences: $e');
      return false;
    }
  }

  /// Sets the app theme mode
  Future<bool> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return true;

    _themeMode = mode;
    notifyListeners();

    final success = await _savePreferences();
    if (!success) {
      // Revert on failure
      _themeMode = _themeMode == mode 
          ? (mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light)
          : _themeMode;
      notifyListeners();
    }
    return success;
  }

  /// Toggles between light and dark theme
  Future<bool> toggleTheme() async {
    final newMode = _themeMode == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
    return setThemeMode(newMode);
  }

  /// Sets the display currency
  Future<bool> setCurrency(String currency) async {
    if (_currency == currency) return true;

    _currency = currency;
    notifyListeners();

    final success = await _savePreferences();
    if (!success) {
      _currency = _currency == currency ? 'USD' : _currency;
      notifyListeners();
    }
    return success;
  }

  /// Sets the app language/locale
  Future<bool> setLanguage(String language) async {
    if (_language == language) return true;

    _language = language;
    notifyListeners();

    final success = await _savePreferences();
    if (!success) {
      _language = _language == language ? 'en' : _language;
      notifyListeners();
    }
    return success;
  }

  /// Sets the date format for display
  Future<bool> setDateFormat(String format) async {
    if (_dateFormat == format) return true;

    _dateFormat = format;
    notifyListeners();

    final success = await _savePreferences();
    if (!success) {
      _dateFormat = _dateFormat == format ? 'MM/dd/yyyy' : _dateFormat;
      notifyListeners();
    }
    return success;
  }

  /// Marks onboarding as completed
  Future<bool> completeOnboarding() async {
    if (_onboardingCompleted) return true;

    _onboardingCompleted = true;
    notifyListeners();

    return await _savePreferences();
  }

  /// Resets onboarding status (for testing/reset)
  Future<bool> resetOnboarding() async {
    _onboardingCompleted = false;
    notifyListeners();

    return await _savePreferences();
  }

  /// Resets all preferences to default values
  Future<bool> resetPreferences() async {
    _themeMode = ThemeMode.system;
    _currency = 'USD';
    _language = 'en';
    _dateFormat = 'MM/dd/yyyy';
    _onboardingCompleted = false;
    
    notifyListeners();

    final success = await _savePreferences();
    if (!success) {
      await _loadPreferences();
    }
    return success;
  }

  /// Clears all app data including preferences
  Future<bool> clearAllData() async {
    _setLoading(true);
    _clearError();

    try {
      await _storageService.clearAll();
      await resetPreferences();
      return true;
    } catch (e) {
      _setError('Failed to clear data: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Updates app version (called on app upgrade)
  Future<void> updateAppVersion(String version) async {
    _appVersion = version;
    notifyListeners();
  }

  /// Gets a map of all current settings
  Map<String, dynamic> getSettingsMap() {
    return {
      'themeMode': _themeModeToString(_themeMode),
      'themeModeDisplayName': themeModeDisplayName,
      'currency': _currency,
      'language': _language,
      'dateFormat': _dateFormat,
      'appVersion': _appVersion,
      'onboardingCompleted': _onboardingCompleted,
    };
  }

  // Private helper methods
  
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  ThemeMode _themeModeFromString(String value) {
    switch (value.toLowerCase()) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}

/// Extension to provide currency formatting utilities
extension CurrencyUtils on AppProvider {
  /// Returns currency symbol for the current currency
  String get currencySymbol {
    return _getCurrencySymbol(_currency);
  }

  /// Formats amount with currency symbol
  String formatAmount(double amount) {
    return '$currencySymbol${amount.toStringAsFixed(2)}';
  }

  String _getCurrencySymbol(String currency) {
    const symbols = {
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
      'JPY': '¥',
      'CAD': 'CA\$',
      'AUD': 'A\$',
      'CHF': 'CHF',
      'CNY': '¥',
      'INR': '₹',
      'KRW': '₩',
      'BRL': 'R\$',
      'MXN': 'MX\$',
    };
    return symbols[currency] ?? '\$';
  }
}

/// Extension to provide date formatting utilities
extension DateFormatUtils on AppProvider {
  /// Formats a DateTime according to user's date format preference
  String formatDate(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    switch (_dateFormat) {
      case 'dd/MM/yyyy':
        return '$day/$month/$year';
      case 'yyyy-MM-dd':
        return '$year-$month-$day';
      case 'MM-dd-yyyy':
        return '$month-$day-$year';
      case 'dd-MM-yyyy':
        return '$day-$month-$year';
      default: // MM/dd/yyyy
        return '$month/$day/$year';
    }
  }

  /// Formats a DateTime with time
  String formatDateTime(DateTime dateTime) {
    final date = formatDate(dateTime);
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$date $hour:$minute';
  }
}
