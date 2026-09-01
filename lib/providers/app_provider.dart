import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fintrack/core/theme/app_theme.dart';
import 'package:fintrack/core/constants/app_constants.dart';
import 'package:fintrack/services/auth_service.dart';
import 'package:fintrack/services/storage_service.dart';

/// App-wide state class containing global application state
class AppState {
  final bool isInitialized;
  final bool isAuthenticated;
  final ThemeMode themeMode;
  final String? userId;
  final String? userEmail;
  final bool isLoading;
  final String? errorMessage;
  final bool isOffline;
  final String locale;

  const AppState({
    this.isInitialized = false,
    this.isAuthenticated = false,
    this.themeMode = ThemeMode.system,
    this.userId,
    this.userEmail,
    this.isLoading = false,
    this.errorMessage,
    this.isOffline = false,
    this.locale = 'en',
  });

  AppState copyWith({
    bool? isInitialized,
    bool? isAuthenticated,
    ThemeMode? themeMode,
    String? userId,
    String? userEmail,
    bool? isLoading,
    String? errorMessage,
    bool? isOffline,
    String? locale,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AppState(
      isInitialized: isInitialized ?? this.isInitialized,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      themeMode: themeMode ?? this.themeMode,
      userId: clearUser ? null : (userId ?? this.userId),
      userEmail: clearUser ? null : (userEmail ?? this.userEmail),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isOffline: isOffline ?? this.isOffline,
      locale: locale ?? this.locale,
    );
  }

  bool get hasError => errorMessage != null;
  bool get hasUser => userId != null && userEmail != null;

  Map<String, dynamic> toJson() {
    return {
      'isInitialized': isInitialized,
      'isAuthenticated': isAuthenticated,
      'themeMode': themeMode.index,
      'userId': userId,
      'userEmail': userEmail,
      'locale': locale,
    };
  }

  factory AppState.fromJson(Map<String, dynamic> json) {
    return AppState(
      isInitialized: json['isInitialized'] as bool? ?? false,
      isAuthenticated: json['isAuthenticated'] as bool? ?? false,
      themeMode: ThemeMode.values[json['themeMode'] as int? ?? 0],
      userId: json['userId'] as String?,
      userEmail: json['userEmail'] as String?,
      locale: json['locale'] as String? ?? 'en',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppState &&
        other.isInitialized == isInitialized &&
        other.isAuthenticated == isAuthenticated &&
        other.themeMode == themeMode &&
        other.userId == userId &&
        other.userEmail == userEmail &&
        other.isLoading == isLoading &&
        other.errorMessage == errorMessage &&
        other.isOffline == isOffline &&
        other.locale == locale;
  }

  @override
  int get hashCode {
    return Object.hash(
      isInitialized,
      isAuthenticated,
      themeMode,
      userId,
      userEmail,
      isLoading,
      errorMessage,
      isOffline,
      locale,
    );
  }
}

/// Notifier class for managing app-wide state
class AppStateNotifier extends StateNotifier<AppState> {
  final AuthService _authService;
  final StorageService _storageService;

  AppStateNotifier({
    required AuthService authService,
    required StorageService storageService,
  })  : _authService = authService,
        _storageService = storageService,
        super(const AppState());

  /// Initialize the application on startup
  Future<void> initializeApp() async {
    if (state.isInitialized) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // Load persisted settings
      await _loadPersistedSettings();

      // Check if user is already authenticated
      final isAuthenticated = await _authService.isAuthenticated();

      if (isAuthenticated) {
        final user = await _authService.getCurrentUser();
        state = state.copyWith(
          isInitialized: true,
          isAuthenticated: true,
          isLoading: false,
          userId: user?.id,
          userEmail: user?.email,
        );
      } else {
        state = state.copyWith(
          isInitialized: true,
          isAuthenticated: false,
          isLoading: false,
          clearUser: true,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isInitialized: true,
        isLoading: false,
        errorMessage: 'Failed to initialize app: ${e.toString()}',
      );
    }
  }

  /// Load persisted settings from secure storage
  Future<void> _loadPersistedSettings() async {
    try {
      final settings = await _storageService.getAppSettings();
      if (settings != null) {
        state = state.copyWith(
          themeMode: ThemeMode.values[settings['themeMode'] as int? ?? 0],
          locale: settings['locale'] as String? ?? 'en',
        );
      }
    } catch (e) {
      // Use default settings on error
      debugPrint('Failed to load persisted settings: $e');
    }
  }

  /// Save current settings to secure storage
  Future<void> _persistSettings() async {
    try {
      await _storageService.saveAppSettings({
        'themeMode': state.themeMode.index,
        'locale': state.locale,
      });
    } catch (e) {
      debugPrint('Failed to persist settings: $e');
    }
  }

  /// Sign in user with email and password
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final user = await _authService.signIn(
        email: email,
        password: password,
      );

      if (user != null) {
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          userId: user.id,
          userEmail: user.email,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Invalid email or password',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _mapAuthError(e.toString()),
      );
      return false;
    }
  }

