import 'package:dio/dio.dart';
import 'package:flutter_template/data/response_objects/auth_response/auth_response.dart';
import 'package:flutter_template/data/services/auth/source/local/token_local_data_source.dart';
import 'package:flutter_template/presentation/app/auth_event_bus.dart';

/// Intercepts every request to attach the Bearer token, and handles 401
/// responses by attempting a silent token refresh.
///
/// If the refresh succeeds the original request is retried transparently.
/// If the refresh fails (expired / invalid refresh token) all stored tokens
/// are cleared and [AuthEventBus.dispatchSessionExpired] is called so the
/// presentation layer can navigate the user back to login.
///
/// This class is intentionally NOT annotated with @injectable — it is
/// constructed manually inside [NetworkModule] so that the correct
/// [refreshDio] (a bare Dio with no interceptors) can be injected,
/// preventing infinite 401 retry loops.
class AuthInterceptor extends Interceptor {
  final TokenLocalDataSource _tokenLocalDataSource;

  /// A bare [Dio] instance with **no interceptors**. Used exclusively for
  /// the token-refresh call so that a 401 on the refresh endpoint does not
  /// trigger another refresh attempt.
  final Dio _refreshDio;

  final AuthEventBus _authEventBus;

  AuthInterceptor({
    required TokenLocalDataSource tokenLocalDataSource,
    required Dio refreshDio,
    required AuthEventBus authEventBus,
  })  : _tokenLocalDataSource = tokenLocalDataSource,
        _refreshDio = refreshDio,
        _authEventBus = authEventBus;

  /// Attaches the stored access token as a Bearer header before every request.
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenLocalDataSource.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  /// Intercepts 401 responses and attempts a silent token refresh.
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    try {
      final newTokens = await _tryRefresh();

      // Retry the original request with the new access token.
      final retryOptions = err.requestOptions;
      retryOptions.headers['Authorization'] =
          'Bearer ${newTokens.accessToken}';
      final retryResponse = await _refreshDio.fetch<dynamic>(retryOptions);
      handler.resolve(retryResponse);
    } catch (_) {
      // Refresh failed — clear credentials and force re-login.
      await _tokenLocalDataSource.clearTokens();
      _authEventBus.dispatchSessionExpired();
      handler.next(err);
    }
  }

  /// Calls the refresh endpoint via [_refreshDio] and persists the new tokens.
  Future<AuthResponse> _tryRefresh() async {
    final refreshToken = await _tokenLocalDataSource.getRefreshToken();
    if (refreshToken == null) {
      throw Exception('No refresh token stored');
    }

    final response = await _refreshDio.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: {'refresh_token': refreshToken},
    );

    final newTokens = AuthResponse.fromJson(response.data!);

    await _tokenLocalDataSource.saveTokens(
      accessToken: newTokens.accessToken,
      refreshToken: newTokens.refreshToken,
      expiresAt: DateTime.parse(newTokens.expiresAt),
    );

    return newTokens;
  }
}
