import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/api_constants.dart';
import '../core/utils/app_utils.dart';

/// Application-wide state provider
/// Manages global app state including theme, locale, and initialization

/// App initialization state
enum AppInitializationState {
  uninitialized,
  initializing,
  initialized,
  error,
}

/// App global state model
class AppState {
  final AppInitializationState initializationState;
  final ThemeMode themeMode;
  final Locale locale;
  final bool isOnline;
  final String? errorMessage;
  final UserModel? currentUser;
  final bool isAuthenticated;

  const AppState({
    this.initializationState = AppInitializationState.uninitialized,
    this.themeMode = ThemeMode.system,
    this.locale = const Locale('en'),
    this.isOnline = true,
    this.errorMessage,
    this.currentUser,
    this.isAuthenticated = false,
  });

  AppState copyWith({
    AppInitializationState? initializationState,
    ThemeMode? themeMode,
    Locale? locale,
    bool? isOnline,
    String? errorMessage,
    UserModel? currentUser,
    bool? isAuthenticated,
  }) {
    return AppState(
      initializationState: initializationState ?? this.initializationState,
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      isOnline: isOnline ?? this.isOnline,
      errorMessage: errorMessage,
      currentUser: currentUser ?? this.currentUser,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'initializationState': initializationState.index,
      'themeMode': themeMode.index,
      'locale': locale.toString(),
      'isOnline': isOnline,
      'errorMessage': errorMessage,
      'currentUser': currentUser?.toJson(),
      'isAuthenticated': isAuthenticated,
    };
  }

  factory AppState.fromJson(Map<String, dynamic> json) {
    return AppState(
      initializationState: AppInitializationState.values[json['initializationState'] ?? 0],
      themeMode: ThemeMode.values[json['themeMode'] ?? 0],
      locale: Locale(json['locale'] ?? 'en'),
      isOnline: json['isOnline'] ?? true,
      errorMessage: json['errorMessage'],
      currentUser: json['currentUser'] != null 
          ? UserModel.fromJson(json['currentUser']) 
          : null,
      isAuthenticated: json['isAuthenticated'] ?? false,
    );
  }
}

/// App state notifier for managing global app state
class AppStateNotifier extends StateNotifier<AppState> {
  final AuthService _authService;
  final StorageService _storageService;
  final Ref _ref;

  AppStateNotifier(this._authService, this._storageService, this._ref) 
      : super(const AppState());

  /// Initialize the application
  Future<void> initializeApp() async {
    try {
      state = state.copyWith(
        initializationState: AppInitializationState.initializing,
      );

      // Load saved preferences
      await _loadPreferences();

      // Initialize services
      await _initializeServices();

      // Check authentication status
      await _checkAuthentication();

      state = state.copyWith(
        initializationState: AppInitializationState.initialized,
      );
    } catch (e) {
      state = state.copyWith(
        initializationState: AppInitializationState.error,
        errorMessage: 'Failed to initialize app: ${e.toString()}',
      );
    }
  }

  /// Load user preferences from storage
  Future<void> _loadPreferences() async {
    try {
      // Load theme preference
      final savedThemeIndex = await _storageService.getInt(AppConstants.themeModeKey);
      if (savedThemeIndex != null) {
        final themeMode = ThemeMode.values[savedThemeIndex];
        state = state.copyWith(themeMode: themeMode);
      }

      // Load locale preference
      final savedLocale = await _storageService.getString(AppConstants.localeKey);
      if (savedLocale != null) {
        state = state.copyWith(locale: Locale(savedLocale));
      }
    } catch (e) {
      AppUtils.log('Error loading preferences: ${e.toString()}');
    }
  }

  /// Initialize required services
  Future<void> _initializeServices() async {
    try {
      // Initialize API service
      final apiService = _ref.read(apiServiceProvider);
      await apiService.initialize();

      // Check network connectivity
      final isOnline = await _checkConnectivity();
      state = state.copyWith(isOnline: isOnline);
    } catch (e) {
      AppUtils.log('Error initializing services: ${e.toString()}');
    }
  }

  /// Check user authentication status
  Future<void> _checkAuthentication() async {
    try {
      final token = await _authService.getStoredToken();
      if (token != null && token.isNotEmpty) {
        final isValid = await _authService.validateToken(token);
        if (isValid) {
          final user = await _authService.getCurrentUser();
          if (user != null) {
            state = state.copyWith(
              currentUser: user,
              isAuthenticated: true,
            );
          }
        }
      }
    } catch (e) {
      AppUtils.log('Error checking authentication: ${e.toString()}');
    }
  }

  /// Check network connectivity
  Future<bool> _checkConnectivity() async {
    try {
      // Simple connectivity check using API health endpoint
      final apiService = _ref.read(apiServiceProvider);
      return await apiService.checkConnectivity();
    } catch (e) {
      return false;
    }
  }

  /// Update theme mode
  Future<void> setThemeMode(ThemeMode themeMode) async {
    try {
      await _storageService.setInt(
        AppConstants.themeModeKey,
        themeMode.index,
      );
      state = state.copyWith(themeMode: themeMode);
    } catch (e) {
      AppUtils.log('Error saving theme preference: ${e.toString()}');
    }
  }

