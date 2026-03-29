# Skill: Writing Tests

Use this skill before writing tests for a cubit, repository, or use case.

Replace `Xxx`/`xxx` with your feature name (e.g., `Profile`/`profile`).

---

## Test File Location

Mirror `lib/` structure under `test/`:

```
lib/presentation/features/login/cubit/login_cubit.dart
→ test/presentation/features/login/cubit/login_cubit_test.dart

lib/data/repositories/auth/auth_repository_impl.dart
→ test/data/repositories/auth/auth_repository_impl_test.dart
```

---

## Critical Rules

1. **Mock abstract interfaces, not impls:** `class MockXxxRepository extends Mock implements XxxRepository {}`
2. **Instantiate impl directly:** `sut = XxxRepositoryImpl(mockRemote, mockRemapper)` — no DI
3. **`setUpAll` with `registerFallbackValue`** is required when using `any()` matchers against Freezed request objects (because Freezed objects need a fallback for `any()` to work with mocktail)
4. **`seed:`** sets the cubit's initial state before `act:` runs — use it to skip setup steps
5. **Partial matching:** `isA<XxxState>().having(...)` — use direct state equality only when ALL fields match exactly
6. **Failure assertion:** `throwsA(isA<ResponseError>())` — not `thenThrow(ResponseError(...))`
7. **Failure status check (cubit):** `isA<XxxState>().having((s) => s.initStatus.isFailure, 'isFailure', true)` — no need to match the exact subtype

---

## Cubit Test Template

`test/presentation/features/<f>/cubit/<f>_cubit_test.dart`

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_template/domain/common/base_status/base_status.dart';
import 'package:flutter_template/domain/entities/<f>/<f>_entity.dart';
import 'package:flutter_template/domain/repositories/<f>/<f>_repository.dart';
import 'package:flutter_template/presentation/features/<f>/cubit/<f>_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockXxxRepository extends Mock implements XxxRepository {}

void main() {
  late MockXxxRepository mockRepository;

  // Test fixtures
  final tEntity = XxxEntity(id: '1', name: 'Test');

  setUp(() {
    mockRepository = MockXxxRepository();
  });

  XxxCubit buildCubit() => XxxCubit(mockRepository);

  group('XxxCubit', () {
    group('loadXxx', () {
      blocTest<XxxCubit, XxxState>(
        'emits loading then success with entity on success',
        build: () {
          when(() => mockRepository.getXxx(id: any(named: 'id')))
              .thenAnswer((_) async => tEntity);
          return buildCubit();
        },
        act: (cubit) => cubit.loadXxx(id: '1'),
        expect: () => [
          isA<XxxState>().having(
            (s) => s.initStatus,
            'initStatus',
            const BaseStatus<dynamic>.loading(),
          ),
          isA<XxxState>()
              .having(
                (s) => s.initStatus,
                'initStatus',
                const BaseStatus<dynamic>.success(),
              )
              .having((s) => s.xxx, 'xxx', tEntity),
        ],
      );

      blocTest<XxxCubit, XxxState>(
        'emits loading then failure on error',
        build: () {
          when(() => mockRepository.getXxx(id: any(named: 'id')))
              .thenThrow(Exception('network error'));
          return buildCubit();
        },
        act: (cubit) => cubit.loadXxx(id: '1'),
        expect: () => [
          isA<XxxState>().having(
            (s) => s.initStatus,
            'initStatus',
            const BaseStatus<dynamic>.loading(),
          ),
          isA<XxxState>().having(
            (s) => s.initStatus.isFailure,
            'isFailure',
            true,
          ),
        ],
      );

      blocTest<XxxCubit, XxxState>(
        'does not emit when already loading',
        build: buildCubit,
        seed: () => const XxxState(initStatus: BaseStatus.loading()),
        act: (cubit) => cubit.loadXxx(id: '1'),
        expect: () => [],
      );
    });
  });
}
```

### Form Cubit Additional Tests

```dart
group('onNameChanged', () {
  blocTest<XxxCubit, XxxState>(
    'emits error when name is empty',
    build: buildCubit,
    act: (cubit) => cubit.onNameChanged(''),
    expect: () => [
      const XxxState(name: '', nameError: 'Name is required'),
    ],
  );

  blocTest<XxxCubit, XxxState>(
    'clears error when name is valid',
    build: buildCubit,
    act: (cubit) => cubit.onNameChanged('Valid Name'),
    expect: () => [
      const XxxState(name: 'Valid Name', nameError: null),
    ],
  );
});

