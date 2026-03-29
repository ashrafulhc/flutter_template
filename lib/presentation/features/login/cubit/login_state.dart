part of 'login_cubit.dart';

@freezed
abstract class LoginState with _$LoginState {
  const factory LoginState({
    @Default('') String email,
    @Default('') String password,
    @Default(BaseStatus.initial()) BaseStatus initStatus,
    String? emailError,
    String? passwordError,
  }) = _LoginState;
}
