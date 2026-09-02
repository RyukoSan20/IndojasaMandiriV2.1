import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import '../core/services/storage_service.dart';
import '../models/user_preferences.dart';

// Storage Service Provider
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

// User Preferences Provider
final userPreferencesProvider = StateNotifierProvider<UserPreferencesNotifier, UserPreferences>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return UserPreferencesNotifier(storageService);
});

class UserPreferencesNotifier extends StateNotifier<UserPreferences> {
  final StorageService _storageService;

  UserPreferencesNotifier(this._storageService) : super(UserPreferences.initial()) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final preferences = await _storageService.getUserPreferences();
    if (preferences != null) {
      state = preferences;
    }
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _storageService.saveUserPreferences(state);
  }

  Future<void> updateCurrency(String currency) async {
    state = state.copyWith(currency: currency);
    await _storageService.saveUserPreferences(state);
  }

  Future<void> updateLanguage(String languageCode) async {
    state = state.copyWith(languageCode: languageCode);
    await _storageService.saveUserPreferences(state);
  }

  Future<void> updateNotificationsEnabled(bool enabled) async {
    state = state.copyWith(notificationsEnabled: enabled);
    await _storageService.saveUserPreferences(state);
  }

  Future<void> updateOnboardingCompleted(bool completed) async {
    state = state.copyWith(onboardingCompleted: completed);
    await _storageService.saveUserPreferences(state);
  }
}

// Theme Mode Provider
final themeModeProvider = Provider<ThemeMode>((ref) {
  final preferences = ref.watch(userPreferencesProvider);
  return preferences.themeMode;
});

// Currency Provider
final currencyProvider = Provider<String>((ref) {
  final preferences = ref.watch(userPreferencesProvider);
  return preferences.currency;
});

// App Initialization Provider
final appInitializationProvider = FutureProvider<bool>((ref) async {
  final storageService = ref.read(storageServiceProvider);
  await storageService.init();
  return true;
});

// App Loading State Provider
final appLoadingProvider = StateProvider<bool>((ref) => false);

// App Error State Provider
final appErrorProvider = StateProvider<String?>((ref) => null);

// Tab Navigation Provider
final selectedTabIndexProvider = StateProvider<int>((ref) => 0);

// Search Query Provider
final searchQueryProvider = StateProvider<String>((ref) => '');

// Date Range Filter Provider
final dateRangeFilterProvider = StateProvider<DateTimeRange?>((ref) => null);

// Account Filter Provider
final accountFilterProvider = StateProvider<String?>((ref) => null);

// Category Filter Provider
final categoryFilterProvider = StateProvider<String?>((ref) => null);

// App Drawer State Provider
final isDrawerOpenProvider = StateProvider<bool>((ref) => false);

// Bottom Navigation Index Provider
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

// Chart Type Provider
final selectedChartTypeProvider = StateProvider<ChartType>((ref) => ChartType.bar);

// Time Period Provider for charts and analytics
final selectedTimePeriodProvider = StateProvider<TimePeriod>((ref) => TimePeriod.month);

// Dashboard Refresh Provider
final dashboardRefreshProvider = StateProvider<int>((ref) => 0);

// Notification Badge Count Provider
final notificationBadgeProvider = StateProvider<int>((ref) => 0);

// App Version Provider
final appVersionProvider = Provider<String>((ref) => AppConstants.appVersion);

// App Environment Provider
final appEnvironmentProvider = Provider<String>((ref) => AppConstants.environment);

// Enums
enum ChartType {
  bar,
  line,
  pie,
  area,
}

enum TimePeriod {
  week,
  month,
  quarter,
  year,
  all,
}

// Extension for TimePeriod display
extension TimePeriodExtension on TimePeriod {
  String get displayName {
    switch (this) {
      case TimePeriod.week:
        return 'This Week';
      case TimePeriod.month:
        return 'This Month';
      case TimePeriod.quarter:
        return 'This Quarter';
      case TimePeriod.year:
        return 'This Year';
      case TimePeriod.all:
        return 'All Time';
    }
  }

  int get days {
    switch (this) {
      case TimePeriod.week:
        return 7;
      case TimePeriod.month:
        return 30;
      case TimePeriod.quarter:
        return 90;
      case TimePeriod.year:
        return 365;
      case TimePeriod.all:
        return 0;
    }
  }
}

// App Global Key for Navigation
final scaffoldMessengerKeyProvider = Provider<GlobalKey<ScaffoldMessengerState>>((ref) {
  return GlobalKey<ScaffoldMessengerState>();
});

// Snackbar Helper
void showAppSnackbar(WidgetRef ref, String message, {bool isError = false, Duration? duration}) {
  final messengerKey = ref.read(scaffoldMessengerKeyProvider);
  messengerKey.currentState?.showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
      duration: duration ?? const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}
