import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// AppProvider manages global application state including authentication,
/// theme settings, user preferences, and app-wide configurations.
class AppProvider extends ChangeNotifier {
  static const String _themeKey = 'app_theme_mode';
  static const String _onboardingKey = 'onboarding_completed';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';
  static const String _currencyKey = 'app_currency';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _biometricKey = 'biometric_enabled';
  static const String _lastSyncKey = 'last_sync_time';

  final FlutterSecureStorage _secureStorage;
  SharedPreferences? _prefs;

  bool _isInitialized = false;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  ThemeMode _themeMode = ThemeMode.system;
  bool _onboardingCompleted = false;
  String? _userId;
  String? _userEmail;
  String? _userName;
  String _currency = 'USD';
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;
  DateTime? _lastSyncTime;
  String? _errorMessage;
  bool _isOffline = false;

  AppProvider({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage(
          aOptions: AndroidOptions(
            encryptedSharedPreferences: true,
          ),
          iOptions: IOSOptions(
            accessibility: KeychainAccessibility.first_unlock,
          ),
        );

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  ThemeMode get themeMode => _themeMode;
  bool get onboardingCompleted => _onboardingCompleted;
  String? get userId => _userId;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  String get currency => _currency;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get biometricEnabled => _biometricEnabled;
  DateTime? get lastSyncTime => _lastSyncTime;
  String? get errorMessage => _errorMessage;
  bool get isOffline => _isOffline;

  String get displayName => _userName ?? _userEmail?.split('@').first ?? 'User';

  String get userInitials {
    if (_userName != null && _userName!.isNotEmpty) {
      final parts = _userName!.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return _userName![0].toUpperCase();
    }
    if (_userEmail != null && _userEmail!.isNotEmpty) {
      return _userEmail![0].toUpperCase();
    }
    return 'U';
  }

  /// Initializes the app provider by loading stored preferences and secure data.
  Future<void> initialize() async {
    if (_isInitialized) return;

    _setLoading(true);
    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadSecureData();
      await _loadPreferences();
      _isInitialized = true;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to initialize app: ${e.toString()}';
      debugPrint('AppProvider initialization error: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadSecureData() async {
    try {
      _userId = await _secureStorage.read(key: _userIdKey);
      _userEmail = await _secureStorage.read(key: _userEmailKey);
      _userName = await _secureStorage.read(key: _userNameKey);

      final lastSyncString = await _secureStorage.read(key: _lastSyncKey);
      if (lastSyncString != null) {
        _lastSyncTime = DateTime.tryParse(lastSyncString);
      }

      _isAuthenticated = _userId != null && _userEmail != null;
    } catch (e) {
      debugPrint('Error loading secure data: $e');
    }
  }

  Future<void> _loadPreferences() async {
    if (_prefs == null) return;

    try {
      final themeModeIndex = _prefs!.getInt(_themeKey) ?? 0;
      _themeMode = ThemeMode.values[themeModeIndex.clamp(0, ThemeMode.values.length - 1)];

      _onboardingCompleted = _prefs!.getBool(_onboardingKey) ?? false;
      _currency = _prefs!.getString(_currencyKey) ?? 'USD';
      _notificationsEnabled = _prefs!.getBool(_notificationsKey) ?? true;
      _biometricEnabled = _prefs!.getBool(_biometricKey) ?? false;
    } catch (e) {
      debugPrint('Error loading preferences: $e');
    }
  }

  /// Sets loading state and notifies listeners.
  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  /// Clears any error message.
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Sets the authentication state after successful login.
  Future<void> setAuthenticated({
    required String userId,
    required String email,
    String? name,
  }) async {
    _setLoading(true);
    try {
      await _secureStorage.write(key: _userIdKey, value: userId);
      await _secureStorage.write(key: _userEmailKey, value: email);
      
      if (name != null) {
        await _secureStorage.write(key: _userNameKey, value: name);
        _userName = name;
      } else {
        await _secureStorage.delete(key: _userNameKey);
        _userName = null;
      }

      _userId = userId;
      _userEmail = email;
      _isAuthenticated = true;
      _errorMessage = null;

      await _updateLastSyncTime();
    } catch (e) {
      _errorMessage = 'Failed to save authentication data: ${e.toString()}';
      debugPrint('Set authenticated error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Logs out the current user and clears all authentication data.
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _secureStorage.delete(key: _userIdKey);
      await _secureStorage.delete(key: _userEmailKey);
      await _secureStorage.delete(key: _userNameKey);
      await _secureStorage.delete(key: _lastSyncKey);

      _userId = null;
      _userEmail = null;
      _userName = null;
      _isAuthenticated = false;
      _lastSyncTime = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to logout: ${e.toString()}';
      debugPrint('Logout error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Updates the user's profile information.
  Future<void> updateProfile({String? name, String? email}) async {
    if (!_isAuthenticated) return;

    _setLoading(true);
    try {
      if (name != null) {
        await _secureStorage.write(key: _userNameKey, value: name);
        _userName = name;
      }
      if (email != null) {
        await _secureStorage.write(key: _userEmailKey, value: email);
        _userEmail = email;
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to update profile: ${e.toString()}';
      debugPrint('Update profile error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Sets the app theme mode.
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();

    try {
      await _prefs?.setInt(_themeKey, mode.index);
    } catch (e) {
      debugPrint('Error saving theme mode: $e');
    }
  }

  /// Toggles between light and dark theme.
  Future<void> toggleTheme() async {
    final newMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : _themeMode == ThemeMode.dark
            ? ThemeMode.system
            : ThemeMode.light;
    await setThemeMode(newMode);
  }

  /// Marks the onboarding process as completed.
  Future<void> completeOnboarding() async {
    if (_onboardingCompleted) return;

    _onboardingCompleted = true;
    notifyListeners();

    try {
      await _prefs?.setBool(_onboardingKey, true);
    } catch (e) {
      debugPrint('Error saving onboarding status: $e');
    }
  }

  /// Sets the app currency.
  Future<void> setCurrency(String currencyCode) async {
    if (_currency == currencyCode) return;

    _currency = currencyCode;
    notifyListeners();

    try {
      await _prefs?.setString(_currencyKey, currencyCode);
    } catch (e) {
      debugPrint('Error saving currency: $e');
    }
  }

  /// Sets the notifications enabled state.
  Future<void> setNotificationsEnabled(bool enabled) async {
    if (_notificationsEnabled == enabled) return;

    _notificationsEnabled = enabled;
    notifyListeners();

    try {
      await _prefs?.setBool(_notificationsKey, enabled);
    } catch (e) {
      debugPrint('Error saving notifications setting: $e');
    }
  }

  /// Sets the biometric authentication enabled state.
  Future<void> setBiometricEnabled(bool enabled) async {
    if (_biometricEnabled == enabled) return;

    _biometricEnabled = enabled;
    notifyListeners();

    try {
      await _prefs?.setBool(_biometricKey, enabled);
    } catch (e) {
      debugPrint('Error saving biometric setting: $e');
    }
  }

  /// Updates the last sync timestamp.
  Future<void> _updateLastSyncTime() async {
    _lastSyncTime = DateTime.now();
    try {
      await _secureStorage.write(
        key: _lastSyncKey,
        value: _lastSyncTime!.toIso8601String(),
      );
    } catch (e) {
      debugPrint('Error saving last sync time: $e');
    }
  }

  /// Triggers a manual sync and updates the last sync time.
  Future<void> triggerSync() async {
    _setLoading(true);
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      await _updateLastSyncTime();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Sync failed: ${e.toString()}';
      debugPrint('Sync error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Sets the offline mode state.
  void setOfflineMode(bool offline) {
    if (_isOffline == offline) return;

    _isOffline = offline;
    notifyListeners();
  }

  /// Resets the app to default state (for testing or account deletion).
  Future<void> resetApp() async {
    _setLoading(true);
    try {
      await _secureStorage.deleteAll();
      await _prefs?.clear();

      _isAuthenticated = false;
      _userId = null;
      _userEmail = null;
      _userName = null;
      _themeMode = ThemeMode.system;
      _onboardingCompleted = false;
      _currency = 'USD';
      _notificationsEnabled = true;
      _biometricEnabled = false;
      _lastSyncTime = null;
      _errorMessage = null;
      _isOffline = false;

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to reset app: ${e.toString()}';
      debugPrint('Reset app error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Formats currency amount based on current app currency setting.
  String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      symbol: _getCurrencySymbol(_currency),
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  String _getCurrencySymbol(String code) {
    switch (code) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'INR':
        return '₹';
      case 'CNY':
        return '¥';
      case 'KRW':
        return '₩';
      case 'BRL':
        return 'R\$';
      case 'CAD':
        return 'C\$';
      case 'AUD':
        return 'A\$';
      default:
        return '\$$code ';
    }
  }

  @override
  void dispose() {
    _secureStorage;
    super.dispose();
  }
}

/// Supported currencies with their symbols and names.
class SupportedCurrency {
  final String code;
  final String symbol;
  final String name;

  const SupportedCurrency({
    required this.code,
    required this.symbol,
    required this.name,
  });

  static const List<SupportedCurrency> all = [
    SupportedCurrency(code: 'USD', symbol: '\$', name: 'US Dollar'),
    SupportedCurrency(code: 'EUR', symbol: '€', name: 'Euro'),
    SupportedCurrency(code: 'GBP', symbol: '£', name: 'British Pound'),
    SupportedCurrency(code: 'JPY', symbol: '¥', name: 'Japanese Yen'),
    SupportedCurrency(code: 'INR', symbol: '₹', name: 'Indian Rupee'),
    SupportedCurrency(code: 'CNY', symbol: '¥', name: 'Chinese Yuan'),
    SupportedCurrency(code: 'KRW', symbol: '₩', name: 'South Korean Won'),
    SupportedCurrency(code: 'BRL', symbol: 'R\$', name: 'Brazilian Real'),
    SupportedCurrency(code: 'CAD', symbol: 'C\$', name: 'Canadian Dollar'),
    SupportedCurrency(code: 'AUD', symbol: 'A\$', name: 'Australian Dollar'),
  ];

  static SupportedCurrency? fromCode(String code) {
    try {
      return all.firstWhere((c) => c.code == code);
    } catch (_) {
      return null;
    }
  }
}
