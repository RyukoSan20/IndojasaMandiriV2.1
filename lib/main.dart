import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_constants.dart';
import 'core/constants/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/router/route_names.dart';
import 'core/services/service_locator.dart';
import 'core/services/secure_storage_service.dart';
import 'core/services/api_service.dart';
import 'core/services/auth_service.dart';
import 'core/utils/validators.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/dashboard/presentation/providers/dashboard_provider.dart';
import 'features/transactions/presentation/providers/transaction_provider.dart';
import 'features/accounts/presentation/providers/account_provider.dart';
import 'features/goals/presentation/providers/goal_provider.dart';
import 'features/portfolio/presentation/providers/portfolio_provider.dart';
import 'features/settings/presentation/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  await ServiceLocator.init();

  runApp(const FinTrackApp());
}

class FinTrackApp extends StatelessWidget {
  const FinTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            authService: ServiceLocator.get<AuthService>(),
            secureStorage: ServiceLocator.get<SecureStorageService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => DashboardProvider(
            apiService: ServiceLocator.get<ApiService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => TransactionProvider(
            apiService: ServiceLocator.get<ApiService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AccountProvider(
            apiService: ServiceLocator.get<ApiService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => GoalProvider(
            apiService: ServiceLocator.get<ApiService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => PortfolioProvider(
            apiService: ServiceLocator.get<ApiService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(
            secureStorage: ServiceLocator.get<SecureStorageService>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: RouteNames.splash,
        onGenerateRoute: AppRouter.generateRoute,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.noScaling,
            ),
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
