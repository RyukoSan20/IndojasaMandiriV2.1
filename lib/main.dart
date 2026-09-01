import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'app/app.dart';
import 'app/core/config/environment.dart';
import 'app/core/di/injection_container.dart';
import 'app/core/error/app_exception_handler.dart';
import 'app/core/utils/logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initializeApp();

  runApp(const FinTrackApp());
}

Future<void> _initializeApp() async {
  final stopwatch = Stopwatch()..start();

  try {
    await _configureSystemUI();
    await _initializeDependencies();
    await _loadAppConfiguration();
    await _initializeAnalytics();

    stopwatch.stop();
    logger.info('App initialization completed in ${stopwatch.elapsedMilliseconds}ms');
  } catch (error, stackTrace) {
    stopwatch.stop();
    logger.error(
      'Critical initialization error: $error',
      error: error,
      stackTrace: stackTrace,
    );
    await AppExceptionHandler.handleFatalError(error, stackTrace);
  }
}

Future<void> _configureSystemUI() async {
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

  if (kIsWeb) {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );
  }
}

Future<void> _initializeDependencies() async {
  await InjectionContainer.init();
}

Future<void> _loadAppConfiguration() async {
  await Environment.initialize();
}

Future<void> _initializeAnalytics() async {
  if (!kReleaseMode) {
    logger.debug('Analytics disabled in debug mode');
    return;
  }
  logger.info('Analytics initialized');
}
