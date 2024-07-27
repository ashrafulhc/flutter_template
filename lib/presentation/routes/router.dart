import 'package:auto_route/auto_route.dart';
import 'package:flutter_template/presentation/features/splash/splash_screen.dart';

part 'router.gr.dart';

@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          page: SplashRoute.page,
          path: '/',
        ),
      ];
}
