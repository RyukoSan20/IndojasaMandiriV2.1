import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fintrack/services/storage_service.dart';
import 'package:fintrack/utils/app_theme.dart';
import 'package:fintrack/utils/constants.dart';

/// App-wide settings state
class AppSettings {
  final ThemeMode themeMode;
  final String locale;
  final bool isOnboardingComplete;
  final bool isFirstLaunch;
  final String currency;
  final DateTime? lastSyncTime;

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.locale = 'en',
    this.isOnboardingComplete = false,
    this.isFirstLaunch = true,
    this.currency = 'USD',
    this.lastSyncTime,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    String? locale,
    bool? isOnboardingComplete,
    bool? isFirstLaunch,
    String? currency,
    DateTime? lastSyncTime,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      isOnboardingComplete: isOnboardingComplete ?? this.isOnboardingComplete,
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      currency: currency ?? this.currency,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.index,
      'locale': locale,
      'isOnboardingComplete': isOnboardingComplete,
      'isFirstLaunch': isFirstLaunch,
      'currency': currency,
      'lastSyncTime': lastSyncTime?.toIso8601String(),
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeMode: ThemeMode.values[json['themeMode'] as int? ?? 0],
      locale: json['locale'] as String? ?? 'en',
      isOnboardingComplete: json['isOnboardingComplete'] as bool? ?? false,
      isFirstLaunch: json['isFirstLaunch'] as bool? ?? true,
      currency: json['currency'] as String? ?? 'USD',
      lastSyncTime: json['lastSyncTime'] != null
          ? DateTime.parse(json['lastSyncTime'] as String)
          : null,
    );
  }
}

/// App settings notifier for managing app-wide state
class AppSettingsNotifier extends StateNotifier<AppSettings> {
  final StorageService _storageService;

  AppSettingsNotifier(this._storageService) : super(const AppSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settingsJson = await _storageService.getJson(AppConstants.settingsKey);
    if (settingsJson != null) {
      state = AppSettings.fromJson(settingsJson);
    }
  }

  Future<void> _saveSettings() async {
    await _storageService.setJson(AppConstants.settingsKey, state.toJson());
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _saveSettings();
  }

  Future<void> toggleTheme() async {
    final newMode = state.themeMode == ThemeMode.light
        ? ThemeMode.dark
        : state.themeMode == ThemeMode.dark
            ? ThemeMode.system
            : ThemeMode.light;
    state = state.copyWith(themeMode: newMode);
    await _saveSettings();
  }

  Future<void> setLocale(String locale) async {
    state = state.copyWith(locale: locale);
    await _saveSettings();
  }

  Future<void> setCurrency(String currency) async {
    state = state.copyWith(currency: currency);
    await _saveSettings();
  }

  Future<void> completeOnboarding() async {
    state = state.copyWith(isOnboardingComplete: true, isFirstLaunch: false);
    await _saveSettings();
  }

  Future<void> setLastSyncTime(DateTime time) async {
    state = state.copyWith(lastSyncTime: time);
    await _saveSettings();
  }

  Future<void> resetSettings() async {
    state = const AppSettings();
    await _saveSettings();
  }
}

/// Storage service provider
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

/// App settings provider
final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettings>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return AppSettingsNotifier(storageService);
});

/// Theme provider derived from app settings
final themeProvider = Provider<ThemeData>((ref) {
  final settings = ref.watch(appSettingsProvider);
  return settings.themeMode == ThemeMode.dark
      ? AppTheme.darkTheme
      : AppTheme.lightTheme;
});

/// Theme mode provider derived from app settings
final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(appSettingsProvider).themeMode;
});

/// Locale provider derived from app settings
final localeProvider = Provider<Locale>((ref) {
  final settings = ref.watch(appSettingsProvider);
  return Locale(settings.locale);
});

/// Currency provider derived from app settings
final currencyProvider = Provider<String>((ref) {
  return ref.watch(appSettingsProvider).currency;
});

/// Onboarding status provider
final isOnboardingCompleteProvider = Provider<bool>((ref) {
  return ref.watch(appSettingsProvider).isOnboardingComplete;
});

/// First launch status provider
final isFirstLaunchProvider = Provider<bool>((ref) {
  return ref.watch(appSettingsProvider).isFirstLaunch;
});

/// Navigation state
class NavigationState {
  final int selectedIndex;
  final List<String> navigationHistory;
  final Map<String, dynamic>? pendingData;

  const NavigationState({
    this.selectedIndex = 0,
    this.navigationHistory = const ['/dashboard'],
    this.pendingData,
  });

  NavigationState copyWith({
    int? selectedIndex,
    List<String>? navigationHistory,
    Map<String, dynamic>? pendingData,
  }) {
    return NavigationState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      navigationHistory: navigationHistory ?? this.navigationHistory,
      pendingData: pendingData ?? this.pendingData,
    );
  }
}

/// Navigation state notifier
class NavigationNotifier extends StateNotifier<NavigationState> {
  NavigationNotifier() : super(const NavigationState());

