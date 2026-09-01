import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fintrack/core/constants/app_constants.dart';
import 'package:fintrack/core/constants/storage_keys.dart';
import 'package:fintrack/core/services/storage_service.dart';
import 'package:fintrack/core/services/api_service.dart';
import 'package:fintrack/core/utils/app_utils.dart';
import 'package:fintrack/core/utils/validators.dart';
import 'package:fintrack/models/user_model.dart';
import 'package:fintrack/models/app_settings_model.dart';
import 'package:fintrack/models/notification_model.dart';

enum AppStatus {
  initial,
  loading,
  ready,
  error,
  maintenance,
  offline,
}

enum ThemePreference {
  system,
  light,
  dark,
}

class AppProvider extends ChangeNotifier {
  final StorageService _storageService;
  final ApiService _apiService;

  AppProvider({
    required StorageService storageService,
    required ApiService apiService,
  })  : _storageService = storageService,
        _apiService = apiService;

  AppStatus _status = AppStatus.initial;
  UserModel? _currentUser;
  ThemePreference _themePreference = ThemePreference.system;
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('en');
  bool _isInitialized = false;
  String? _errorMessage;
  List<NotificationModel> _notifications = [];
  int _unreadNotificationCount = 0;
  bool _isOnline = true;
  bool _biometricEnabled = false;
  String? _sessionToken;
  DateTime? _lastSyncTime;
  AppSettingsModel? _appSettings;

  // Getters
  AppStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  ThemePreference get themePreference => _themePreference;
  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  List<NotificationModel> get notifications => _notifications;
  int get unreadNotificationCount => _unreadNotificationCount;
  bool get isOnline => _isOnline;
  bool get biometricEnabled => _biometricEnabled;
  String? get sessionToken => _sessionToken;
  DateTime? get lastSyncTime => _lastSyncTime;
  AppSettingsModel? get appSettings => _appSettings;

  bool get isLoggedIn => _currentUser != null && _sessionToken != null;
  bool get hasError => _errorMessage != null;
  bool get isLoading => _status == AppStatus.loading;

  // Computed properties
  String get displayName => _currentUser?.displayName ?? 'Guest';
  String get email => _currentUser?.email ?? '';
  String get userId => _currentUser?.id ?? '';
  String get userInitials => _getUserInitials();

