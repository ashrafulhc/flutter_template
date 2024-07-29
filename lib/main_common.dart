import 'package:flutter/material.dart';
import 'package:flutter_template/presentation/app/app.dart';
import 'package:flutter_template/presentation/app/app_flavor.dart';
import 'package:flutter_template/injection/dependencies.dart';

void mainCommon(AppFlavor flavor) async {
  await DependencyManager.inject(flavor);
  // Bloc Observer needs to be added here
  runApp(const App());
}
