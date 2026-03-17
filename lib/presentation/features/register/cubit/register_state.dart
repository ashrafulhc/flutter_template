part of 'register_cubit.dart';

@freezed
abstract class RegisterState with _$RegisterState {
  const factory RegisterState({
    @Default('') String email,
    @Default('') String password,
    @Default('') String confirmPassword,
    @Default(BaseStatus.initial()) BaseStatus initStatus,
    String? emailError,
    String? passwordError,
    String? confirmPasswordError,
  }) = _RegisterState;
}
