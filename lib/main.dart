import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fintrack/core/constants/app_constants.dart';
import 'package:fintrack/core/theme/app_theme.dart';
import 'package:fintrack/core/router/app_router.dart';
import 'package:fintrack/core/services/service_locator.dart';
import 'package:fintrack/features/auth/presentation/providers/auth_provider.dart';
import 'package:fintrack/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:fintrack/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:fintrack/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:fintrack/features/budgets/presentation/providers/budgets_provider.dart';
import 'package:fintrack/features/savings/presentation/providers/savings_provider.dart';
import 'package:fintrack/features/stocks/presentation/providers/stocks_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
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

  await setupServiceLocator();

  runApp(const FinTrackApp());
}

class FinTrackApp extends StatelessWidget {
  const FinTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => getIt<AuthProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<DashboardProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<AccountsProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<TransactionsProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<BudgetsProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<SavingsProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<StocksProvider>()),
      ],
      child: MaterialApp.router(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
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
