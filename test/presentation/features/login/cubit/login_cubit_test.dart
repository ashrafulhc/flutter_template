import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_template/domain/common/errors/response_error.dart';
import 'package:flutter_template/domain/common/base_status/base_status.dart';
import 'package:flutter_template/domain/entities/auth/auth_entity.dart';
import 'package:flutter_template/domain/usecases/auth/login_use_case.dart';
import 'package:flutter_template/presentation/features/login/cubit/login_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

void main() {
  late MockLoginUseCase mockLoginUseCase;

  final tEntity = AuthEntity(
    accessToken: 'access123',
    refreshToken: 'refresh123',
    expiresAt: DateTime(2030),
  );

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
  });

  LoginCubit buildCubit() => LoginCubit(mockLoginUseCase);

  group('LoginCubit', () {
    group('onEmailChanged', () {
      blocTest<LoginCubit, LoginState>(
        'emits emailError when email is empty',
        build: buildCubit,
        act: (cubit) => cubit.onEmailChanged(''),
        expect: () => [
          const LoginState(email: '', emailError: 'Email is required'),
        ],
      );

      blocTest<LoginCubit, LoginState>(
        'emits emailError when email is invalid',
        build: buildCubit,
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
        build: buildCubit,
        act: (cubit) => cubit.onEmailChanged('user@example.com'),
        expect: () => [
          const LoginState(email: 'user@example.com', emailError: null),
        ],
      );
    });

    group('onPasswordChanged', () {
      blocTest<LoginCubit, LoginState>(
        'emits passwordError when password is empty',
        build: buildCubit,
        act: (cubit) => cubit.onPasswordChanged(''),
        expect: () => [
          const LoginState(
            password: '',
            passwordError: 'Password is required',
          ),
        ],
      );

      blocTest<LoginCubit, LoginState>(
        'emits passwordError when password is too short',
        build: buildCubit,
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
        build: buildCubit,
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
        build: buildCubit,
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
        build: buildCubit,
        seed: () => const LoginState(
          email: 'bademail',
          password: 'validpassword',
        ),
        act: (cubit) => cubit.onSubmit(),
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
        build: buildCubit,
        seed: () => const LoginState(
          email: 'user@example.com',
          password: 'short',
        ),
        act: (cubit) => cubit.onSubmit(),
        expect: () => [
          isA<LoginState>().having(
            (s) => s.passwordError,
            'passwordError',
            'Password must be at least 8 characters',
          ),
        ],
      );

      blocTest<LoginCubit, LoginState>(
        'emits loading then success when login succeeds',
        build: () {
          when(
            () => mockLoginUseCase.run(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenAnswer((_) async => tEntity);
          return buildCubit();
        },
        seed: () => const LoginState(
          email: 'user@example.com',
          password: 'validpassword',
        ),
        act: (cubit) => cubit.onSubmit(),
        expect: () => [
          isA<LoginState>().having(
            (s) => s.initStatus,
            'initStatus',
            const BaseStatus<dynamic>.loading(),
          ),
          isA<LoginState>().having(
            (s) => s.initStatus,
            'initStatus',
            const BaseStatus<dynamic>.success(),
          ),
        ],
      );

      blocTest<LoginCubit, LoginState>(
        'emits loading then failure when login throws',
        build: () {
          when(
            () => mockLoginUseCase.run(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenThrow(const ResponseError.unauthorized());
          return buildCubit();
        },
        seed: () => const LoginState(
          email: 'user@example.com',
          password: 'validpassword',
        ),
        act: (cubit) => cubit.onSubmit(),
        expect: () => [
          isA<LoginState>().having(
            (s) => s.initStatus,
            'initStatus',
            const BaseStatus<dynamic>.loading(),
          ),
          isA<LoginState>().having(
            (s) => s.initStatus.isFailure,
            'isFailure',
            true,
          ),
        ],
      );

      blocTest<LoginCubit, LoginState>(
        'does not emit when already loading',
        build: buildCubit,
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
