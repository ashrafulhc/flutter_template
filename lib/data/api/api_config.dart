import 'package:flutter_template/presentation/app/app_flavor.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ApiConfig {
  final AppFlavor flavor;

  ApiConfig(this.flavor);

  String get baseUrl => switch (flavor) {
        AppFlavor.development => 'https://jsonplaceholder.typicode.com',
        AppFlavor.staging => 'https://jsonplaceholder.typicode.com',
        AppFlavor.production => 'https://jsonplaceholder.typicode.com',
      };
}
