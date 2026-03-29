import 'package:flutter_template/data/remappers/auth_remapper.dart';
import 'package:flutter_template/data/request_objects/login_request/login_request.dart';
import 'package:flutter_template/data/request_objects/register_request/register_request.dart';
import 'package:flutter_template/data/mappers/response_error_mapper.dart';
import 'package:flutter_template/data/services/auth/source/local/token_local_data_source.dart';
import 'package:flutter_template/data/services/auth/source/remote/auth_remote_data_source.dart';
import 'package:flutter_template/domain/entities/auth/auth_entity.dart';
import 'package:flutter_template/domain/repositories/auth/auth_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final TokenLocalDataSource _tokenLocalDataSource;
  final AuthRemapper _remapper;

  AuthRepositoryImpl(
    this._remoteDataSource,
    this._tokenLocalDataSource,
    this._remapper,
  );

  @override
  Future<AuthEntity> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _remoteDataSource.login(
        LoginRequest(email: email, password: password),
      );
      final entity = _remapper.toAuthEntity(response);
      await _tokenLocalDataSource.saveTokens(
        accessToken: entity.accessToken,
        refreshToken: entity.refreshToken,
        expiresAt: entity.expiresAt,
      );
      return entity;
    } catch (e) {
      throw mapToResponseError(e);
    }
  }

  @override
  Future<AuthEntity> register({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _remoteDataSource.register(
        RegisterRequest(email: email, password: password),
      );
      final entity = _remapper.toAuthEntity(response);
      await _tokenLocalDataSource.saveTokens(
        accessToken: entity.accessToken,
        refreshToken: entity.refreshToken,
        expiresAt: entity.expiresAt,
      );
      return entity;
    } catch (e) {
      throw mapToResponseError(e);
    }
  }

  @override
  Future<void> clearTokens() => _tokenLocalDataSource.clearTokens();
}
