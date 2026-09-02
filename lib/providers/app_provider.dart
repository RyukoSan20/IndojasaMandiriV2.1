import 'package:flutter/material.dart';

/// AppProvider - Central state management for FinTrack application
/// Handles authentication state, user settings, theme, notifications, and sync status
/// Uses ChangeNotifier pattern for reactive state updates across the app
class AppProvider extends ChangeNotifier {
  // ==================== Private State Variables ====================
  
  final StorageService _storageService;
  final AuthService _authService;
  final SyncService _syncService;
  
  UserModel? _currentUser;
  SettingsModel? _settings;
  ThemeMode _themeMode = ThemeMode.system;
  String _locale = 'id';
  String _currency = 'IDR';
  String _currencySymbol = 'Rp';
  bool _isAuthenticated = false;
  bool _isInitialized = false;
  bool _isLoading = false;
  bool _isSyncing = false;
  String? _error;
  DateTime? _lastSyncTime;
  int _pendingSyncCount = 0;
  
  // Notification state
  List<NotificationModel> _notifications = [];
  int _unreadNotificationCount = 0;
  
  // Network state
  bool _isOnline = true;
  bool _isWifi = false;
  
  // Security state
  bool _pinEnabled = false;
  bool _biometricEnabled = false;
  bool _biometricVerified = false;
  DateTime? _sessionExpiresAt;
  
  // App state
  bool _hasOnboarded = false;
  bool _maintenanceMode = false;
  String? _appVersion;
  bool _forceUpdateRequired = false;
  
  // Performance tracking
  Map<String, DateTime> _screenTimings = {};
  Map<String, int> _apiCallCount = {};
  
  // ==================== Constructor ====================
  
  AppProvider({
    required StorageService storageService,
    required AuthService authService,
    required SyncService syncService,
  })  : _storageService = storageService,
        _authService = authService,
        _syncService = syncService;
  
  // ==================== Getters ====================
  
  UserModel? get currentUser => _currentUser;
  SettingsModel? get settings => _settings;
  ThemeMode get themeMode => _themeMode;
  String get locale => _locale;
  String get currency => _currency;
  String get currencySymbol => _currencySymbol;
  bool get isAuthenticated => _isAuthenticated;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  String? get error => _error;
  DateTime? get lastSyncTime => _lastSyncTime;
  int get pendingSyncCount => _pendingSyncCount;
  
  List<NotificationModel> get notifications => _notifications;
  int get unreadNotificationCount => _unreadNotificationCount;
  
  bool get isOnline => _isOnline;
  bool get isWifi => _isWifi;
  
  bool get pinEnabled => _pinEnabled;
  bool get biometricEnabled => _biometricEnabled;
  bool get biometricVerified => _biometricVerified;
  DateTime? get sessionExpiresAt => _sessionExpiresAt;
  
  bool get hasOnboarded => _hasOnboarded;
  bool get maintenanceMode => _maintenanceMode;
  String? get appVersion => _appVersion;
  bool get forceUpdateRequired => _forceUpdateRequired;
  
  Map<String, DateTime> get screenTimings => _screenTimings;
  Map<String, int> get apiCallCount => _apiCallCount;
  
  // ==================== Computed Properties ====================
  
  bool get needsReauth {
    if (_sessionExpiresAt == null) return true;
    return DateTime.now().isAfter(_sessionExpiresAt!);
  }
  
