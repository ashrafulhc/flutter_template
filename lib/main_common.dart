import 'package:flutter/material.dart';
import 'package:flutter_template/presentation/app/app.dart';
import 'package:flutter_template/presentation/app/app_flavor.dart';

void mainCommon(AppFlavor flavor) {
  // Todo: Dependency Injection
  // Bloc Observer
  runApp(const App());
}
