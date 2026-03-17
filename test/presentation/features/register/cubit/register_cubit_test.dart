import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_template/domain/common/base_status/base_status.dart';
import 'package:flutter_template/presentation/features/register/cubit/register_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RegisterCubit', () {
    // ------------------------------------------------------------------ email
    group('onEmailChanged', () {
      blocTest<RegisterCubit, RegisterState>(
        'emits emailError when email is empty',
        build: RegisterCubit.new,
        act: (cubit) => cubit.onEmailChanged(''),
        expect: () => [
          const RegisterState(email: '', emailError: 'Email is required'),
        ],
      );

      blocTest<RegisterCubit, RegisterState>(
        'emits emailError when email is invalid',
        build: RegisterCubit.new,
        act: (cubit) => cubit.onEmailChanged('notanemail'),
        expect: () => [
          const RegisterState(
            email: 'notanemail',
            emailError: 'Enter a valid email address',
          ),
        ],
      );

      blocTest<RegisterCubit, RegisterState>(
        'emits null emailError when email is valid',
        build: RegisterCubit.new,
        act: (cubit) => cubit.onEmailChanged('user@example.com'),
        expect: () => [
          const RegisterState(email: 'user@example.com', emailError: null),
        ],
      );
    });

    // --------------------------------------------------------------- password
    group('onPasswordChanged', () {
      blocTest<RegisterCubit, RegisterState>(
        'emits passwordError when password is empty',
        build: RegisterCubit.new,
        act: (cubit) => cubit.onPasswordChanged(''),
        expect: () => [
          const RegisterState(password: '', passwordError: 'Password is required'),
        ],
      );

      blocTest<RegisterCubit, RegisterState>(
        'emits passwordError when password is too short',
        build: RegisterCubit.new,
        act: (cubit) => cubit.onPasswordChanged('short'),
        expect: () => [
          const RegisterState(
            password: 'short',
            passwordError: 'Password must be at least 8 characters',
          ),
        ],
      );

      blocTest<RegisterCubit, RegisterState>(
        'emits null passwordError when password is valid',
        build: RegisterCubit.new,
        act: (cubit) => cubit.onPasswordChanged('validpassword'),
        expect: () => [
          const RegisterState(password: 'validpassword', passwordError: null),
        ],
      );

      blocTest<RegisterCubit, RegisterState>(
        'updates confirmPasswordError when confirm was already touched and no longer matches',
        build: RegisterCubit.new,
        seed: () => const RegisterState(
          confirmPassword: 'oldpass1',
          confirmPasswordError: null,
        ),
        act: (cubit) => cubit.onPasswordChanged('newpassword'),
        expect: () => [
          isA<RegisterState>().having(
            (s) => s.confirmPasswordError,
            'confirmPasswordError',
            'Passwords do not match',
          ),
        ],
      );
    });

    // ------------------------------------------------------- confirmPassword
    group('onConfirmPasswordChanged', () {
      blocTest<RegisterCubit, RegisterState>(
        'emits confirmPasswordError when confirm is empty',
        build: RegisterCubit.new,
        act: (cubit) => cubit.onConfirmPasswordChanged(''),
        expect: () => [
          const RegisterState(
            confirmPassword: '',
            confirmPasswordError: 'Please confirm your password',
          ),
        ],
      );

      blocTest<RegisterCubit, RegisterState>(
        'emits confirmPasswordError when confirm does not match password',
        build: RegisterCubit.new,
        seed: () => const RegisterState(password: 'validpassword'),
        act: (cubit) => cubit.onConfirmPasswordChanged('differentpass'),
        expect: () => [
          isA<RegisterState>().having(
            (s) => s.confirmPasswordError,
            'confirmPasswordError',
            'Passwords do not match',
          ),
        ],
      );

      blocTest<RegisterCubit, RegisterState>(
        'emits null confirmPasswordError when confirm matches password',
        build: RegisterCubit.new,
        seed: () => const RegisterState(password: 'validpassword'),
        act: (cubit) => cubit.onConfirmPasswordChanged('validpassword'),
        expect: () => [
          isA<RegisterState>().having(
            (s) => s.confirmPasswordError,
            'confirmPasswordError',
            null,
          ),
        ],
      );
    });

    // ---------------------------------------------------------------- submit
    group('onSubmit', () {
      blocTest<RegisterCubit, RegisterState>(
        'emits field errors and does not load when all fields are untouched',
        build: RegisterCubit.new,
        act: (cubit) => cubit.onSubmit(),
        expect: () => [
          const RegisterState(email: '', emailError: 'Email is required'),
          const RegisterState(
            email: '',
            emailError: 'Email is required',
            password: '',
            passwordError: 'Password is required',
          ),
          const RegisterState(
            email: '',
            emailError: 'Email is required',
            password: '',
            passwordError: 'Password is required',
            confirmPassword: '',
            confirmPasswordError: 'Please confirm your password',
          ),
        ],
      );

      blocTest<RegisterCubit, RegisterState>(
        'does not emit loading when email is invalid',
        build: RegisterCubit.new,
        seed: () => const RegisterState(
          email: 'bademail',
          password: 'validpassword',
          confirmPassword: 'validpassword',
        ),
        act: (cubit) => cubit.onSubmit(),
        expect: () => [
          isA<RegisterState>().having(
            (s) => s.emailError,
            'emailError',
            'Enter a valid email address',
          ),
        ],
      );

      blocTest<RegisterCubit, RegisterState>(
        'does not emit loading when password is too short',
        build: RegisterCubit.new,
        seed: () => const RegisterState(
          email: 'user@example.com',
          password: 'short',
          confirmPassword: 'short',
        ),
        act: (cubit) => cubit.onSubmit(),
        expect: () => [
          isA<RegisterState>().having(
            (s) => s.passwordError,
            'passwordError',
            'Password must be at least 8 characters',
          ),
        ],
      );

      blocTest<RegisterCubit, RegisterState>(
        'does not emit loading when passwords do not match',
        build: RegisterCubit.new,
        seed: () => const RegisterState(
          email: 'user@example.com',
          password: 'validpassword',
          confirmPassword: 'differentpassword',
        ),
        act: (cubit) => cubit.onSubmit(),
        expect: () => [
          isA<RegisterState>().having(
            (s) => s.confirmPasswordError,
            'confirmPasswordError',
            'Passwords do not match',
          ),
        ],
      );

      blocTest<RegisterCubit, RegisterState>(
        'emits loading then success when all fields are valid',
        build: RegisterCubit.new,
        seed: () => const RegisterState(
          email: 'user@example.com',
          password: 'validpassword',
          confirmPassword: 'validpassword',
        ),
        act: (cubit) => cubit.onSubmit(),
        expect: () => [
          isA<RegisterState>().having(
            (s) => s.initStatus,
            'initStatus',
            const BaseStatus.loading(),
          ),
          isA<RegisterState>().having(
            (s) => s.initStatus,
            'initStatus',
            const BaseStatus.success(),
          ),
        ],
      );

      blocTest<RegisterCubit, RegisterState>(
        'does not emit when already loading',
        build: RegisterCubit.new,
        seed: () => const RegisterState(
          email: 'user@example.com',
          password: 'validpassword',
          confirmPassword: 'validpassword',
          initStatus: BaseStatus.loading(),
        ),
        act: (cubit) => cubit.onSubmit(),
        expect: () => [],
      );
    });
  });
}
