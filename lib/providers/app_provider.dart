import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App-wide state management provider for FinTrack
/// Handles theme, authentication state, app settings, and global configurations
class AppProvider extends ChangeNotifier {
  // Singleton instance
  static AppProvider? _instance;
  
  AppProvider._internal();
  
  factory AppProvider() {
    _instance ??= AppProvider._internal();
    return _instance!;
  }
  
  // Private state variables
  ThemeMode _themeMode = ThemeMode.system;
  bool _isInitialized = false;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentUserId;
  String? _currentUserEmail;
  Locale _locale = const Locale('en', 'US');
  bool _showOnboarding = true;
  String _currency = 'USD';
  String _dateFormat = 'MM/dd/yyyy';
  bool _biometricEnabled = false;
  Map<String, dynamic> _appSettings = {};
  
  // Getters
  ThemeMode get themeMode => _themeMode;
  bool get isInitialized => _isInitialized;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get currentUserId => _currentUserId;
  String? get currentUserEmail => _currentUserEmail;
  Locale get locale => _locale;
  bool get showOnboarding => _showOnboarding;
  String get currency => _currency;
  String get dateFormat => _dateFormat;
  bool get biometricEnabled => _biometricEnabled;
  Map<String, dynamic> get appSettings => _appSettings;
  
  // Computed getters
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isLightMode => _themeMode == ThemeMode.light;
  bool get isSystemMode => _themeMode == ThemeMode.system;
  
  /// Initialize the app provider with stored preferences
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      setLoading(true);
      clearError();
      
      final prefs = await SharedPreferences.getInstance();
      
      // Load theme preference
      final themeModeIndex = prefs.getInt('themeMode') ?? 0;
      _themeMode = ThemeMode.values[themeModeIndex];
      
      // Load locale preference
      final languageCode = prefs.getString('languageCode') ?? 'en';
      final countryCode = prefs.getString('countryCode') ?? 'US';
      _locale = Locale(languageCode, countryCode);
      
      // Load onboarding status
      _showOnboarding = prefs.getBool('showOnboarding') ?? true;
      
      // Load currency preference
      _currency = prefs.getString('currency') ?? 'USD';
      
      // Load date format preference
      _dateFormat = prefs.getString('dateFormat') ?? 'MM/dd/yyyy';
      
      // Load biometric preference
      _biometricEnabled = prefs.getBool('biometricEnabled') ?? false;
      
      // Load app settings
      final settingsString = prefs.getString('appSettings');
      if (settingsString != null) {
        // Parse settings if needed
      }
      