  String _getUserInitials() {
    if (_currentUser == null) return 'G';
    final name = _currentUser?.displayName ?? '';
    if (name.isEmpty) return 'G';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  // Initialization
  Future<void> initialize() async {
    if (_isInitialized) return;

    _setStatus(AppStatus.loading);
    _clearError();

    try {
      await _loadStoredData();
      await _loadUserPreferences();
      await _validateSession();
      await _loadNotifications();
      await _checkAppVersion();
      await _loadAppSettings();

      _setStatus(AppStatus.ready);
      _isInitialized = true;
    } catch (e, stackTrace) {
      debugPrint('App initialization error: $e');
      debugPrint('Stack trace: $stackTrace');
      _handleError('Failed to initialize app: ${AppUtils.formatError(e)}');
      _setStatus(AppStatus.error);
    }

    notifyListeners();
  }

  Future<void> _loadStoredData() async {
    try {
      final themeStr = await _storageService.getString(StorageKeys.themePreference);
      if (themeStr != null) {
        _themePreference = ThemePreference.values.firstWhere(
          (e) => e.name == themeStr,
          orElse: () => ThemePreference.system,
        );
        _themeMode = _mapThemePreference(_themePreference);
      }

      final localeStr = await _storageService.getString(StorageKeys.locale);
      if (localeStr != null) {
        _locale = Locale(localeStr);
      }

      _sessionToken = await _storageService.getString(StorageKeys.sessionToken);
      _biometricEnabled = await _storageService.getBool(StorageKeys.biometricEnabled) ?? false;

      final lastSyncStr = await _storageService.getString(StorageKeys.lastSyncTime);
      if (lastSyncStr != null) {
        _lastSyncTime = DateTime.tryParse(lastSyncStr);
      }
    } catch (e) {
      debugPrint('Error loading stored data: $e');
    }
  }

  Future<void> _loadUserPreferences() async {
    try {
      if (_sessionToken != null) {
        final userData = await _storageService.getJson(StorageKeys.currentUser);
        if (userData != null) {
          _currentUser = UserModel.fromJson(userData);
        }
      }
    } catch (e) {
      debugPrint('Error loading user preferences: $e');
    }
  }

  Future<void> _validateSession() async {
    if (_sessionToken == null || _currentUser == null) return;

    try {
      final isValid = await _apiService.validateSession(_sessionToken!);
      if (!isValid) {
        await logout(clearSession: true);
      }
    } catch (e) {
      debugPrint('Session validation error: $e');
    }
  }

  Future<void> _loadNotifications() async {
    if (_currentUser == null) return;

    try {
      final notificationData = await _storageService.getJsonList(StorageKeys.notifications);
      if (notificationData != null) {
        _notifications = notificationData
            .map((json) => NotificationModel.fromJson(json))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _unreadNotificationCount = _notifications.where((n) => !n.isRead).length;
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    }
  }

  Future<void> _checkAppVersion() async {
    try {
      final currentVersion = await _storageService.getString(StorageKeys.appVersion);
      if (currentVersion == null) {
        await _storageService.setString(StorageKeys.appVersion, AppConstants.appVersion);
      }
    } catch (e) {
      debugPrint('Error checking app version: $e');
    }
  }

  Future<void> _loadAppSettings() async {
    try {
      final settingsData = await _storageService.getJson(StorageKeys.appSettings);
      if (settingsData != null) {
        _appSettings = AppSettingsModel.fromJson(settingsData);
      } else {
        _appSettings = AppSettingsModel.defaultSettings();
      }
    } catch (e) {
      debugPrint('Error loading app settings: $e');
      _appSettings = AppSettingsModel.defaultSettings();
    }
  }

  // Theme Management
  Future<void> setThemePreference(ThemePreference preference) async {
    _themePreference = preference;
    _themeMode = _mapThemePreference(preference);

    try {
      await _storageService.setString(StorageKeys.themePreference, preference.name);
    } catch (e) {
      debugPrint('Error saving theme preference: $e');
    }

    notifyListeners();
  }

  ThemeMode _mapThemePreference(ThemePreference preference) {
    switch (preference) {
      case ThemePreference.light:
        return ThemeMode.light;
      case ThemePreference.dark:
        return ThemeMode.dark;
      case ThemePreference.system:
        return ThemeMode.system;
    }
  }

  Future<void> toggleTheme() async {
    final nextPreference = switch (_themePreference) {
      ThemePreference.system => ThemePreference.light,
      ThemePreference.light => ThemePreference.dark,
      ThemePreference.dark => ThemePreference.system,
    };
    await setThemePreference(nextPreference);
  }

  // Locale Management
  Future<void> setLocale(Locale locale) async {
    if (!AppConstants.supportedLocales.contains(locale)) {
      debugPrint('Unsupported locale: ${locale.languageCode}');
      return;
    }

    _locale = locale;

    try {
      await _storageService.setString(StorageKeys.locale, locale.languageCode);
    } catch (e) {
      debugPrint('Error saving locale: $e');
    }

    notifyListeners();
  }

  // Authentication
  Future<bool> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    _setStatus(AppStatus.loading);
    _clearError();

    try {
      // Validate input
      if (!Validators.isValidEmail(email)) {
        throw Exception('Invalid email address');
      }

      if (!Validators.isValidPassword(password)) {
        throw Exception('Password must be at least 8 characters');
      }

      // Make API call
      final response = await _apiService.login(
        email: email,
        password: password,
      );

      if (response.success && response.data != null) {
        final token = response.data['token'] as String;
        final userData = response.data['user'] as Map<String, dynamic>;

        _sessionToken = token;
        _currentUser = UserModel.fromJson(userData);

        // Store credentials
        await _storageService.setString(StorageKeys.sessionToken, token);
        await _storageService.setJson(StorageKeys.currentUser, userData);

        if (rememberMe) {
          await _storageService.setString(StorageKeys.rememberedEmail, email);
        }

        _setStatus(AppStatus.ready);
        await _loadNotifications();
        notifyListeners();
        return true;
      } else {
        throw Exception(response.message ?? 'Login failed');
      }
    } catch (e) {
      _handleError(AppUtils.formatError(e));
      _setStatus(AppStatus.ready);
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String confirmPassword,
    required String displayName,
    String? phoneNumber,
  }) async {
    _setStatus(AppStatus.loading);
    _clearError();

    try {
      // Validate input
      if (!Validators.isValidEmail(email)) {
        throw Exception('Invalid email address');
      }

      if (!Validators.isValidPassword(password)) {
        throw Exception('Password must be at least 8 characters with uppercase, lowercase, and number');
      }

      if (password != confirmPassword) {
        throw Exception('Passwords do not match');
      }

      if (!Validators.isValidDisplayName(displayName)) {
        throw Exception('Display name must be 2-50 characters');
      }

      // Make API call
      final response = await _apiService.register(
        email: email,
        password: password,
        displayName: displayName,
        phoneNumber: phoneNumber,
      );

      if (response.success && response.data != null) {
        final token = response.data['token'] as String;
        final userData = response.data['user'] as Map<String, dynamic>;

        _sessionToken = token;
        _currentUser = UserModel.fromJson(userData);

        // Store credentials
        await _storageService.setString(StorageKeys.sessionToken, token);
        await _storageService.setJson(StorageKeys.currentUser, userData);

        _setStatus(AppStatus.ready);
        notifyListeners();
        return true;
      } else {
        throw Exception(response.message ?? 'Registration failed');
      }
    } catch (e) {
      _handleError(AppUtils.formatError(e));
      _setStatus(AppStatus.ready);
      notifyListeners();
      return false;
    }
  }

  Future<bool> logout({bool clearSession = false}) async {
    _setStatus(AppStatus.loading);

    try {
      if (_sessionToken != null && !clearSession) {
        await _apiService.logout(_sessionToken!);
      }

      _currentUser = null;
      _sessionToken = null;
      _notifications = [];
      _unreadNotificationCount = 0;
      _lastSyncTime = null;

      await _storageService.remove(StorageKeys.sessionToken);
      await _storageService.remove(StorageKeys.currentUser);
      await _storageService.remove(StorageKeys.notifications);

      _setStatus(AppStatus.ready);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Logout error: $e');
      _setStatus(AppStatus.ready);
      notifyListeners();
      return false;
    }
  }

  Future<bool> refreshSession() async {
    if (_sessionToken == null) return false;

    try {
      final response = await _apiService.refreshToken(_sessionToken!);

      if (response.success && response.data != null) {
        final newToken = response.data['token'] as String;
        _sessionToken = newToken;
        await _storageService.setString(StorageKeys.sessionToken, newToken);
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Session refresh error: $e');
      return false;
    }
  }

  Future<bool> updateProfile({
    String? displayName,
    String? phoneNumber,
    String? avatarUrl,
  }) async {
    if (_currentUser == null) return false;

    _setStatus(AppStatus.loading);
    _clearError();

    try {
      final response = await _apiService.updateProfile(
        userId: _currentUser!.id,
        token: _sessionToken!,
        displayName: displayName,
        phoneNumber: phoneNumber,
        avatarUrl: avatarUrl,
      );

      if (response.success && response.data != null) {
        _currentUser = UserModel.fromJson(response.data);
        await _storageService.setJson(StorageKeys.currentUser, response.data);
        _setStatus(AppStatus.ready);
        notifyListeners();
        return true;
      } else {
        throw Exception(response.message ?? 'Profile update failed');
      }
    } catch (e) {
      _handleError(AppUtils.formatError(e));
      _setStatus(AppStatus.ready);
      notifyListeners();
      return false;
    }
  }

  // Notifications
  Future<void> markNotificationAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1) return;

    final notification = _notifications[index];
    if (notification.isRead) return;

    _notifications[index] = notification.copyWith(isRead: true);
    _unreadNotificationCount = _notifications.where((n) => !n.isRead).length;

    await _saveNotifications();
    notifyListeners();
  }

