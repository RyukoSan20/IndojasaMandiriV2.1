// ignore_for_file: prefer_const_constructors, unused_import
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return MaterialApp(
          title: 'FinTrack',
          themeMode: settingsProvider.themeMode,
          theme: ThemeData(primarySwatch: Colors.blue, brightness: Brightness.light),
          darkTheme: ThemeData(brightness: Brightness.dark),
          locale: Locale(settingsProvider.languageCode),
          home: const DashboardScreen(),
          routes: {
            '/settings': (context) => const SettingsScreen(),
          },
        );
      },
    );
  }
}
