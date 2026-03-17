import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/domain/common/base_status/base_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'register_state.dart';
part 'register_cubit.freezed.dart';

@injectable
class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(const RegisterState());

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
    final passwordError = password.isEmpty
        ? 'Password is required'
        : password.length < 8
            ? 'Password must be at least 8 characters'
            : null;
    final confirmError = state.confirmPassword.isEmpty
        ? state.confirmPasswordError
        : state.confirmPassword != password
            ? 'Passwords do not match'
            : null;
    emit(state.copyWith(
      password: password,
      passwordError: passwordError,
      confirmPasswordError: confirmError,
    ));
  }

  void onConfirmPasswordChanged(String confirmPassword) {
    final error = confirmPassword.isEmpty
        ? 'Please confirm your password'
        : confirmPassword != state.password
            ? 'Passwords do not match'
            : null;
    emit(state.copyWith(
      confirmPassword: confirmPassword,
      confirmPasswordError: error,
    ));
  }

  Future<void> onSubmit() async {
    onEmailChanged(state.email);
    onPasswordChanged(state.password);
    onConfirmPasswordChanged(state.confirmPassword);

    if (state.emailError != null ||
        state.passwordError != null ||
        state.confirmPasswordError != null ||
        state.email.isEmpty ||
        state.password.isEmpty ||
        state.confirmPassword.isEmpty) {
      return;
    }

    if (state.initStatus.isLoading) return;

    emit(state.copyWith(initStatus: const BaseStatus.loading()));
    await Future.delayed(const Duration(seconds: 2));

    if (isClosed) return;

    emit(state.copyWith(initStatus: const BaseStatus.success()));
  }
}