  void setSelectedIndex(int index) {
    state = state.copyWith(selectedIndex: index);
  }

  void pushRoute(String route) {
    final history = List<String>.from(state.navigationHistory);
    history.add(route);
    state = state.copyWith(navigationHistory: history);
  }

  void popRoute() {
    if (state.navigationHistory.length > 1) {
      final history = List<String>.from(state.navigationHistory);
      history.removeLast();
      state = state.copyWith(navigationHistory: history);
    }
  }

  void setPendingData(Map<String, dynamic>? data) {
    state = state.copyWith(pendingData: data);
  }

  void clearPendingData() {
    state = state.copyWith(pendingData: null);
  }

  void reset() {
    state = const NavigationState();
  }
}

/// Navigation state provider
final navigationProvider =
    StateNotifierProvider<NavigationNotifier, NavigationState>((ref) {
  return NavigationNotifier();
});

/// App initialization state
enum AppInitializationStatus {
  uninitialized,
  initializing,
  initialized,
  error,
}

class AppInitializationState {
  final AppInitializationStatus status;
  final String? errorMessage;
  final double progress;

  const AppInitializationState({
    this.status = AppInitializationStatus.uninitialized,
    this.errorMessage,
    this.progress = 0.0,
  });

  AppInitializationState copyWith({
    AppInitializationStatus? status,
    String? errorMessage,
    double? progress,
  }) {
    return AppInitializationState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      progress: progress ?? this.progress,
    );
  }
}

/// App initialization notifier
class AppInitializationNotifier extends StateNotifier<AppInitializationState> {
  final Ref _ref;

  AppInitializationNotifier(this._ref) : super(const AppInitializationState());

  Future<void> initialize() async {
    if (state.status == AppInitializationStatus.initializing) return;

    state = state.copyWith(
      status: AppInitializationStatus.initializing,
      progress: 0.0,
    );

    try {
      // Initialize storage service
      state = state.copyWith(progress: 0.2);
      await _ref.read(storageServiceProvider).init();

      // Load app settings
      state = state.copyWith(progress: 0.4);
      await Future.delayed(const Duration(milliseconds: 100));

      // Check connectivity and sync status
      state = state.copyWith(progress: 0.6);
      await Future.delayed(const Duration(milliseconds: 100));

      // Load user data
      state = state.copyWith(progress: 0.8);
      await Future.delayed(const Duration(milliseconds: 100));

      // Complete initialization
      state = state.copyWith(
        status: AppInitializationStatus.initialized,
        progress: 1.0,
      );
    } catch (e) {
      state = state.copyWith(
        status: AppInitializationStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() {
    state = const AppInitializationState();
  }
}

/// App initialization provider
final appInitializationProvider =
    StateNotifierProvider<AppInitializationNotifier, AppInitializationState>(
        (ref) {
  return AppInitializationNotifier(ref);
});

/// Loading state provider for async operations
final isLoadingProvider = StateProvider<bool>((ref) => false);

/// Error state provider for global error handling
class AppError {
  final String message;
  final String? code;
  final DateTime timestamp;
  final bool isDismissed;

  const AppError({
    required this.message,
    this.code,
    required this.timestamp,
    this.isDismissed = false,
  });

  AppError copyWith({
    String? message,
    String? code,
    DateTime? timestamp,
    bool? isDismissed,
  }) {
    return AppError(
      message: message ?? this.message,
      code: code ?? this.code,
      timestamp: timestamp ?? this.timestamp,
      isDismissed: isDismissed ?? this.isDismissed,
    );
  }
}

/// Error state notifier for managing app errors
class AppErrorNotifier extends StateNotifier<AppError?> {
  AppErrorNotifier() : super(null);

  void setError(String message, {String? code}) {
    state = AppError(
      message: message,
      code: code,
      timestamp: DateTime.now(),
    );
  }

  void clearError() {
    state = null;
  }

  void dismissError() {
    if (state != null) {
      state = state!.copyWith(isDismissed: true);
    }
  }
}

/// App error provider
final appErrorProvider =
    StateNotifierProvider<AppErrorNotifier, AppError?>((ref) {
  return AppErrorNotifier();
});

/// Supported locales constant
const supportedLocales = [
  Locale('en'),
  Locale('es'),
  Locale('fr'),
  Locale('de'),
  Locale('pt'),
  Locale('zh'),
  Locale('ja'),
];

/// Supported currencies constant
const supportedCurrencies = [
  'USD',
  'EUR',
  'GBP',
  'JPY',
  'CNY',
  'INR',
  'CAD',
  'AUD',
  'CHF',
  'BRL',
];

/// Currency symbols map
const currencySymbols = {
  'USD': '\$',
  'EUR': '€',
  'GBP': '£',
  'JPY': '¥',
  'CNY': '¥',
  'INR': '₹',
  'CAD': 'C\$',
  'AUD': 'A\$',
  'CHF': 'Fr',
  'BRL': 'R\$',
};

/// Get currency symbol for a given currency code
String getCurrencySymbol(String currencyCode) {
  return currencySymbols[currencyCode] ?? currencyCode;
}