  /// Sign up new user
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final user = await _authService.signUp(
        email: email,
        password: password,
        name: name,
      );

      if (user != null) {
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          userId: user.id,
          userEmail: user.email,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to create account',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _mapAuthError(e.toString()),
      );
      return false;
    }
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final user = await _authService.signInWithGoogle();

      if (user != null) {
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          userId: user.id,
          userEmail: user.email,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Google sign in failed',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _mapAuthError(e.toString()),
      );
      return false;
    }
  }

  /// Sign in with Apple
  Future<bool> signInWithApple() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final user = await _authService.signInWithApple();

      if (user != null) {
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          userId: user.id,
          userEmail: user.email,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Apple sign in failed',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _mapAuthError(e.toString()),
      );
      return false;
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _authService.signOut();
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        clearUser: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to sign out: ${e.toString()}',
      );
    }
  }

  /// Send password reset email
  Future<bool> sendPasswordReset(String email) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _authService.sendPasswordReset(email);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _mapAuthError(e.toString()),
      );
      return false;
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? name,
    String? email,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final updatedUser = await _authService.updateProfile(
        name: name,
        email: email,
      );

      if (updatedUser != null) {
        state = state.copyWith(
          isLoading: false,
          userEmail: updatedUser.email,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to update profile',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _mapAuthError(e.toString()),
      );
      return false;
    }
  }

  /// Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _mapAuthError(e.toString()),
      );
      return false;
    }
  }

  /// Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _persistSettings();
  }

  /// Toggle between light and dark theme
  Future<void> toggleTheme() async {
    final newMode = state.themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    await setThemeMode(newMode);
  }

  /// Set locale
  Future<void> setLocale(String locale) async {
    if (AppConstants.supportedLocales.contains(locale)) {
      state = state.copyWith(locale: locale);
      await _persistSettings();
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Set offline mode
  void setOfflineMode(bool isOffline) {
    state = state.copyWith(isOffline: isOffline);
  }

  /// Map authentication error codes to user-friendly messages
  String _mapAuthError(String error) {
    final lowerError = error.toLowerCase();

    if (lowerError.contains('invalid-email') ||
        lowerError.contains('invalid email')) {
      return 'Please enter a valid email address';
    } else if (lowerError.contains('weak-password') ||
        lowerError.contains('weak password')) {
      return 'Password should be at least 8 characters';
    } else if (lowerError.contains('email-already-in-use') ||
        lowerError.contains('already in use')) {
      return 'An account with this email already exists';
    } else if (lowerError.contains('user-not-found') ||
        lowerError.contains('no user record')) {
      return 'No account found with this email';
    } else if (lowerError.contains('wrong-password') ||
        lowerError.contains('wrong password') ||
        lowerError.contains('invalid-credential')) {
      return 'Incorrect password. Please try again';
    } else if (lowerError.contains('user-disabled')) {
      return 'This account has been disabled';
    } else if (lowerError.contains('too-many-requests')) {
      return 'Too many attempts. Please try again later';
    } else if (lowerError.contains('network')) {
      return 'Network error. Please check your connection';
    } else if (lowerError.contains('operation-not-allowed')) {
      return 'This sign in method is not enabled';
    } else if (lowerError.contains('cancelled') ||
        lowerError.contains('abort')) {
      return 'Sign in was cancelled';
    }

    return 'An error occurred. Please try again';
  }
}

/// Provider for the app state notifier
final appStateProvider =
    StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  return AppStateNotifier(
    authService: ref.watch(authServiceProvider),
    storageService: ref.watch(storageServiceProvider),
  );
});

/// Provider for authentication state only
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(appStateProvider).isAuthenticated;
});

/// Provider for app initialization state
final isAppInitializedProvider = Provider<bool>((ref) {
  return ref.watch(appStateProvider).isInitialized;
});

/// Provider for current theme mode
final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(appStateProvider).themeMode;
});

/// Provider for current locale
final localeProvider = Provider<String>((ref) {
  return ref.watch(appStateProvider).locale;
});

/// Provider for global loading state
final isGlobalLoadingProvider = Provider<bool>((ref) {
  return ref.watch(appStateProvider).isLoading;
});

/// Provider for current user ID
final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(appStateProvider).userId;
});

/// Provider for current user email
final currentUserEmailProvider = Provider<String?>((ref) {
  return ref.watch(appStateProvider).userEmail;
});

/// Provider for offline mode state
final isOfflineProvider = Provider<bool>((ref) {
  return ref.watch(appStateProvider).isOffline;
});

/// Provider for error message
final errorMessageProvider = Provider<String?>((ref) {
  return ref.watch(appStateProvider).errorMessage;
});

/// Dependency providers for services
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

/// A future provider that waits for app initialization
final appInitializationProvider = FutureProvider<void>((ref) async {
  final notifier = ref.read(appStateProvider.notifier);
  await notifier.initializeApp();
});
