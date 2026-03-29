import 'package:flutter_template/domain/entities/auth/auth_entity.dart';
import 'package:flutter_template/domain/repositories/auth/auth_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class RegisterUseCase {
  final AuthRepository _authRepository;

  RegisterUseCase(this._authRepository);

  Future<AuthEntity> run({required String email, required String password}) {
    return _authRepository.register(email: email, password: password);
  }
}
