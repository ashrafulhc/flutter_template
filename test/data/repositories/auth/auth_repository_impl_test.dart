import 'package:flutter_template/data/remappers/auth_remapper.dart';
import 'package:flutter_template/data/repositories/auth/auth_repository_impl.dart';
import 'package:flutter_template/data/request_objects/login_request/login_request.dart';
import 'package:flutter_template/data/request_objects/register_request/register_request.dart';
import 'package:flutter_template/data/response_objects/auth_response/auth_response.dart';
import 'package:flutter_template/domain/common/errors/response_error.dart';
import 'package:flutter_template/data/services/auth/source/local/token_local_data_source.dart';
import 'package:flutter_template/data/services/auth/source/remote/auth_remote_data_source.dart';
import 'package:flutter_template/domain/entities/auth/auth_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockTokenLocalDataSource extends Mock implements TokenLocalDataSource {}

class MockAuthRemapper extends Mock implements AuthRemapper {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const LoginRequest(email: 'fallback@example.com', password: 'fallback'),
    );
    registerFallbackValue(
      const RegisterRequest(
        email: 'fallback@example.com',
        password: 'fallback',
      ),
    );
  });
  late MockAuthRemoteDataSource mockRemote;
  late MockTokenLocalDataSource mockLocal;
  late MockAuthRemapper mockRemapper;
  late AuthRepositoryImpl sut;

  final tResponse = AuthResponse(
    accessToken: 'access123',
    refreshToken: 'refresh123',
    expiresAt: DateTime(2030).toIso8601String(),
  );

  final tEntity = AuthEntity(
    accessToken: 'access123',
    refreshToken: 'refresh123',
    expiresAt: DateTime(2030),
  );

  setUp(() {
    mockRemote = MockAuthRemoteDataSource();
    mockLocal = MockTokenLocalDataSource();
    mockRemapper = MockAuthRemapper();
    sut = AuthRepositoryImpl(mockRemote, mockLocal, mockRemapper);

    when(
      () => mockLocal.saveTokens(
        accessToken: any(named: 'accessToken'),
        refreshToken: any(named: 'refreshToken'),
        expiresAt: any(named: 'expiresAt'),
      ),
    ).thenAnswer((_) async {});

    when(() => mockLocal.clearTokens()).thenAnswer((_) async {});
  });

  group('login', () {
    setUp(() {
      when(() => mockRemapper.toAuthEntity(tResponse)).thenReturn(tEntity);
    });

    test('returns AuthEntity and saves tokens on success', () async {
      when(
        () => mockRemote.login(any()),
      ).thenAnswer((_) async => tResponse);

      final result = await sut.login(
        email: 'user@example.com',
        password: 'password123',
      );

      expect(result, equals(tEntity));
      verify(
        () => mockLocal.saveTokens(
          accessToken: tEntity.accessToken,
          refreshToken: tEntity.refreshToken,
          expiresAt: tEntity.expiresAt,
        ),
      ).called(1);
    });

    test('throws ResponseError on remote data source failure', () async {
      when(() => mockRemote.login(any())).thenThrow(
        Exception('Network error'),
      );

      expect(
        () => sut.login(email: 'user@example.com', password: 'password123'),
        throwsA(isA<ResponseError>()),
      );
    });
  });

  group('register', () {
    setUp(() {
      when(() => mockRemapper.toAuthEntity(tResponse)).thenReturn(tEntity);
    });

    test('returns AuthEntity and saves tokens on success', () async {
      when(
        () => mockRemote.register(any()),
      ).thenAnswer((_) async => tResponse);

      final result = await sut.register(
        email: 'user@example.com',
        password: 'password123',
      );

      expect(result, equals(tEntity));
      verify(
        () => mockLocal.saveTokens(
          accessToken: tEntity.accessToken,
          refreshToken: tEntity.refreshToken,
          expiresAt: tEntity.expiresAt,
        ),
      ).called(1);
    });

    test('throws ResponseError on remote data source failure', () async {
      when(() => mockRemote.register(any())).thenThrow(
        Exception('Network error'),
      );

      expect(
        () => sut.register(email: 'user@example.com', password: 'password123'),
        throwsA(isA<ResponseError>()),
      );
    });
  });

  group('clearTokens', () {
    test('delegates to TokenLocalDataSource', () async {
      await sut.clearTokens();
      verify(() => mockLocal.clearTokens()).called(1);
    });
  });
}
