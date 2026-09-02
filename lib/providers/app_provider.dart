import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// App settings and preferences state model
class AppSettings {
  final ThemeMode themeMode;
  final String currency;
  final String currencySymbol;
  final String locale;
  final String dateFormat;
  final int firstDayOfWeek;
  final bool notificationsEnabled;
  final bool biometricEnabled;
  final bool pinEnabled;
  final bool autoSync;
  final int syncFrequency;
  final double lowBalanceThreshold;
  final int budgetAlertPercentage;
  final int investmentAlertPercentage;
  final bool dailyReminderEnabled;
  final String reminderTime;
  final bool transactionAlerts;
  final bool portfolioAlerts;
  final bool savingsMilestones;

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.currency = 'IDR',
    this.currencySymbol = 'Rp',
    this.locale = 'id_ID',
    this.dateFormat = 'DD/MM/YYYY',
    this.firstDayOfWeek = 1,
    this.notificationsEnabled = true,
    this.biometricEnabled = false,
    this.pinEnabled = false,
    this.autoSync = true,
    this.syncFrequency = 5,
    this.lowBalanceThreshold = 500000,
    this.budgetAlertPercentage = 80,
    this.investmentAlertPercentage = 10,
    this.dailyReminderEnabled = true,
    this.reminderTime = '20:00',
    this.transactionAlerts = true,
    this.portfolioAlerts = true,
    this.savingsMilestones = true,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    String? currency,
    String? currencySymbol,
    String? locale,
    String? dateFormat,
    int? firstDayOfWeek,
    bool? notificationsEnabled,
    bool? biometricEnabled,
    bool? pinEnabled,
    bool? autoSync,
    int? syncFrequency,
    double? lowBalanceThreshold,
    int? budgetAlertPercentage,
    int? investmentAlertPercentage,
    bool? dailyReminderEnabled,
    String? reminderTime,
    bool? transactionAlerts,
    bool? portfolioAlerts,
    bool? savingsMilestones,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      currency: currency ?? this.currency,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      locale: locale ?? this.locale,
      dateFormat: dateFormat ?? this.dateFormat,
      firstDayOfWeek: firstDayOfWeek ?? this.firstDayOfWeek,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      pinEnabled: pinEnabled ?? this.pinEnabled,
      autoSync: autoSync ?? this.autoSync,
      syncFrequency: syncFrequency ?? this.syncFrequency,
      lowBalanceThreshold: lowBalanceThreshold ?? this.lowBalanceThreshold,
      budgetAlertPercentage: budgetAlertPercentage ?? this.budgetAlertPercentage,
      investmentAlertPercentage: investmentAlertPercentage ?? this.investmentAlertPercentage,
      dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      transactionAlerts: transactionAlerts ?? this.transactionAlerts,
      portfolioAlerts: portfolioAlerts ?? this.portfolioAlerts,
      savingsMilestones: savingsMilestones ?? this.savingsMilestones,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.index,
      'currency': currency,
      'currencySymbol': currencySymbol,
      'locale': locale,
      'dateFormat': dateFormat,
      'firstDayOfWeek': firstDayOfWeek,
      'notificationsEnabled': notificationsEnabled,
      'biometricEnabled': biometricEnabled,
      'pinEnabled': pinEnabled,
      'autoSync': autoSync,
      'syncFrequency': syncFrequency,
      'lowBalanceThreshold': lowBalanceThreshold,
      'budgetAlertPercentage': budgetAlertPercentage,
      'investmentAlertPercentage': investmentAlertPercentage,
      'dailyReminderEnabled': dailyReminderEnabled,
      'reminderTime': reminderTime,
      'transactionAlerts': transactionAlerts,
      'portfolioAlerts': portfolioAlerts,
      'savingsMilestones': savingsMilestones,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeMode: ThemeMode.values[json['themeMode'] ?? 0],
      currency: json['currency'] ?? 'IDR',
      currencySymbol: json['currencySymbol'] ?? 'Rp',
      locale: json['locale'] ?? 'id_ID',
      dateFormat: json['dateFormat'] ?? 'DD/MM/YYYY',
      firstDayOfWeek: json['firstDayOfWeek'] ?? 1,
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      biometricEnabled: json['biometricEnabled'] ?? false,
      pinEnabled: json['pinEnabled'] ?? false,
      autoSync: json['autoSync'] ?? true,
      syncFrequency: json['syncFrequency'] ?? 5,
      lowBalanceThreshold: (json['lowBalanceThreshold'] ?? 500000).toDouble(),
      budgetAlertPercentage: json['budgetAlertPercentage'] ?? 80,
      investmentAlertPercentage: json['investmentAlertPercentage'] ?? 10,
      dailyReminderEnabled: json['dailyReminderEnabled'] ?? true,
      reminderTime: json['reminderTime'] ?? '20:00',
      transactionAlerts: json['transactionAlerts'] ?? true,
      portfolioAlerts: json['portfolioAlerts'] ?? true,
      savingsMilestones: json['savingsMilestones'] ?? true,
    );
  }
}

