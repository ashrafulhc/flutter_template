import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_template/injection/injector.dart';
import 'package:flutter_template/presentation/app/auth_event_bus.dart';
import 'package:flutter_template/presentation/resources/resources.dart';
import 'package:flutter_template/presentation/routes/app_router.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final StreamSubscription<AuthEvent> _authSubscription;

  @override
  void initState() {
    super.initState();
    _authSubscription =
        injector<AuthEventBus>().stream.listen(_onAuthEvent);
  }

  void _onAuthEvent(AuthEvent event) {
    switch (event) {
      case AuthEvent.sessionExpired:
        appRouter.go(AppRoutes.login);
        // Show snackbar after the navigation frame settles.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final context = appRouter.routerDelegate.navigatorKey.currentContext;
          if (context != null && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Your session has expired. Please log in again.',
                ),
              ),
            );
          }
        });
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

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
