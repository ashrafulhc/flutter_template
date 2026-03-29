import 'package:flutter_template/domain/entities/auth/auth_entity.dart';

abstract interface class AuthRepository {
  Future<AuthEntity> login({required String email, required String password});
  Future<AuthEntity> register({required String email, required String password});
  Future<void> clearTokens();
}