  Future<void> markAllNotificationsAsRead() async {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    _unreadNotificationCount = 0;

    await _saveNotifications();
    notifyListeners();
  }

  Future<void> deleteNotification(String notificationId) async {
    _notifications.removeWhere((n) => n.id == notificationId);
    _unreadNotificationCount = _notifications.where((n) => !n.isRead).length;

    await _saveNotifications();
    notifyListeners();
  }

  Future<void> clearAllNotifications() async {
    _notifications = [];
    _unreadNotificationCount = 0;

    await _saveNotifications();
    notifyListeners();
  }

  Future<void> _saveNotifications() async {
    try {
      final notificationJson = _notifications.map((n) => n.toJson()).toList();
      await _storageService.setJson(StorageKeys.notifications, notificationJson);
    } catch (e) {
      debugPrint('Error saving notifications: $e');
    }
  }

  Future<void> refreshNotifications() async {
    if (_currentUser == null) return;

    try {
      final response = await _apiService.getNotifications(
        userId: _currentUser!.id,
        token: _sessionToken!,
      );

      if (response.success && response.data != null) {
        final notificationList = response.data['notifications'] as List;
        _notifications = notificationList
            .map((json) => NotificationModel.fromJson(json))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _unreadNotificationCount = _notifications.where((n) => !n.isRead).length;
        await _saveNotifications();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error refreshing notifications: $e');
    }
  }

  // Biometric Authentication
  Future<void> setBiometricEnabled(bool enabled) async {
    _biometricEnabled = enabled;

    try {
      await _storageService.setBool(StorageKeys.biometricEnabled, enabled);
    } catch (e) {
      debugPrint('Error saving biometric setting: $e');
    }

    notifyListeners();
  }

  // Online/Offline Status
  void setOnlineStatus(bool isOnline) {
    if (_isOnline == isOnline) return;

    _isOnline = isOnline;
    _setStatus(isOnline ? AppStatus.ready : AppStatus.offline);
    notifyListeners();
  }

  // Sync Management
  Future<void> syncData() async {
    if (_currentUser == null || !_isOnline) return;

    try {
      await refreshNotifications();
      await _updateLastSyncTime();
    } catch (e) {
      debugPrint('Sync error: $e');
    }
  }

  Future<void> _updateLastSyncTime() async {
    _lastSyncTime = DateTime.now();
    await _storageService.setString(
      StorageKeys.lastSyncTime,
      _lastSyncTime!.toIso8601String(),
    );
    notifyListeners();
  }

  // App Settings
  Future<void> updateAppSettings(AppSettingsModel settings) async {
    _appSettings = settings;

    try {
      await _storageService.setJson(StorageKeys.appSettings, settings.toJson());
    } catch (e) {
      debugPrint('Error saving app settings: $e');
    }

    notifyListeners();
  }

  Future<void> resetAppSettings() async {
    _appSettings = AppSettingsModel.defaultSettings();

    try {
      await _storageService.setJson(StorageKeys.appSettings, _appSettings!.toJson());
    } catch (e) {
      debugPrint('Error resetting app settings: $e');
    }

    notifyListeners();
  }

  // Data Management
  Future<void> clearAllData() async {
    try {
      await _storageService.clearAll();
      _currentUser = null;
      _sessionToken = null;
      _notifications = [];
      _unreadNotificationCount = 0;
      _lastSyncTime = null;
      _themePreference = ThemePreference.system;
      _themeMode = ThemeMode.system;
      _locale = const Locale('en');
      _biometricEnabled = false;
      _appSettings = AppSettingsModel.defaultSettings();

      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing all data: $e');
    }
  }

  Future<void> exportData() async {
    if (_currentUser == null) return;

    try {
      final exportData = {
        'user': _currentUser!.toJson(),
        'notifications': _notifications.map((n) => n.toJson()).toList(),
        'settings': _appSettings?.toJson(),
        'exportedAt': DateTime.now().toIso8601String(),
        'appVersion': AppConstants.appVersion,
      };

      await _storageService.setJson(StorageKeys.exportedData, exportData);
    } catch (e) {
      debugPrint('Error exporting data: $e');
    }
  }

  // Error Handling
  void _setStatus(AppStatus status) {
    _status = status;
  }

  void _handleError(String message) {
    _errorMessage = message;
    _status = AppStatus.error;
    debugPrint('App Error: $message');
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _clearError();
    if (_status == AppStatus.error) {
      _status = AppStatus.ready;
    }
    notifyListeners();
  }

  // Utility Methods
  bool get shouldShowOnboarding {
    final hasCompletedOnboarding = _storageService.getBool(StorageKeys.onboardingCompleted);
    return hasCompletedOnboarding != true;
  }

  Future<void> completeOnboarding() async {
    await _storageService.setBool(StorageKeys.onboardingCompleted, true);
    notifyListeners();
  }

  String get formattedLastSync {
    if (_lastSyncTime == null) return 'Never';
    return AppUtils.formatDateTime(_lastSyncTime!);
  }

  Duration get timeSinceLastSync {
    if (_lastSyncTime == null) return Duration.zero;
    return DateTime.now().difference(_lastSyncTime!);
  }

  bool get needsSync {
    if (_lastSyncTime == null) return true;
    return timeSinceLastSync.inMinutes > AppConstants.syncIntervalMinutes;
  }

  // Currency and Locale Helpers
  String formatCurrency(double amount, {String? currencyCode}) {
    return AppUtils.formatCurrency(amount, currencyCode: currencyCode ?? _appSettings?.defaultCurrency ?? 'USD');
  }

  String formatPercentage(double value, {int decimals = 2}) {
    return AppUtils.formatPercentage(value, decimals: decimals);
  }

  String formatNumber(double value, {int decimals = 2}) {
    return AppUtils.formatNumber(value, decimals: decimals);
  }

  String formatDate(DateTime date) {
    return AppUtils.formatDate(date);
  }

  String formatDateTime(DateTime dateTime) {
    return AppUtils.formatDateTime(dateTime);
  }

  // Validation Helpers
  bool isValidEmail(String email) => Validators.isValidEmail(email);
  bool isValidPassword(String password) => Validators.isValidPassword(password);
  bool isValidDisplayName(String name) => Validators.isValidDisplayName(name);
  bool isValidAmount(String amount) => Validators.isValidAmount(amount);
  bool isValidAccountNumber(String accountNumber) => Validators.isValidAccountNumber(accountNumber);

  // Clipboard Helpers
  Future<void> copyToClipboard(String text, {String? label}) async {
    await Clipboard.setData(ClipboardData(text: text));
    // Could show a snackbar here via a notification system
    debugPrint('Copied to clipboard: $label');
  }

  Future<String?> pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text;
  }

  @override
  void dispose() {
    _storageService.dispose();
    _apiService.dispose();
    super.dispose();
  }
}

// App Provider Factory
class AppProviderFactory {
  static ChangeNotifierProvider<AppProvider> create({
    required StorageService storageService,
    required ApiService apiService,
  }) {
    return ChangeNotifierProvider<AppProvider>(
      create: (_) => AppProvider(
        storageService: storageService,
        apiService: apiService,
      ),
    );
  }
}