group('onSubmit', () {
  blocTest<XxxCubit, XxxState>(
    'does not emit loading when name is empty',
    build: buildCubit,
    act: (cubit) => cubit.onSubmit(),
    expect: () => [
      // validation emit only — no loading state
      isA<XxxState>().having((s) => s.nameError, 'nameError', 'Name is required'),
    ],
  );
});
```

---

## Repository Test Template

`test/data/repositories/<f>/<f>_repository_impl_test.dart`

```dart
import 'package:flutter_template/data/remappers/<f>_remapper.dart';
import 'package:flutter_template/data/repositories/<f>/<f>_repository_impl.dart';
import 'package:flutter_template/data/request_objects/<f>_request/<f>_request.dart';
import 'package:flutter_template/data/response_objects/<f>_response/<f>_response.dart';
import 'package:flutter_template/data/response_objects/response_error.dart';
import 'package:flutter_template/data/services/<f>/source/remote/<f>_remote_data_source.dart';
import 'package:flutter_template/domain/entities/<f>/<f>_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockXxxRemoteDataSource extends Mock implements XxxRemoteDataSource {}

class MockXxxRemapper extends Mock implements XxxRemapper {}

void main() {
  // registerFallbackValue is required for Freezed request objects used with any()
  setUpAll(() {
    registerFallbackValue(const XxxRequest(name: 'fallback'));
  });

  late MockXxxRemoteDataSource mockRemote;
  late MockXxxRemapper mockRemapper;
  late XxxRepositoryImpl sut;

  // Test fixtures
  final tResponse = XxxResponse(
    id: '1',
    name: 'Test',
    createdAt: '2030-01-01T00:00:00.000Z',
  );
  final tEntity = XxxEntity(id: '1', name: 'Test');

  setUp(() {
    mockRemote = MockXxxRemoteDataSource();
    mockRemapper = MockXxxRemapper();
    // Instantiate impl directly — no DI
    sut = XxxRepositoryImpl(mockRemote, mockRemapper);
  });

  group('getXxx', () {
    setUp(() {
      when(() => mockRemapper.toXxxEntity(tResponse)).thenReturn(tEntity);
    });

    test('returns XxxEntity on success', () async {
      when(() => mockRemote.getXxx(any())).thenAnswer((_) async => tResponse);

      final result = await sut.getXxx(id: '1');

      expect(result, equals(tEntity));
    });

    test('throws ResponseError on remote failure', () async {
      when(() => mockRemote.getXxx(any())).thenThrow(Exception('network error'));

      expect(
        () => sut.getXxx(id: '1'),
        throwsA(isA<ResponseError>()),
      );
    });
  });

  group('createXxx', () {
    setUp(() {
      when(() => mockRemapper.toXxxEntity(tResponse)).thenReturn(tEntity);
    });

    test('returns XxxEntity and calls remote on success', () async {
      when(() => mockRemote.createXxx(any())).thenAnswer((_) async => tResponse);

      final result = await sut.createXxx(name: 'Test');

      expect(result, equals(tEntity));
      verify(() => mockRemote.createXxx(any())).called(1);
    });

    test('throws ResponseError on remote failure', () async {
      when(() => mockRemote.createXxx(any())).thenThrow(Exception('error'));

      expect(
        () => sut.createXxx(name: 'Test'),
        throwsA(isA<ResponseError>()),
      );
    });
  });

  group('deleteXxx', () {
    test('delegates to remote data source', () async {
      when(() => mockRemote.deleteXxx(any())).thenAnswer((_) async {});

      await sut.deleteXxx(id: '1');

      verify(() => mockRemote.deleteXxx('1')).called(1);
    });
  });
}
```

---

## Use Case Test Template

`test/domain/usecases/<f>/get_<f>_use_case_test.dart`

```dart
import 'package:flutter_template/domain/entities/<f>/<f>_entity.dart';
import 'package:flutter_template/domain/repositories/<f>/<f>_repository.dart';
import 'package:flutter_template/domain/usecases/<f>/get_<f>_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockXxxRepository extends Mock implements XxxRepository {}

void main() {
  late MockXxxRepository mockRepository;
  late GetXxxUseCase sut;

  final tEntity = XxxEntity(id: '1', name: 'Test');

  setUp(() {
    mockRepository = MockXxxRepository();
    sut = GetXxxUseCase(mockRepository);
  });

  group('GetXxxUseCase', () {
    test('calls repository.getXxx and returns entity', () async {
      when(() => mockRepository.getXxx(id: any(named: 'id')))
          .thenAnswer((_) async => tEntity);

      final result = await sut.run(id: '1');

      expect(result, equals(tEntity));
      verify(() => mockRepository.getXxx(id: '1')).called(1);
    });
  });
}
```

---

## Common Mock Snippets Reference

```dart
// Stub an async method
when(() => mock.method(any())).thenAnswer((_) async => result);

// Stub a synchronous method
when(() => mock.method(any())).thenReturn(result);

// Stub to throw
when(() => mock.method(any())).thenThrow(Exception('error'));

// Stub void async
when(() => mock.voidMethod(any())).thenAnswer((_) async {});

// Named parameter matchers
when(() => mock.method(id: any(named: 'id'))).thenAnswer(...);

// Verify called once
verify(() => mock.method(expectedArg)).called(1);

// Verify never called
verifyNever(() => mock.method(any()));

// Capture argument
final captured = verify(() => mock.method(captureAny())).captured;
expect(captured.last, equals(expectedArg));
```

---

## Run Tests

```bash
flutter test
flutter analyze
```