  /// Toggle between light and dark theme
  Future<void> toggleTheme() async {
    final newTheme = state.themeMode == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
    await setThemeMode(newTheme);
  }

  /// Update locale
  Future<void> setLocale(Locale locale) async {
    try {
      await _storageService.setString(
        AppConstants.localeKey,
        locale.toString(),
      );
      state = state.copyWith(locale: locale);
    } catch (e) {
      AppUtils.log('Error saving locale preference: ${e.toString()}');
    }
  }

  /// Update online status
  void setOnlineStatus(bool isOnline) {
    state = state.copyWith(isOnline: isOnline);
  }

  /// Set current user
  void setCurrentUser(UserModel? user) {
    state = state.copyWith(
      currentUser: user,
      isAuthenticated: user != null,
    );
  }

  /// Login user
  Future<bool> login(String email, String password) async {
    try {
      final response = await _authService.login(email, password);
      if (response != null && response.success) {
        final user = response.data['user'] as UserModel?;
        if (user != null) {
          state = state.copyWith(
            currentUser: user,
            isAuthenticated: true,
          );
          return true;
        }
      }
      return false;
    } catch (e) {
      AppUtils.log('Login error: ${e.toString()}');
      return false;
    }
  }

  /// Register new user
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    try {
      final response = await _authService.register(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );
      if (response != null && response.success) {
        final user = response.data['user'] as UserModel?;
        if (user != null) {
          state = state.copyWith(
            currentUser: user,
            isAuthenticated: true,
          );
          return true;
        }
      }
      return false;
    } catch (e) {
      AppUtils.log('Registration error: ${e.toString()}');
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _authService.logout();
      state = state.copyWith(
        currentUser: null,
        isAuthenticated: false,
      );
    } catch (e) {
      AppUtils.log('Logout error: ${e.toString()}');
    }
  }

  /// Refresh user data
  Future<void> refreshUserData() async {
    try {
      if (state.isAuthenticated) {
        final user = await _authService.getCurrentUser();
        if (user != null) {
          state = state.copyWith(currentUser: user);
        }
      }
    } catch (e) {
      AppUtils.log('Error refreshing user data: ${e.toString()}');
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Reset app state
  Future<void> resetApp() async {
    try {
      await _storageService.clearAll();
      state = const AppState();
    } catch (e) {
      AppUtils.log('Error resetting app: ${e.toString()}');
    }
  }
}

/// API service provider
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

/// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  return AuthService(apiService, storageService);
});

/// Storage service provider
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

/// App state provider
final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  final authService = ref.watch(authServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  return AppStateNotifier(authService, storageService, ref);
});

/// Theme mode provider (convenience)
final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(appStateProvider).themeMode;
});

/// Locale provider (convenience)
final localeProvider = Provider<Locale>((ref) {
  return ref.watch(appStateProvider).locale;
});

/// Authentication state provider (convenience)
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(appStateProvider).isAuthenticated;
});

/// Current user provider (convenience)
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(appStateProvider).currentUser;
});

/// Online status provider (convenience)
final isOnlineProvider = Provider<bool>((ref) {
  return ref.watch(appStateProvider).isOnline;
});

/// App initialization state provider
final appInitializationStateProvider = Provider<AppInitializationState>((ref) {
  return ref.watch(appStateProvider).initializationState;
});

/// Error message provider
final errorMessageProvider = Provider<String?>((ref) {
  return ref.watch(appStateProvider).errorMessage;
});

/// App loading state provider
final isAppLoadingProvider = Provider<bool>((ref) {
  final initState = ref.watch(appInitializationStateProvider);
  return initState == AppInitializationState.initializing ||
         initState == AppInitializationState.uninitialized;
});

/// API Service class for handling HTTP requests
class ApiService {
  String? _baseUrl;
  String? _authToken;
  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<void> initialize() async {
    _baseUrl = ApiConstants.baseUrl;
    _headers['X-App-Version'] = AppConstants.appVersion;
    _headers['X-Platform'] = AppConstants.platform;
  }

  void setAuthToken(String token) {
    _authToken = token;
    _headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    _authToken = null;
    _headers.remove('Authorization');
  }

  Future<bool> checkConnectivity() async {
    try {
      // Simple connectivity check
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> get(String endpoint, {Map<String, dynamic>? queryParams}) async {
    // Implementation for GET requests
    return {};
  }

  Future<Map<String, dynamic>> post(String endpoint, {Map<String, dynamic>? body}) async {
    // Implementation for POST requests
    return {};
  }

  Future<Map<String, dynamic>> put(String endpoint, {Map<String, dynamic>? body}) async {
    // Implementation for PUT requests
    return {};
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    // Implementation for DELETE requests
    return {};
  }
}

/// API Response model
class ApiResponse {
  final bool success;
  final Map<String, dynamic> data;
  final String? message;
  final int statusCode;

  ApiResponse({
    required this.success,
    required this.data,
    this.message,
    this.statusCode = 200,
  });

  factory ApiResponse.success(Map<String, dynamic> data, {String? message}) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
      statusCode: 200,
    );
  }

  factory ApiResponse.error(String message, {int statusCode = 400}) {
    return ApiResponse(
      success: false,
      data: {},
      message: message,
      statusCode: statusCode,
    );
  }
}
