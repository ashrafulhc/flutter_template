import 'package:go_router/go_router.dart';
import 'package:flutter_template/presentation/features/_playground/playground_screen.dart';
import 'package:flutter_template/presentation/features/home/home_page.dart';
import 'package:flutter_template/presentation/features/main/main_screen.dart';
import 'package:flutter_template/presentation/features/settings/settings_page.dart';
import 'package:flutter_template/presentation/features/splash/splash_screen.dart';

abstract class AppRoutes {
  static const splash = '/';
  static const main = '/main';
  static const home = 'home';
  static const settings = 'settings';
  static const playground = '/playground';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => MainScreen(body: child),
      routes: [
        GoRoute(
          path: '${AppRoutes.main}/${AppRoutes.home}',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '${AppRoutes.main}/${AppRoutes.settings}',
          builder: (context, state) => const SettingsPage(),
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.playground,
      builder: (context, state) => const PlaygroundScreen(),
    ),
  ],
);
