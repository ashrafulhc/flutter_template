import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_template/injection/dependencies.dart';
import 'package:flutter_template/presentation/app/app.dart';
import 'package:flutter_template/presentation/app/app_flavor.dart';

Future<void> mainCommon(AppFlavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    // TODO: Log to crash reporting service (e.g., Firebase Crashlytics)
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    // TODO: Log to crash reporting service
    return false;
  };

  await DependencyManager.inject(flavor);
  // Bloc Observer needs to be added here
  runApp(const App());
}