/// Notification model for in-app notifications
class AppNotification {
  final String id;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.data,
    this.isRead = false,
    required this.createdAt,
  });

  AppNotification copyWith({
    String? id,
    String? type,
    String? title,
    String? body,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'body': body,
      'data': data,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      type: json['type'],
      title: json['title'],
      body: json['body'],
      data: json['data'],
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

/// Sync status model
enum SyncStatus {
  idle,
  syncing,
  success,
  error,
  offline,
}

/// App provider state
class AppProviderState {
  final bool isInitialized;
  final bool isLoading;
  final String? error;
  final AppSettings settings;
  final SyncStatus syncStatus;
  final DateTime? lastSyncTime;
  final int pendingChanges;
  final List<AppNotification> notifications;
  final int unreadNotificationCount;
  final String? activeModal;
  final bool isOnline;
  final String appVersion;
  final bool isFirstLaunch;

  const AppProviderState({
    this.isInitialized = false,
    this.isLoading = false,
    this.error,
    this.settings = const AppSettings(),
    this.syncStatus = SyncStatus.idle,
    this.lastSyncTime,
    this.pendingChanges = 0,
    this.notifications = const [],
    this.unreadNotificationCount = 0,
    this.activeModal,
    this.isOnline = true,
    this.appVersion = '1.0.0',
    this.isFirstLaunch = true,
  });

  AppProviderState copyWith({
    bool? isInitialized,
    bool? isLoading,
    String? error,
    AppSettings? settings,
    SyncStatus? syncStatus,
    DateTime? lastSyncTime,
    int? pendingChanges,
    List<AppNotification>? notifications,
    int? unreadNotificationCount,
    String? activeModal,
    bool? isOnline,
    String? appVersion,
    bool? isFirstLaunch,
  }) {
    return AppProviderState(
      isInitialized: isInitialized ?? this.isInitialized,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      settings: settings ?? this.settings,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      pendingChanges: pendingChanges ?? this.pendingChanges,
      notifications: notifications ?? this.notifications,
      unreadNotificationCount: unreadNotificationCount ?? this.unreadNotificationCount,
      activeModal: activeModal,
      isOnline: isOnline ?? this.isOnline,
      appVersion: appVersion ?? this.appVersion,
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
    );
  }
}

/// AppProvider - Central state management for app-wide settings and state
/// Uses ChangeNotifier pattern for reactive state updates
class AppProvider extends ChangeNotifier {
  AppProviderState _state = const AppProviderState();
  AppProviderState get state => _state;

  SharedPreferences? _prefs;
  static const String _settingsKey = 'app_settings';
  static const String _notificationsKey = 'app_notifications';
  static const String _lastSyncKey = 'last_sync_time';
  static const String _firstLaunchKey = 'is_first_launch';
  static const String _pendingChangesKey = 'pending_changes';

  // Convenience getters
  bool get isInitialized => _state.isInitialized;
  bool get isLoading => _state.isLoading;
  String? get error => _state.error;
  AppSettings get settings => _state.settings;
  SyncStatus get syncStatus => _state.syncStatus;
  DateTime? get lastSyncTime => _state.lastSyncTime;
  int get pendingChanges => _state.pendingChanges;
  List<AppNotification> get notifications => _state.notifications;
  int get unreadNotificationCount => _state.unreadNotificationCount;
  bool get isOnline => _state.isOnline;
  String get appVersion => _state.appVersion;
  bool get isFirstLaunch => _state.isFirstLaunch;
  ThemeMode get themeMode => _state.settings.themeMode;
  String get currency => _state.settings.currency;
  String get currencySymbol => _state.settings.currencySymbol;

  /// Initialize the app provider - load settings from storage
  Future<void> initialize() async {
    if (_state.isInitialized) return;

    _setLoading(true);
    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadSettings();
      await _loadNotifications();
      await _loadSyncData();
      await _checkFirstLaunch();
      _setInitialized(true);
    } catch (e) {
      _setError('Failed to initialize app: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load settings from local storage
  Future<void> _loadSettings() async {
    try {
      final settingsJson = _prefs?.getString(_settingsKey);
      if (settingsJson != null) {
        final decoded = jsonDecode(settingsJson) as Map<String, dynamic>;
        final loadedSettings = AppSettings.fromJson(decoded);
        _state = _state.copyWith(settings: loadedSettings);
      }
    } catch (e) {
      // Use default settings if loading fails
      debugPrint('Error loading settings: $e');
    }
  }

  /// Save settings to local storage
  Future<void> _saveSettings() async {
    try {
      final settingsJson = jsonEncode(_state.settings.toJson());
      await _prefs?.setString(_settingsKey, settingsJson);
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  /// Load notifications from local storage
  Future<void> _loadNotifications() async {
    try {
      final notificationsJson = _prefs?.getString(_notificationsKey);
      if (notificationsJson != null) {
        final decoded = jsonDecode(notificationsJson) as List<dynamic>;
        final notifications = decoded
            .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
            .toList();
        final unreadCount = notifications.where((n) => !n.isRead).length;
        _state = _state.copyWith(
          notifications: notifications,
          unreadNotificationCount: unreadCount,
        );
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    }
  }

  /// Save notifications to local storage
  Future<void> _saveNotifications() async {
    try {
      final notificationsJson = jsonEncode(
        _state.notifications.map((n) => n.toJson()).toList(),
      );
      await _prefs?.setString(_notificationsKey, notificationsJson);
    } catch (e) {
      debugPrint('Error saving notifications: $e');
    }
  }

  /// Load sync data from local storage
  Future<void> _loadSyncData() async {
    try {
      final lastSyncString = _prefs?.getString(_lastSyncKey);
      final pendingChanges = _prefs?.getInt(_pendingChangesKey) ?? 0;
      
      DateTime? lastSyncTime;
      if (lastSyncString != null) {
        lastSyncTime = DateTime.tryParse(lastSyncString);
      }

      _state = _state.copyWith(
        lastSyncTime: lastSyncTime,
        pendingChanges: pendingChanges,
      );
    } catch (e) {
      debugPrint('Error loading sync data: $e');
    }
  }

  /// Check if this is the first app launch
  Future<void> _checkFirstLaunch() async {
    final isFirstLaunch = _prefs?.getBool(_firstLaunchKey) ?? true;
    if (isFirstLaunch) {
      await _prefs?.setBool(_firstLaunchKey, false);
    }
    _state = _state.copyWith(isFirstLaunch: isFirstLaunch);
  }

  // ==================== Theme Settings CRUD ====================

  /// Update theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    _state = _state.copyWith(
      settings: _state.settings.copyWith(themeMode: mode),
    );
    notifyListeners();
    await _saveSettings();
  }

  /// Toggle between light and dark theme
  Future<void> toggleTheme() async {
    final currentMode = _state.settings.themeMode;
    ThemeMode newMode;
    
    switch (currentMode) {
      case ThemeMode.system:
        newMode = ThemeMode.light;
        break;
      case ThemeMode.light:
        newMode = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        newMode = ThemeMode.system;
        break;
    }
    
    await setThemeMode(newMode);
  }

  // ==================== Currency Settings CRUD ====================

  /// Update currency settings
  Future<void> setCurrency({
    required String currency,
    required String currencySymbol,
  }) async {
    _state = _state.copyWith(
      settings: _state.settings.copyWith(
        currency: currency,
        currencySymbol: currencySymbol,
      ),
    );
    notifyListeners();
    await _saveSettings();
  }

  /// Set currency by code (IDR, USD, EUR, etc.)
  Future<void> setCurrencyCode(String currency) async {
    final symbols = {
      'IDR': 'Rp',
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
      'SGD': 'S\$',
      'JPY': '¥',
      'MYR': 'RM',
      'THB': '฿',
    };
    final symbol = symbols[currency] ?? currency;
    await setCurrency(currency: currency, currencySymbol: symbol);
  }

  // ==================== Locale Settings CRUD ====================

  /// Update locale settings
  Future<void> setLocale(String locale) async {
    _state = _state.copyWith(
      settings: _state.settings.copyWith(locale: locale),
    );
    notifyListeners();
    await _saveSettings();
  }

  /// Update date format
  Future<void> setDateFormat(String format) async {
    _state = _state.copyWith(
      settings: _state.settings.copyWith(dateFormat: format),
    );
    notifyListeners();
    await _saveSettings();
  }

  /// Update first day of week
  Future<void> setFirstDayOfWeek(int day) async {
    if (day < 0 || day > 6) return;
    _state = _state.copyWith(
      settings: _state.settings.copyWith(firstDayOfWeek: day),
    );
    notifyListeners();
    await _saveSettings();
  }

  // ==================== Notification Settings CRUD ====================

  /// Toggle all notifications
  Future<void> setNotificationsEnabled(bool enabled) async {
    _state = _state.copyWith(
      settings: _state.settings.copyWith(notificationsEnabled: enabled),
    );
    notifyListeners();
    await _saveSettings();
  }

  /// Toggle daily reminder
  Future<void> setDailyReminderEnabled(bool enabled) async {
    _state = _state.copyWith(
      settings: _state.settings.copyWith(dailyReminderEnabled: enabled),
    );
    notifyListeners();
    await _saveSettings();
  }

  /// Set reminder time
  Future<void> setReminderTime(String time) async {
    _state = _state.copyWith(
      settings: _state.settings.copyWith(reminderTime: time),
    );
    notifyListeners();
    await _saveSettings();
  }

  /// Toggle transaction alerts
  Future<void> setTransactionAlerts(bool enabled) async {
    _state = _state.copyWith(
      settings: _state.settings.copyWith(transactionAlerts: enabled),
    );
    notifyListeners();
    await _saveSettings();
  }

  /// Toggle portfolio alerts
  Future<void> setPortfolioAlerts(bool enabled) async {
    _state = _state.copyWith(
      settings: _state.settings.copyWith(portfolioAlerts: enabled),
    );
    notifyListeners();
    await _saveSettings();
  }

  /// Toggle savings milestones notifications
  Future<void> setSavingsMilestones(bool enabled) async {
    _state = _state.copyWith(
      settings: _state.settings.copyWith(savingsMilestones: enabled),
    );
    notifyListeners();
    await _saveSettings();
  }

  // ==================== Security Settings CRUD ====================

  /// Enable biometric authentication
  Future<void> setBiometricEnabled(bool enabled) async {
    _state = _state.copyWith(
      settings: _state.settings.copyWith(biometricEnabled: enabled),
    );
    notifyListeners();
    await _saveSettings();
  }

  /// Enable PIN authentication
  Future<void> setPinEnabled(bool enabled) async {
    _state = _state.copyWith(
      settings: _state.settings.copyWith(pinEnabled: enabled),
    );
    notifyListeners();
    await _saveSettings();
  }

  // ==================== Sync Settings CRUD ====================

  /// Toggle auto sync
  Future<void> setAutoSync(bool enabled) async {
    _state = _state.copyWith(
      settings: _state.settings.copyWith(autoSync: enabled),
    );
    notifyListeners();
    await _saveSettings();
  }

  /// Set sync frequency in minutes
  Future<void> setSyncFrequency(int minutes) async {
    if (minutes < 1 || minutes > 60) return;
    _state = _state.copyWith(
      settings: _state.settings.copyWith(syncFrequency: minutes),
    );
    notifyListeners();
    await _saveSettings();
  }

  /// Update sync status
  void setSyncStatus(SyncStatus status) {
    _state = _state.copyWith(syncStatus: status);
    notifyListeners();
  }

  /// Update last sync time
  Future<void> setLastSyncTime(DateTime time) async {
    _state = _state.copyWith(lastSyncTime: time);
    notifyListeners();
    await _prefs?.setString(_lastSyncKey, time.toIso8601String());
  }

  /// Update pending changes count
  Future<void> setPendingChanges(int count) async {
    _state = _state.copyWith(pendingChanges: count);
    notifyListeners();
    await _prefs?.setInt(_pendingChangesKey, count);
  }

  /// Increment pending changes
  Future<void> incrementPendingChanges() async {
    await setPendingChanges(_state.pendingChanges + 1);
  }

  /// Decrement pending changes
  Future<void> decrementPendingChanges() async {
    final newCount = _state.pendingChanges - 1;
    await setPendingChanges(newCount < 0 ? 0 : newCount);
  }

  // ==================== Alert Settings CRUD ====================

  /// Set low balance threshold
  Future<void> setLowBalanceThreshold(double amount) async {
    _state = _state.copyWith(
      settings: _state.settings.copyWith(lowBalanceThreshold: amount),
    );
    notifyListeners();
    await _saveSettings();
  }

  /// Set budget alert percentage
  Future<void> setBudgetAlertPercentage(int percentage) async {
    if (percentage < 0 || percentage > 100) return;
    _state = _state.copyWith(
      settings: _state.settings.copyWith(budgetAlertPercentage: percentage),
    );
    notifyListeners();
    await _saveSettings();
  }

  /// Set investment alert percentage
  Future<void> setInvestmentAlertPercentage(int percentage) async {
    if (percentage < 0 || percentage > 100) return;
    _state = _state.copyWith(
      settings: _state.settings.copyWith(investmentAlertPercentage: percentage),
    );
    notifyListeners();
    await _saveSettings();
  }

  // ==================== Notification Management CRUD ====================

  /// Add a new notification
  Future<void> addNotification(AppNotification notification) async {
    final updatedNotifications = [notification, ..._state.notifications];
    final unreadCount = updatedNotifications.where((n) => !n.isRead).length;
    _state = _state.copyWith(
      notifications: updatedNotifications,
      unreadNotificationCount: unreadCount,
    );
    notifyListeners();
    await _saveNotifications();
  }

  /// Create and add notification from parameters
  Future<void> createNotification({
    required String type,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      title: title,
      body: body,
      data: data,
      createdAt: DateTime.now(),
    );
    await addNotification(notification);
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(String id) async {
    final updatedNotifications = _state.notifications.map((n) {
      if (n.id == id) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();
    final unreadCount = updatedNotifications.where((n) => !n.isRead).length;
    _state = _state.copyWith(
      notifications: updatedNotifications,
      unreadNotificationCount: unreadCount,
    );
    notifyListeners();
    await _saveNotifications();
  }

  /// Mark all notifications as read
  Future<void> markAllNotificationsAsRead() async {
    final updatedNotifications = _state.notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();
    _state = _state.copyWith(
      notifications: updatedNotifications,
      unreadNotificationCount: 0,
    );
    notifyListeners();
    await _saveNotifications();
  }

  /// Delete a notification
  Future<void> deleteNotification(String id) async {
    final updatedNotifications =
        _state.notifications.where((n) => n.id != id).toList();
    final unreadCount = updatedNotifications.where((n) => !n.isRead).length;
    _state = _state.copyWith(
      notifications: updatedNotifications,
      unreadNotificationCount: unreadCount,
    );
    notifyListeners();
    await _saveNotifications();
  }

  /// Delete all notifications
  Future<void> deleteAllNotifications() async {
    _state = _state.copyWith(
      notifications: [],
      unreadNotificationCount: 0,
    );
    notifyListeners();
    await _saveNotifications();
  }

  /// Delete read notifications only
  Future<void> deleteReadNotifications() async {
    final updatedNotifications =
        _state.notifications.where((n) => !n.isRead).toList();
    _state = _state.copyWith(
      notifications: updatedNotifications,
      unreadNotificationCount: updatedNotifications.length,
    );
    notifyListeners();
    await _saveNotifications();
  }

  /// Filter notifications by type
  List<AppNotification> getNotificationsByType(String type) {
    return _state.notifications.where((n) => n.type == type).toList();
  }

  /// Get unread notifications
  List<AppNotification> get unreadNotifications {
    return _state.notifications.where((n) => !n.isRead).toList();
  }

  // ==================== UI State Management ====================

  /// Set active modal
  void setActiveModal(String? modalId) {
    _state = _state.copyWith(activeModal: modalId);
    notifyListeners();
  }

  /// Close active modal
  void closeModal() {
    _state = _state.copyWith(activeModal: null);
    notifyListeners();
  }

  /// Set online status
  void setOnlineStatus(bool isOnline) {
    _state = _state.copyWith(
      isOnline: isOnline,
      syncStatus: isOnline ? SyncStatus.idle : SyncStatus.offline,
    );
    notifyListeners();
  }

  // ==================== Bulk Settings Update ====================

  /// Update all settings at once
  Future<void> updateSettings(AppSettings newSettings) async {
    _state = _state.copyWith(settings: newSettings);
    notifyListeners();
    await _saveSettings();
  }

  /// Reset all settings to default
  Future<void> resetSettings() async {
    _state = _state.copyWith(settings: const AppSettings());
    notifyListeners();
    await _saveSettings();
  }

  // ==================== Sync Operations ====================

  /// Perform sync operation
  Future<void> performSync() async {
    if (_state.syncStatus == SyncStatus.syncing) return;
    if (!_state.isOnline) {
      _state = _state.copyWith(syncStatus: SyncStatus.offline);
      notifyListeners();
      return;
    }

    _state = _state.copyWith(syncStatus: SyncStatus.syncing);
    notifyListeners();

    try {
      // Simulate sync delay - replace with actual sync logic
      await Future.delayed(const Duration(seconds: 2));
      
      // Clear pending changes after successful sync
      await setPendingChanges(0);
      await setLastSyncTime(DateTime.now());
      
      _state = _state.copyWith(syncStatus: SyncStatus.success);
      notifyListeners();

      // Reset to idle after showing success
      await Future.delayed(const Duration(seconds: 2));
      _state = _state.copyWith(syncStatus: SyncStatus.idle);
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(syncStatus: SyncStatus.error);
      notifyListeners();
      _setError('Sync failed: $e');
    }
  }

  // ==================== Helper Methods ====================

  void _setLoading(bool loading) {
    _state = _state.copyWith(isLoading: loading);
    notifyListeners();
  }

  void _setError(String error) {
    _state = _state.copyWith(error: error);
    notifyListeners();
  }

  void _setInitialized(bool initialized) {
    _state = _state.copyWith(isInitialized: initialized);
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _state = _state.copyWith(error: null);
    notifyListeners();
  }

  /// Format currency amount
  String formatCurrency(double amount) {
    final symbol = _state.settings.currencySymbol;
    final formatted = amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return '$symbol $formatted';
  }

  /// Format date according to settings
  String formatDate(DateTime date) {
    final format = _state.settings.dateFormat;
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;

    switch (format) {
      case 'MM/DD/YYYY':
        return '$month/$day/$year';
      case 'YYYY-MM-DD':
        return '$year-$month-$day';
      case 'DD-MM-YYYY':
        return '$day-$month-$year';
      case 'DD/MM/YYYY':
      default:
        return '$day/$month/$year';
    }
  }

  /// Get time ago string
  String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} tahun lalu';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} bulan lalu';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit lalu';
    } else {
      return 'Baru saja';
    }
  }

  // ==================== Export/Import Settings ====================

  /// Export settings as JSON string
  String exportSettings() {
    return jsonEncode(_state.settings.toJson());
  }

  /// Import settings from JSON string
  Future<bool> importSettings(String jsonString) async {
    try {
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      final importedSettings = AppSettings.fromJson(decoded);
      await updateSettings(importedSettings);
      return true;
    } catch (e) {
      _setError('Failed to import settings: $e');
      return false;
    }
  }

  // ==================== Cleanup ====================

  @override
  void dispose() {
    _prefs = null;
    super.dispose();
  }
}
