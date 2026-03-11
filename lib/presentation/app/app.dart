import 'package:flutter/material.dart';
import 'package:flutter_template/presentation/resources/resources.dart';
import 'package:flutter_template/presentation/routes/app_router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.fromBrightness(Brightness.light),
      darkTheme: AppTheme.fromBrightness(Brightness.dark),
      // TODO: Set to [ThemeMode.light] if your app only supports light mode
      themeMode: ThemeMode.system,
      title: 'Flutter Template',
      routerConfig: appRouter,
    );
  }
}