      // Check authentication state
      _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
      _currentUserId = prefs.getString('currentUserId');
      _currentUserEmail = prefs.getString('currentUserEmail');
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      setError('Failed to initialize app: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }
  
  /// Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('themeMode', mode.index);
      
      // Update system UI overlay style
      if (mode == ThemeMode.dark) {
        SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarColor: Color(0xFF121212),
            systemNavigationBarIconBrightness: Brightness.light,
          ),
        );
      } else {
        SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            systemNavigationBarColor: Colors.white,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
        );
      }
    } catch (e) {
      // Silently fail preference save
    }
  }
  
  /// Toggle between light and dark theme
  Future<void> toggleTheme() async {
    final newMode = _themeMode == ThemeMode.dark 
        ? ThemeMode.light 
        : ThemeMode.dark;
    await setThemeMode(newMode);
  }
  
  /// Set locale
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    
    _locale = locale;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('languageCode', locale.languageCode);
      if (locale.countryCode != null) {
        await prefs.setString('countryCode', locale.countryCode!);
      }
    } catch (e) {
      // Silently fail preference save
    }
  }
  
  /// Set currency
  Future<void> setCurrency(String currency) async {
    if (_currency == currency) return;
    
    _currency = currency;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currency', currency);
    } catch (e) {
      // Silently fail preference save
    }
  }
  
  /// Set date format
  Future<void> setDateFormat(String format) async {
    if (_dateFormat == format) return;
    
    _dateFormat = format;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('dateFormat', format);
    } catch (e) {
      // Silently fail preference save
    }
  }
  
  /// Enable or disable biometric authentication
  Future<void> setBiometricEnabled(bool enabled) async {
    if (_biometricEnabled == enabled) return;
    
    _biometricEnabled = enabled;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('biometricEnabled', enabled);
    } catch (e) {
      // Silently fail preference save
    }
  }
  
  /// Set onboarding completed
  Future<void> setOnboardingCompleted() async {
    if (!_showOnboarding) return;
    
    _showOnboarding = false;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('showOnboarding', false);
    } catch (e) {
      // Silently fail preference save
    }
  }
  
  /// Set loading state
  void setLoading(bool loading) {
    if (_isLoading == loading) return;
    _isLoading = loading;
    notifyListeners();
  }
  
  /// Set error message
  void setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }
  
  /// Clear error message
  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }
  
  /// Set authentication state
  Future<void> setAuthenticated({
    required bool authenticated,
    String? userId,
    String? email,
  }) async {
    _isAuthenticated = authenticated;
    _currentUserId = userId;
    _currentUserEmail = email;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAuthenticated', authenticated);
      if (userId != null) {
        await prefs.setString('currentUserId', userId);
      }
      if (email != null) {
        await prefs.setString('currentUserEmail', email);
      }
    } catch (e) {
      // Silently fail preference save
    }
  }
  
  /// Login user
  Future<bool> login({
    required String userId,
    required String email,
  }) async {
    try {
      setLoading(true);
      clearError();
      
      // Simulate network delay for authentication
      await Future.delayed(const Duration(milliseconds: 500));
      
      await setAuthenticated(
        authenticated: true,
        userId: userId,
        email: email,
      );
      
      return true;
    } catch (e) {
      setError('Login failed: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }
  
  /// Logout user
  Future<void> logout() async {
    try {
      setLoading(true);
      clearError();
      
      await setAuthenticated(
        authenticated: false,
        userId: null,
        email: null,
      );
      
      // Clear sensitive data
      _appSettings.clear();
      
    } catch (e) {
      setError('Logout failed: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }
  
  /// Update app settings
  Future<void> updateAppSettings(Map<String, dynamic> settings) async {
    _appSettings = {..._appSettings, ...settings};
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('appSettings', _appSettings.toString());
    } catch (e) {
      // Silently fail preference save
    }
  }
  
  /// Reset app to default state
  Future<void> resetApp() async {
    try {
      setLoading(true);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      _themeMode = ThemeMode.system;
      _locale = const Locale('en', 'US');
      _showOnboarding = true;
      _currency = 'USD';
      _dateFormat = 'MM/dd/yyyy';
      _biometricEnabled = false;
      _appSettings.clear();
      _isAuthenticated = false;
      _currentUserId = null;
      _currentUserEmail = null;
      
      notifyListeners();
    } catch (e) {
      setError('Failed to reset app: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }
  
  /// Get currency symbol based on current currency
  String get currencySymbol {
    switch (_currency) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'CNY':
        return '¥';
      case 'INR':
        return '₹';
      case 'AUD':
        return 'A\$';
      case 'CAD':
        return 'C\$';
      case 'CHF':
        return 'CHF';
      case 'KRW':
        return '₩';
      case 'MXN':
        return 'MX\$';
      case 'BRL':
        return 'R\$';
      default:
        return _currency;
    }
  }
  
  /// Format amount with currency
  String formatAmount(double amount) {
    final symbol = currencySymbol;
    final isNegative = amount < 0;
    final absAmount = amount.abs();
    
    String formatted;
    if (_currency == 'JPY' || _currency == 'KRW') {
      formatted = absAmount.toStringAsFixed(0);
    } else {
      formatted = absAmount.toStringAsFixed(2);
    }
    
    // Add thousand separators
    final parts = formatted.split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? '.${parts[1]}' : '';
    
    final buffer = StringBuffer();
    for (var i = 0; i < integerPart.length; i++) {
      if (i > 0 && (integerPart.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(integerPart[i]);
    }
    
    return isNegative 
        ? '-$symbol${buffer.toString()}$decimalPart'
        : '$symbol${buffer.toString()}$decimalPart';
  }
  
  /// Format date according to user preference
  String formatDate(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    
    switch (_dateFormat) {
      case 'MM/dd/yyyy':
        return '$month/$day/$year';
      case 'dd/MM/yyyy':
        return '$day/$month/$year';
      case 'yyyy-MM-dd':
        return '$year-$month-$day';
      case 'dd-MM-yyyy':
        return '$day-$month-$year';
      case 'MMM dd, yyyy':
        final months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        return '${months[date.month - 1]} $day, $year';
      default:
        return '$month/$day/$year';
    }
  }
}