  String get formattedLastSync {
    if (_lastSyncTime == null) return 'Never';
    final diff = DateTime.now().difference(_lastSyncTime!);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
  
  bool get hasPendingChanges => _pendingSyncCount > 0;
  
  // ==================== Initialization ====================
  
  /// Initialize the app provider
  /// Loads cached data, restores session, and prepares app state
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _setLoading(true);
    _clearError();
    
    try {
      // Load app settings from local storage
      await _loadAppSettings();
      
      // Check if user has completed onboarding
      _hasOnboarded = await _storageService.getBool(AppConstants.hasOnboardedKey) ?? false;
      
      // Load cached user data if available
      await _loadCachedUser();
      
      // Initialize sync service
      await _syncService.initialize();
      
      // Check for updates
      await _checkForUpdates();
      
      // Restore authentication session if valid
      await _restoreSession();
      
      // Load notifications
      await _loadNotifications();
      
      _isInitialized = true;
    } catch (e) {
      _setError('Failed to initialize app: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> _loadAppSettings() async {
    final settingsJson = await _storageService.getString(AppConstants.settingsKey);
    if (settingsJson != null) {
      _settings = SettingsModel.fromJson(settingsJson);
      _applySettings(_settings!);
    } else {
      _settings = SettingsModel.defaultSettings();
      await _saveSettings();
    }
  }
  
  Future<void> _loadCachedUser() async {
    final userJson = await _storageService.getString(AppConstants.currentUserKey);
    if (userJson != null) {
      _currentUser = UserModel.fromJson(userJson);
    }
  }
  
  Future<void> _restoreSession() async {
    final token = await _authService.getStoredToken();
    if (token != null && !_authService.isTokenExpired(token)) {
      _isAuthenticated = true;
      
      // Verify token with server
      final isValid = await _authService.verifyToken(token);
      if (isValid) {
        await _loadUserProfile();
      } else {
        await _authService.clearTokens();
        _isAuthenticated = false;
      }
    }
  }
  
  Future<void> _loadUserProfile() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        _currentUser = user;
        await _storageService.setString(
          AppConstants.currentUserKey,
          user.toJson(),
        );
        _applyUserSecuritySettings(user);
      }
    } catch (e) {
      // Use cached data on error
    }
  }
  
  void _applySettings(SettingsModel settings) {
    _themeMode = _parseThemeMode(settings.theme);
    _locale = settings.language;
    _currency = settings.currency;
    _currencySymbol = settings.currencySymbol;
    _pinEnabled = settings.pinEnabled;
    _biometricEnabled = settings.biometricEnabled;
  }
  
  void _applyUserSecuritySettings(UserModel user) {
    _pinEnabled = user.pinEnabled;
    _biometricEnabled = user.biometricEnabled;
  }
  
  ThemeMode _parseThemeMode(String theme) {
    switch (theme) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
  
  Future<void> _checkForUpdates() async {
    try {
      // Check app version and update status
      final updateInfo = await _syncService.checkForUpdates();
      _appVersion = updateInfo['version'];
      _forceUpdateRequired = updateInfo['forceUpdate'] ?? false;
      _maintenanceMode = updateInfo['maintenance'] ?? false;
    } catch (e) {
      // Continue with current version
    }
  }
  
  Future<void> _loadNotifications() async {
    try {
      final notificationsData = await _syncService.getNotifications();
      _notifications = notificationsData
          .map((json) => NotificationModel.fromJson(json))
          .toList();
      _unreadNotificationCount = _notifications.where((n) => !n.isRead).length;
    } catch (e) {
      // Continue with empty notifications
    }
  }
  
  // ==================== Authentication CRUD ====================
  
  /// Register a new user account
  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authService.register(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );
      
      if (result['success']) {
        _currentUser = UserModel.fromJson(result['user']);
        _isAuthenticated = true;
        _hasOnboarded = true;
        
        await _storageService.setBool(AppConstants.hasOnboardedKey, true);
        await _storageService.setString(
          AppConstants.currentUserKey,
          _currentUser!.toJson(),
        );
        
        notifyListeners();
        return true;
      } else {
        _setError(result['message'] ?? 'Registration failed');
        return false;
      }
    } catch (e) {
      _setError('Registration error: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Login with email and password
  Future<bool> login({
    required String email,
    required String password,
    String? deviceId,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authService.login(
        email: email,
        password: password,
        deviceId: deviceId,
      );
      
      if (result['success']) {
        _currentUser = UserModel.fromJson(result['user']);
        _isAuthenticated = true;
        _sessionExpiresAt = DateTime.now().add(const Duration(minutes: 30));
        
        await _storageService.setString(
          AppConstants.currentUserKey,
          _currentUser!.toJson(),
        );
        await _authService.storeToken(result['accessToken'], result['refreshToken']);
        
        notifyListeners();
        return true;
      } else {
        _setError(result['message'] ?? 'Login failed');
        return false;
      }
    } catch (e) {
      _setError('Login error: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Login with Google OAuth
  Future<bool> loginWithGoogle({
    required String idToken,
    String? deviceId,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authService.loginWithGoogle(
        idToken: idToken,
        deviceId: deviceId,
      );
      
      if (result['success']) {
        _currentUser = UserModel.fromJson(result['user']);
        _isAuthenticated = true;
        _hasOnboarded = true;
        _sessionExpiresAt = DateTime.now().add(const Duration(minutes: 30));
        
        await _storageService.setBool(AppConstants.hasOnboardedKey, true);
        await _storageService.setString(
          AppConstants.currentUserKey,
          _currentUser!.toJson(),
        );
        await _authService.storeToken(result['accessToken'], result['refreshToken']);
        
        notifyListeners();
        return true;
      } else {
        _setError(result['message'] ?? 'Google login failed');
        return false;
      }
    } catch (e) {
      _setError('Google login error: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Logout current user
  Future<void> logout() async {
    _setLoading(true);
    _clearError();
    
    try {
      await _authService.logout();
      await _clearUserData();
    } catch (e) {
      // Still clear local data
      await _clearUserData();
    } finally {
      _setLoading(false);
    }
  }
  
  /// Logout from all devices
  Future<bool> logoutAllDevices() async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authService.logoutAllDevices();
      if (result['success']) {
        await _clearUserData();
        return true;
      } else {
        _setError(result['message'] ?? 'Logout failed');
        return false;
      }
    } catch (e) {
      _setError('Logout error: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> _clearUserData() async {
    _currentUser = null;
    _isAuthenticated = false;
    _biometricVerified = false;
    _sessionExpiresAt = null;
    _notifications = [];
    _unreadNotificationCount = 0;
    
    await _storageService.remove(AppConstants.currentUserKey);
    await _authService.clearTokens();
    
    notifyListeners();
  }
  
  /// Refresh authentication token
  Future<bool> refreshToken() async {
    try {
      final result = await _authService.refreshToken();
      if (result['success']) {
        await _authService.storeToken(result['accessToken'], result['refreshToken']);
        _sessionExpiresAt = DateTime.now().add(const Duration(minutes: 30));
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Token refresh failed');
      return false;
    }
  }
  
  /// Verify PIN for sensitive operations
  Future<bool> verifyPin(String pin) async {
    try {
      final result = await _authService.verifyPin(pin);
      if (result['success']) {
        _biometricVerified = true;
        _sessionExpiresAt = DateTime.now().add(const Duration(minutes: 5));
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  /// Verify biometric authentication
  Future<bool> verifyBiometric() async {
    if (!_biometricEnabled) return false;
    
    try {
      final result = await _authService.verifyBiometric();
      if (result['success']) {
        _biometricVerified = true;
        _sessionExpiresAt = DateTime.now().add(const Duration(minutes: 5));
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  /// Set up PIN for the account
  Future<bool> setupPin(String pin) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authService.setupPin(pin);
      if (result['success']) {
        _pinEnabled = true;
        _currentUser?.pinEnabled = true;
        await _saveSettings();
        notifyListeners();
        return true;
      } else {
        _setError(result['message'] ?? 'PIN setup failed');
        return false;
      }
    } catch (e) {
      _setError('PIN setup error: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Change PIN
  Future<bool> changePin(String currentPin, String newPin) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authService.changePin(currentPin, newPin);
      if (result['success']) {
        notifyListeners();
        return true;
      } else {
        _setError(result['message'] ?? 'PIN change failed');
        return false;
      }
    } catch (e) {
      _setError('PIN change error: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Enable biometric authentication
  Future<bool> enableBiometric(String deviceId) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authService.enableBiometric(deviceId);
      if (result['success']) {
        _biometricEnabled = true;
        _currentUser?.biometricEnabled = true;
        await _saveSettings();
        notifyListeners();
        return true;
      } else {
        _setError(result['message'] ?? 'Biometric enable failed');
        return false;
      }
    } catch (e) {
      _setError('Biometric enable error: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Disable biometric authentication
  Future<bool> disableBiometric(String pin) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authService.disableBiometric(pin);
      if (result['success']) {
        _biometricEnabled = false;
        _currentUser?.biometricEnabled = false;
        await _saveSettings();
        notifyListeners();
        return true;
      } else {
        _setError(result['message'] ?? 'Biometric disable failed');
        return false;
      }
    } catch (e) {
      _setError('Biometric disable error: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // ==================== User Profile CRUD ====================
  
  /// Update user profile
  Future<bool> updateProfile({
    String? fullName,
    String? phone,
    String? avatarBase64,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authService.updateProfile(
        fullName: fullName,
        phone: phone,
        avatarBase64: avatarBase64,
      );
      
      if (result['success']) {
        _currentUser = UserModel.fromJson(result['user']);
        await _storageService.setString(
          AppConstants.currentUserKey,
          _currentUser!.toJson(),
        );
        notifyListeners();
        return true;
      } else {
        _setError(result['message'] ?? 'Profile update failed');
        return false;
      }
    } catch (e) {
      _setError('Profile update error: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      
      if (result['success']) {
        notifyListeners();
        return true;
      } else {
        _setError(result['message'] ?? 'Password change failed');
        return false;
      }
    } catch (e) {
      _setError('Password change error: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Delete user account
  Future<bool> deleteAccount(String password) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authService.deleteAccount(password);
      if (result['success']) {
        await _clearUserData();
        await _storageService.clearAll();
        return true;
      } else {
        _setError(result['message'] ?? 'Account deletion failed');
        return false;
      }
    } catch (e) {
      _setError('Account deletion error: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // ==================== Settings CRUD ====================
  
  /// Update app settings
  Future<bool> updateSettings(SettingsModel newSettings) async {
    _setLoading(true);
    _clearError();
    
    try {
      _settings = newSettings;
      _applySettings(newSettings);
      await _saveSettings();
      
      // Sync settings to server
      await _syncService.syncSettings(newSettings);
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Settings update error: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> _saveSettings() async {
    if (_settings != null) {
      await _storageService.setString(
        AppConstants.settingsKey,
        _settings!.toJson(),
      );
    }
  }
  
  /// Update theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    _settings?.theme = mode == ThemeMode.light ? 'light' 
                   : mode == ThemeMode.dark ? 'dark' 
                   : 'system';
    await _saveSettings();
    notifyListeners();
  }
  
  /// Update locale/language
  Future<void> setLocale(String locale) async {
    _locale = locale;
    _settings?.language = locale;
    await _saveSettings();
    notifyListeners();
  }
  
  /// Update currency
  Future<void> setCurrency(String currency, String symbol) async {
    _currency = currency;
    _currencySymbol = symbol;
    _settings?.currency = currency;
    _settings?.currencySymbol = symbol;
    await _saveSettings();
    notifyListeners();
  }
  
  /// Toggle notifications
  Future<void> toggleNotifications(bool enabled) async {
    _settings?.notificationsEnabled = enabled;
    await _saveSettings();
    notifyListeners();
  }
  
  /// Toggle daily reminder
  Future<void> toggleDailyReminder(bool enabled, {String? time}) async {
    _settings?.dailyReminderEnabled = enabled;
    if (time != null) _settings?.dailyReminderTime = time;
    await _saveSettings();
    notifyListeners();
  }
  
  /// Set low balance alert threshold
  Future<void> setLowBalanceThreshold(double amount) async {
    _settings?.lowBalanceThreshold = amount;
    await _saveSettings();
    notifyListeners();
  }
  
  /// Complete onboarding
  Future<void> completeOnboarding() async {
    _hasOnboarded = true;
    await _storageService.setBool(AppConstants.hasOnboardedKey, true);
    notifyListeners();
  }
  
  // ==================== Sync CRUD ====================
  
  /// Trigger manual sync
  Future<bool> syncData() async {
    if (_isSyncing) return false;
    
    _isSyncing = true;
    _clearError();
    notifyListeners();
    
    try {
      final result = await _syncService.performSync();
      
      if (result['success']) {
        _lastSyncTime = DateTime.now();
        _pendingSyncCount = 0;
        notifyListeners();
        return true;
      } else {
        _setError(result['message'] ?? 'Sync failed');
        return false;
      }
    } catch (e) {
      _setError('Sync error: ${e.toString()}');
      return false;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
  
  /// Update pending sync count
  void updatePendingSyncCount(int count) {
    _pendingSyncCount = count;
    notifyListeners();
  }
  
  /// Increment pending sync count
  void incrementPendingSync() {
    _pendingSyncCount++;
    notifyListeners();
  }
  
  /// Get sync status
  Future<Map<String, dynamic>> getSyncStatus() async {
    try {
      final status = await _syncService.getSyncStatus();
      _lastSyncTime = status['lastSync'];
      _pendingSyncCount = status['pendingChanges'] ?? 0;
      notifyListeners();
      return status;
    } catch (e) {
      return {
        'lastSync': _lastSyncTime,
        'pendingChanges': _pendingSyncCount,
        'status': 'error',
      };
    }
  }
  
  // ==================== Notification CRUD ====================
  
  /// Add a notification
  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    if (!notification.isRead) {
      _unreadNotificationCount++;
    }
    notifyListeners();
  }
  
  /// Mark notification as read
  Future<void> markNotificationRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index].isRead = true;
      _unreadNotificationCount--;
      await _syncService.markNotificationRead(notificationId);
      notifyListeners();
    }
  }
  
  /// Mark all notifications as read
  Future<void> markAllNotificationsRead() async {
    for (var notification in _notifications) {
      notification.isRead = true;
    }
    _unreadNotificationCount = 0;
    await _syncService.markAllNotificationsRead();
    notifyListeners();
  }
  
  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      if (!_notifications[index].isRead) {
        _unreadNotificationCount--;
      }
      _notifications.removeAt(index);
      await _syncService.deleteNotification(notificationId);
      notifyListeners();
    }
  }
  
  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    _notifications.clear();
    _unreadNotificationCount = 0;
    await _syncService.clearAllNotifications();
    notifyListeners();
  }
  
  /// Refresh notifications from server
  Future<void> refreshNotifications() async {
    try {
      await _loadNotifications();
      notifyListeners();
    } catch (e) {
      _setError('Failed to refresh notifications');
    }
  }
  
  // ==================== Network State ====================
  
  /// Update network connectivity state
  void updateNetworkState({
    required bool isOnline,
    bool? isWifi,
  }) {
    _isOnline = isOnline;
    _isWifi = isWifi ?? _isWifi;
    notifyListeners();
  }
  
  // ==================== Session Management ====================
  
  /// Lock the app (require re-authentication)
  void lockApp() {
    _biometricVerified = false;
    notifyListeners();
  }
  
  /// Unlock the app with biometric
  Future<bool> unlockWithBiometric() async {
    if (!_biometricEnabled) return false;
    return await verifyBiometric();
  }
  
  /// Unlock the app with PIN
  Future<bool> unlockWithPin(String pin) async {
    return await verifyPin(pin);
  }
  
  /// Update session expiration
  void extendSession() {
    _sessionExpiresAt = DateTime.now().add(const Duration(minutes: 30));
    notifyListeners();
  }
  
  // ==================== Performance Tracking ====================
  
  /// Track screen load time
  void trackScreenLoad(String screenName) {
    _screenTimings[screenName] = DateTime.now();
    notifyListeners();
  }
  
  /// Track API call
  void trackApiCall(String endpoint) {
    _apiCallCount[endpoint] = (_apiCallCount[endpoint] ?? 0) + 1;
    notifyListeners();
  }
  
  /// Get screen load time
  Duration? getScreenLoadTime(String screenName) {
    final start = _screenTimings[screenName];
    if (start == null) return null;
    return DateTime.now().difference(start);
  }
  
  /// Reset performance tracking
  void resetPerformanceTracking() {
    _screenTimings.clear();
    _apiCallCount.clear();
    notifyListeners();
  }
  
  // ==================== Export/Import ====================
  
  /// Export user data
  Future<Map<String, dynamic>?> exportUserData() async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _syncService.exportData();
      if (result['success']) {
        return result;
      } else {
        _setError(result['message'] ?? 'Export failed');
        return null;
      }
    } catch (e) {
      _setError('Export error: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Import user data
  Future<bool> importUserData(Map<String, dynamic> data) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _syncService.importData(data);
      if (result['success']) {
        await _loadUserProfile();
        notifyListeners();
        return true;
      } else {
        _setError(result['message'] ?? 'Import failed');
        return false;
      }
    } catch (e) {
      _setError('Import error: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // ==================== Helper Methods ====================
  
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
  
  /// Clear error after delay
  void clearErrorAfterDelay(Duration delay) {
    Future.delayed(delay, () {
      _clearError();
      notifyListeners();
    });
  }
  
  /// Reset provider to initial state
  void reset() {
    _currentUser = null;
    _settings = null;
    _isAuthenticated = false;
    _isInitialized = false;
    _isLoading = false;
    _isSyncing = false;
    _error = null;
    _lastSyncTime = null;
    _pendingSyncCount = 0;
    _notifications = [];
    _unreadNotificationCount = 0;
    _isOnline = true;
    _pinEnabled = false;
    _biometricEnabled = false;
    _biometricVerified = false;
    _sessionExpiresAt = null;
    _hasOnboarded = false;
    notifyListeners();
  }
  
  // ==================== Debug Methods ====================
  
  /// Print current state for debugging
  void debugPrintState() {
    debugPrint('=== AppProvider State ===');
    debugPrint('User: ${_currentUser?.fullName ?? 'null'}');
    debugPrint('Authenticated: $_isAuthenticated');
    debugPrint('Theme: $_themeMode');
    debugPrint('Locale: $_locale');
    debugPrint('Currency: $_currency ($_currencySymbol)');
    debugPrint('Online: $_isOnline');
    debugPrint('Syncing: $_isSyncing');
    debugPrint('Pending Sync: $_pendingSyncCount');
    debugPrint('Unread Notifications: $_unreadNotificationCount');
    debugPrint('PIN Enabled: $_pinEnabled');
    debugPrint('Biometric Enabled: $_biometricEnabled');
    debugPrint('Biometric Verified: $_biometricVerified');
  }
}
