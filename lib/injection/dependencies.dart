import 'package:flutter_template/presentation/app/app_flavor.dart';
import 'package:flutter_template/injection/injector.dart';

class DependencyManager {
  static Future<void> inject(AppFlavor flavor) async {
    injector.registerLazySingleton<AppFlavor>(() => flavor);

    await configureDependencies();
  }
}
