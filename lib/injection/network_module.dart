import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_template/data/api/api_config.dart';
import 'package:flutter_template/data/interceptors/auth_interceptor.dart';
import 'package:flutter_template/data/services/auth/source/local/token_local_data_source.dart';
import 'package:flutter_template/presentation/app/auth_event_bus.dart';
import 'package:injectable/injectable.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

/// Named constant for the main authenticated Dio client.
const dioClient = 'DIOCLIENT';

/// Named constant for the bare refresh-only Dio client (no interceptors).
/// Used exclusively by [AuthInterceptor] to call the token-refresh endpoint,
/// preventing an infinite 401 retry loop.
const dioRefreshClient = 'DIOCLIENT_REFRESH';

Dio _createBaseDio(ApiConfig apiConfig) {
  final dio = Dio()
    ..httpClientAdapter = HttpClientAdapter()
    ..options.baseUrl = apiConfig.baseUrl
    ..options.contentType = 'application/json';

  return dio;
}

final logger = PrettyDioLogger(
  requestHeader: true,
  requestBody: true,
);

@module
abstract class StorageModule {
  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();
}

@module
abstract class NetworkModule {
  /// Bare Dio used only for silent token refresh inside [AuthInterceptor].
  /// Must have no interceptors to avoid infinite retry loops.
  @singleton
  @Named(dioRefreshClient)
  Dio getRefreshDio(ApiConfig apiConfig) => _createBaseDio(apiConfig);

  /// Main authenticated Dio client. Includes [AuthInterceptor] which attaches
  /// the Bearer token to every request and handles 401 responses.
  @singleton
  @Named(dioClient)
  Dio getForAuthenticationDio(
    ApiConfig apiConfig,
    TokenLocalDataSource tokenLocalDataSource,
    AuthEventBus authEventBus,
    @Named(dioRefreshClient) Dio refreshDio,
  ) {
    final authInterceptor = AuthInterceptor(
      tokenLocalDataSource: tokenLocalDataSource,
      refreshDio: refreshDio,
      authEventBus: authEventBus,
    );

    return _createBaseDio(apiConfig)
      ..interceptors.addAll([authInterceptor, logger]);
  }
}
