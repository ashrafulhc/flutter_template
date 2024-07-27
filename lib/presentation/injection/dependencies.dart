import 'package:flutter_template/presentation/app/app_flavor.dart';
import 'package:flutter_template/presentation/injection/injector.dart';
import 'package:flutter_template/presentation/routes/router.dart';

class DependencyManager {
  static Future<void> inject(AppFlavor flavor) async {
    injector.registerLazySingleton<AppFlavor>(() => flavor);
    injector.registerLazySingleton<AppRouter>(() => AppRouter());

    await configureDependencies();
  }
}
