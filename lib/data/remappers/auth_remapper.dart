import 'package:flutter_template/data/response_objects/auth_response/auth_response.dart';
import 'package:flutter_template/domain/entities/auth/auth_entity.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AuthRemapper {
  AuthEntity toAuthEntity(AuthResponse response) {
    return AuthEntity(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
      expiresAt: DateTime.parse(response.expiresAt),
    );
  }
}
