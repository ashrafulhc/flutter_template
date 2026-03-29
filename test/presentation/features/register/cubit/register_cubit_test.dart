import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_template/domain/common/errors/response_error.dart';
import 'package:flutter_template/domain/common/base_status/base_status.dart';
import 'package:flutter_template/domain/entities/auth/auth_entity.dart';
import 'package:flutter_template/domain/usecases/auth/register_use_case.dart';
import 'package:flutter_template/presentation/features/register/cubit/register_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

void main() {
  late MockRegisterUseCase mockRegisterUseCase;

  final tEntity = AuthEntity(
    accessToken: 'access123',
    refreshToken: 'refresh123',
    expiresAt: DateTime(2030),
  );

  setUp(() {
    mockRegisterUseCase = MockRegisterUseCase();
  });

  RegisterCubit buildCubit() => RegisterCubit(mockRegisterUseCase);

  group('RegisterCubit', () {
    // ------------------------------------------------------------------ email
    group('onEmailChanged', () {
      blocTest<RegisterCubit, RegisterState>(
        'emits emailError when email is empty',
        build: buildCubit,
        act: (cubit) => cubit.onEmailChanged(''),
        expect: () => [
          const RegisterState(email: '', emailError: 'Email is required'),
        ],
      );

      blocTest<RegisterCubit, RegisterState>(
        'emits emailError when email is invalid',
        build: buildCubit,
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
        build: buildCubit,
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
        build: buildCubit,
        act: (cubit) => cubit.onPasswordChanged(''),
        expect: () => [
          const RegisterState(
            password: '',
            passwordError: 'Password is required',
          ),
        ],
      );

      blocTest<RegisterCubit, RegisterState>(
        'emits passwordError when password is too short',
        build: buildCubit,
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
        build: buildCubit,
        act: (cubit) => cubit.onPasswordChanged('validpassword'),
        expect: () => [
          const RegisterState(password: 'validpassword', passwordError: null),
        ],
      );

      blocTest<RegisterCubit, RegisterState>(
        'updates confirmPasswordError when confirm was already touched and no longer matches',
        build: buildCubit,
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
        build: buildCubit,
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
        build: buildCubit,
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
        build: buildCubit,
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
        build: buildCubit,
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
        build: buildCubit,
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
        build: buildCubit,
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
        build: buildCubit,
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
        'emits loading then success when register succeeds',
        build: () {
          when(
            () => mockRegisterUseCase.run(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenAnswer((_) async => tEntity);
          return buildCubit();
        },
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
            const BaseStatus<dynamic>.loading(),
          ),
          isA<RegisterState>().having(
            (s) => s.initStatus,
            'initStatus',
            const BaseStatus<dynamic>.success(),
          ),
        ],
      );

      blocTest<RegisterCubit, RegisterState>(
        'emits loading then failure when register throws',
        build: () {
          when(
            () => mockRegisterUseCase.run(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenThrow(const ResponseError.conflict());
          return buildCubit();
        },
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
            const BaseStatus<dynamic>.loading(),
          ),
          isA<RegisterState>().having(
            (s) => s.initStatus.isFailure,
            'isFailure',
            true,
          ),
        ],
      );

      blocTest<RegisterCubit, RegisterState>(
        'does not emit when already loading',
        build: buildCubit,
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
