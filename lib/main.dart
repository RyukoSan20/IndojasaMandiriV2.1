import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:fintrack/config/app_config.dart';
import 'package:fintrack/config/theme_config.dart';
import 'package:fintrack/core/router/app_router.dart';
import 'package:fintrack/core/services/analytics_service.dart';
import 'package:fintrack/core/services/auth_service.dart';
import 'package:fintrack/core/services/connectivity_service.dart';
import 'package:fintrack/core/services/storage_service.dart';
import 'package:fintrack/core/services/error_handler_service.dart';
import 'package:fintrack/core/utils/app_utils.dart';
import 'package:fintrack/l10n/app_localizations.dart';
import 'package:fintrack/presentation/providers/app_settings_provider.dart';
import 'package:fintrack/presentation/providers/auth_provider.dart';
import 'package:fintrack/presentation/providers/portfolio_provider.dart';
import 'package:fintrack/presentation/providers/transaction_provider.dart';
import 'package:fintrack/presentation/providers/account_provider.dart';
import 'package:fintrack/presentation/providers/savings_goal_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await _initializeApp();
  _setPreferredOrientations();
  _setSystemUIOverlayStyle();
  
  runApp(const FinTrackApp());
}

Future<void> _initializeApp() async {
  await StorageService.instance.init();
  await AppConfig.load();
  
  final analyticsService = AnalyticsService.instance;
  await analyticsService.init();
  
  final connectivityService = ConnectivityService.instance;
  await connectivityService.init();
}

void _setPreferredOrientations() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

void _setSystemUIOverlayStyle() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
}

class FinTrackApp extends StatefulWidget {
  const FinTrackApp({super.key});

  @override
  State<FinTrackApp> createState() => _FinTrackAppState();
}

class _FinTrackAppState extends State<FinTrackApp> with WidgetsBindingObserver, AppLifecycleObserver {
  late final ErrorHandlerService _errorHandler;
  late final AppRouter _appRouter;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    _errorHandler = ErrorHandlerService.instance;
    _appRouter = AppRouter();
    
    final authService = AuthService.instance;
    await authService.init();
    
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _handleLifecycleState(state);
  }

  void _handleLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _onAppResumed();
        break;
      case AppLifecycleState.paused:
        _onAppPaused();
        break;
      case AppLifecycleState.inactive:
        _onAppInactive();
        break;
      case AppLifecycleState.detached:
        _onAppDetached();
        break;
      case AppLifecycleState.hidden:
        _onAppHidden();
        break;
    }
  }

  void _onAppResumed() {
    AppUtils.log('App resumed');
    ConnectivityService.instance.startMonitoring();
  }

  void _onAppPaused() {
    AppUtils.log('App paused');
    StorageService.instance.savePendingData();
  }

  void _onAppInactive() {
    AppUtils.log('App inactive');
  }

  void _onAppDetached() {
    AppUtils.log('App detached');
    StorageService.instance.savePendingData();
  }

  void _onAppHidden() {
    AppUtils.log('App hidden');
    StorageService.instance.savePendingData();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const _SplashScreen(),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppSettingsProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AccountProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => TransactionProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SavingsGoalProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => PortfolioProvider(),
        ),
      ],
      child: Consumer<AppSettingsProvider>(
        builder: (context, settingsProvider, _) {
          return MaterialApp.router(
            title: AppConfig.appName,
            debugShowCheckedModeBanner: AppConfig.debugMode,
            theme: ThemeConfig.lightTheme,
            darkTheme: ThemeConfig.darkTheme,
            themeMode: settingsProvider.themeMode,
            locale: settingsProvider.locale,
            supportedLocales: AppConfig.supportedLocales,
            localizationsDelegates: _localizationDelegates,
            routerConfig: _appRouter.router,
            builder: _appBuilder,
          );
        },
      ),
    );
  }

  List<LocalizationsDelegate<dynamic>> get _localizationDelegates => [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  Widget _appBuilder(BuildContext context, Widget? child) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(
          MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.3),
        ),
      ),
      child: child ?? const SizedBox.shrink(),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.lightTheme.colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  size: 60,
                  color: Color(0xFF1E3A5F),
                ),
              ),
            ),
            const SizedBox(height: 24),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: child,
                );
              },
              child: const Text(
                'FinTrack',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your Financial Companion',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 48),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
