import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_template/injection/injector.dart';
import 'package:flutter_template/presentation/routes/router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = injector.get<AppRouter>();

    return MaterialApp.router(
      title: 'Flutter Template',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      routerDelegate: AutoRouterDelegate(
        appRouter,
      ),
      routeInformationParser: appRouter.defaultRouteParser(),
    );
  }
}
