import 'package:dio/dio.dart';
import 'package:flutter_template/data/api/api_config.dart';
import 'package:injectable/injectable.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

// For network call
const dioClient = 'DIOCLIENT';

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
abstract class NetworkModule {
  @singleton
  @Named(dioClient)
  Dio getForAuthenticationDio(ApiConfig apiConfig) {
    final dio = _createBaseDio(apiConfig)
      ..interceptors.addAll(
        [
          logger,
        ],
      );
    return dio;
  }
}
