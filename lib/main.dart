import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fintrack/core/constants/app_constants.dart';
import 'package:fintrack/core/theme/app_theme.dart';
import 'package:fintrack/core/router/app_router.dart';
import 'package:fintrack/core/services/service_locator.dart';
import 'package:fintrack/core/services/analytics_service.dart';
import 'package:fintrack/core/services/crash_reporting_service.dart';
import 'package:fintrack/core/utils/permission_utils.dart';
import 'package:fintrack/presentation/providers/auth_provider.dart';
import 'package:fintrack/presentation/providers/theme_provider.dart';
import 'package:fintrack/presentation/providers/connectivity_provider.dart';
import 'package:fintrack/presentation/widgets/common/app_splash_screen.dart';
import 'package:fintrack/presentation/widgets/common/app_network_error.dart';
import 'package:fintrack/presentation/widgets/common/app_maintenance_mode.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initializeServices();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    ProviderScope(
      child: const FinTrackApp(),
    ),
  );
}

Future<void> _initializeServices() async {
  await serviceLocatorInit();
  await getIt<CrashReportingService>().initialize();
  await getIt<AnalyticsService>().initialize();
  await PermissionUtils.requestNotificationPermission();
}

class FinTrackApp extends ConsumerStatefulWidget {
  const FinTrackApp({super.key});

  @override
  ConsumerState<FinTrackApp> createState() => _FinTrackAppState();
}

class _FinTrackAppState extends ConsumerState<FinTrackApp> with WidgetsBindingObserver {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _appRouter = AppRouter(ref: ref);
    _checkMaintenanceMode();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _handleAppLifecycleState(state);
  }

  void _handleAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        getIt<AnalyticsService>().logAppResume();
        ref.read(connectivityProvider.notifier).checkConnectivity();
        break;
      case AppLifecycleState.paused:
        getIt<AnalyticsService>().logAppPause();
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  Future<void> _checkMaintenanceMode() async {
    // Maintenance mode check can be implemented here
    // await ref.read(maintenanceProvider).checkMaintenanceStatus();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isOnline = ref.watch(connectivityProvider).isOnline;
    final isMaintenanceMode = false; // Replace with actual maintenance mode check

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: _appRouter.router,
      builder: (context, child) {
        return ErrorBoundary(
          child: _buildAppContent(child, isOnline, isMaintenanceMode),
        );
      },
      localizationsDelegates: const [
        // Add localization delegates if using internationalization
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('en', 'GB'),
        // Add more supported locales as needed
      ],
    );
  }

  Widget _buildAppContent(Widget? child, bool isOnline, bool isMaintenanceMode) {
    if (isMaintenanceMode) {
      return const AppMaintenanceMode();
    }

    if (!isOnline) {
      return AppNetworkError(
        onRetry: () {
          ref.read(connectivityProvider.notifier).checkConnectivity();
        },
      );
    }

    return child ?? const AppSplashScreen();
  }
}

class ErrorBoundary extends StatefulWidget {
  final Widget child;

  const ErrorBoundary({super.key, required this.child});

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  final GlobalKey _errorKey = GlobalKey<ErrorWidget>();

  @override
  Widget build(BuildContext context) {
    return ErrorWidgetBuilder(
      key: _errorKey,
      child: widget.child,
    );
  }
}

class ErrorWidgetBuilder extends ConsumerWidget {
  final Widget child;

  const ErrorWidgetBuilder({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return child;
  }
}

class FinTrackAppRunConfig {
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  static const bool enableLogging = bool.fromEnvironment(
    'ENABLE_LOGGING',
    defaultValue: true,
  );

  static const bool enableAnalytics = bool.fromEnvironment(
    'ENABLE_ANALYTICS',
    defaultValue: true,
  );

  static const bool enableCrashReporting = bool.fromEnvironment(
    'ENABLE_CRASH_REPORTING',
    defaultValue: true,
  );

  static bool get isDevelopment => environment == 'development';
  static bool get isProduction => environment == 'production';
  static bool get isStaging => environment == 'staging';
}
