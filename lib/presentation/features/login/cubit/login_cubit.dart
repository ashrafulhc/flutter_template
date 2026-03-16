import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/domain/common/base_status/base_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'login_state.dart';
part 'login_cubit.freezed.dart';

@injectable
class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginState());

  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  void onEmailChanged(String email) {
    final error = email.trim().isEmpty
        ? 'Email is required'
        : !_emailRegex.hasMatch(email.trim())
            ? 'Enter a valid email address'
            : null;
    emit(state.copyWith(email: email, emailError: error));
  }

  void onPasswordChanged(String password) {
    final error = password.isEmpty
        ? 'Password is required'
        : password.length < 8
            ? 'Password must be at least 8 characters'
            : null;
    emit(state.copyWith(password: password, passwordError: error));
  }

  Future<void> onSubmit() async {
    // Re-validate to surface errors for untouched fields
    onEmailChanged(state.email);
    onPasswordChanged(state.password);

    if (state.emailError != null ||
        state.passwordError != null ||
        state.email.isEmpty ||
        state.password.isEmpty) {
      return;
    }

    if (state.initStatus.isLoading) return;

    emit(state.copyWith(initStatus: BaseStatus.loading()));
    await Future.delayed(const Duration(seconds: 2));

    if (isClosed) return;

    emit(state.copyWith(initStatus: BaseStatus.success()));
  }
}
