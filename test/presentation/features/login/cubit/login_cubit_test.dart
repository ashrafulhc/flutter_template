import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_template/domain/common/base_status/base_status.dart';
import 'package:flutter_template/presentation/features/login/cubit/login_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoginCubit', () {
    group('onEmailChanged', () {
      blocTest<LoginCubit, LoginState>(
        'emits emailError when email is empty',
        build: LoginCubit.new,
        act: (cubit) => cubit.onEmailChanged(''),
        expect: () => [
          const LoginState(email: '', emailError: 'Email is required'),
        ],
      );

      blocTest<LoginCubit, LoginState>(
        'emits emailError when email is invalid',
        build: LoginCubit.new,
        act: (cubit) => cubit.onEmailChanged('notanemail'),
        expect: () => [
          const LoginState(
            email: 'notanemail',
            emailError: 'Enter a valid email address',
          ),
        ],
      );

      blocTest<LoginCubit, LoginState>(
        'emits null emailError when email is valid',
        build: LoginCubit.new,
        act: (cubit) => cubit.onEmailChanged('user@example.com'),
        expect: () => [
          const LoginState(email: 'user@example.com', emailError: null),
        ],
      );
    });

    group('onPasswordChanged', () {
      blocTest<LoginCubit, LoginState>(
        'emits passwordError when password is empty',
        build: LoginCubit.new,
        act: (cubit) => cubit.onPasswordChanged(''),
        expect: () => [
          const LoginState(password: '', passwordError: 'Password is required'),
        ],
      );

      blocTest<LoginCubit, LoginState>(
        'emits passwordError when password is too short',
        build: LoginCubit.new,
        act: (cubit) => cubit.onPasswordChanged('short'),
        expect: () => [
          const LoginState(
            password: 'short',
            passwordError: 'Password must be at least 8 characters',
          ),
        ],
      );

      blocTest<LoginCubit, LoginState>(
        'emits null passwordError when password is valid',
        build: LoginCubit.new,
        act: (cubit) => cubit.onPasswordChanged('validpassword'),
        expect: () => [
          const LoginState(
            password: 'validpassword',
            passwordError: null,
          ),
        ],
      );
    });

    group('onSubmit', () {
      blocTest<LoginCubit, LoginState>(
        'emits field errors and does not load when fields are untouched',
        build: LoginCubit.new,
        act: (cubit) => cubit.onSubmit(),
        expect: () => [
          // onEmailChanged('') emitted
          const LoginState(email: '', emailError: 'Email is required'),
          // onPasswordChanged('') emitted
          const LoginState(
            email: '',
            emailError: 'Email is required',
            password: '',
            passwordError: 'Password is required',
          ),
          // blocked — no loading state emitted
        ],
      );

      blocTest<LoginCubit, LoginState>(
        'does not emit loading when email is invalid',
        build: LoginCubit.new,
        seed: () => const LoginState(
          email: 'bademail',
          password: 'validpassword',
        ),
        act: (cubit) => cubit.onSubmit(),
        // onEmailChanged emits with emailError set.
        // onPasswordChanged re-validates an already-valid password — state
        // is identical to what was just emitted, so Freezed deduplicates it
        // and no second emit occurs. Blocked before loading.
        expect: () => [
          isA<LoginState>().having(
            (s) => s.emailError,
            'emailError',
            'Enter a valid email address',
          ),
        ],
      );

      blocTest<LoginCubit, LoginState>(
        'does not emit loading when password is too short',
        build: LoginCubit.new,
        seed: () => const LoginState(
          email: 'user@example.com',
          password: 'short',
        ),
        act: (cubit) => cubit.onSubmit(),
        // onEmailChanged re-validates an already-valid email — same state,
        // deduplicated. onPasswordChanged emits with passwordError set.
        // Blocked before loading.
        expect: () => [
          isA<LoginState>().having(
            (s) => s.passwordError,
            'passwordError',
            'Password must be at least 8 characters',
          ),
        ],
      );

      blocTest<LoginCubit, LoginState>(
        'emits loading then success when fields are valid',
        build: LoginCubit.new,
        seed: () => const LoginState(
          email: 'user@example.com',
          password: 'validpassword',
        ),
        act: (cubit) => cubit.onSubmit(),
        // Re-validation of already-valid seeded values produces identical
        // state — deduplicated by Freezed. Only loading + success are emitted.
        expect: () => [
          isA<LoginState>().having(
            (s) => s.initStatus,
            'initStatus',
            const BaseStatus.loading(),
          ),
          isA<LoginState>().having(
            (s) => s.initStatus,
            'initStatus',
            const BaseStatus.success(),
          ),
        ],
      );

      blocTest<LoginCubit, LoginState>(
        'does not emit when already loading',
        build: LoginCubit.new,
        seed: () => const LoginState(
          email: 'user@example.com',
          password: 'validpassword',
          initStatus: BaseStatus.loading(),
        ),
        act: (cubit) => cubit.onSubmit(),
        expect: () => [],
      );
    });
  });
}
