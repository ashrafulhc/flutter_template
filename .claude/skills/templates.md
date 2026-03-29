# Skill: Code Templates Reference

Quick copy-paste templates for every file type. Replace `Xxx`/`xxx` with the feature name (e.g., `Profile`/`profile`). No instructions — use `/new-feature` for guided creation.

---

## Domain Entity
`lib/domain/entities/<f>/<f>_entity.dart`
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part '<f>_entity.freezed.dart';

@freezed
abstract class XxxEntity with _$XxxEntity {
  const factory XxxEntity({
    required String id,
    required String name,
  }) = _XxxEntity;
}
```

---

## Domain Repository Interface
`lib/domain/repositories/<f>/<f>_repository.dart`
```dart
import 'package:flutter_template/domain/entities/<f>/<f>_entity.dart';

abstract interface class XxxRepository {
  Future<XxxEntity> getXxx({required String id});
  Future<XxxEntity> createXxx({required String name});
  Future<void> deleteXxx({required String id});
}
```

---

## Response DTO
`lib/data/response_objects/<f>_response/<f>_response.dart`
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part '<f>_response.freezed.dart';
part '<f>_response.g.dart';

@freezed
abstract class XxxResponse with _$XxxResponse {
  const factory XxxResponse({
    @JsonKey(name: 'id') required String id,
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _XxxResponse;

  factory XxxResponse.fromJson(Map<String, dynamic> json) =>
      _$XxxResponseFromJson(json);
}
```

---

## Request Object
`lib/data/request_objects/<f>_request/<f>_request.dart`
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part '<f>_request.freezed.dart';
part '<f>_request.g.dart';

@freezed
abstract class XxxRequest with _$XxxRequest {
  const factory XxxRequest({
    @JsonKey(name: 'name') required String name,
  }) = _XxxRequest;

  factory XxxRequest.fromJson(Map<String, dynamic> json) =>
      _$XxxRequestFromJson(json);
}
```

---

## Remapper
`lib/data/remappers/<f>_remapper.dart`
```dart
import 'package:flutter_template/data/response_objects/<f>_response/<f>_response.dart';
import 'package:flutter_template/domain/entities/<f>/<f>_entity.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class XxxRemapper {
  XxxEntity toXxxEntity(XxxResponse response) {
    return XxxEntity(
      id: response.id,
      name: response.name,
    );
  }
}
```

---

## Remote Data Source (Retrofit)
`lib/data/services/<f>/source/remote/<f>_remote_data_source.dart`
```dart
import 'package:dio/dio.dart';
import 'package:flutter_template/data/request_objects/<f>_request/<f>_request.dart';
import 'package:flutter_template/data/response_objects/<f>_response/<f>_response.dart';
import 'package:flutter_template/injection/network_module.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

part '<f>_remote_data_source.g.dart';

@RestApi()
@lazySingleton
abstract class XxxRemoteDataSource {
  @factoryMethod
  factory XxxRemoteDataSource(@Named(dioClient) Dio dio) =
      _XxxRemoteDataSource;

  @GET('/xxx/{id}')
  Future<XxxResponse> getXxx(@Path('id') String id);

  @POST('/xxx')
  Future<XxxResponse> createXxx(@Body() XxxRequest request);

  @DELETE('/xxx/{id}')
  Future<void> deleteXxx(@Path('id') String id);
}
```

---

## Local Data Source (SecureStorage)
`lib/data/services/<f>/source/local/<f>_local_data_source.dart`
```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class XxxLocalDataSource {
  final FlutterSecureStorage _storage;

  const XxxLocalDataSource(this._storage);

  static const _xxxKey = 'xxx_key';

  Future<void> saveXxx(String value) =>
      _storage.write(key: _xxxKey, value: value);

  Future<String?> getXxx() => _storage.read(key: _xxxKey);

  Future<void> clearXxx() => _storage.delete(key: _xxxKey);
}
```

---

## Repository Implementation
`lib/data/repositories/<f>/<f>_repository_impl.dart`
```dart
import 'package:flutter_template/data/remappers/<f>_remapper.dart';
import 'package:flutter_template/data/request_objects/<f>_request/<f>_request.dart';
import 'package:flutter_template/data/response_objects/response_error.dart';
import 'package:flutter_template/data/services/<f>/source/remote/<f>_remote_data_source.dart';
import 'package:flutter_template/domain/entities/<f>/<f>_entity.dart';
import 'package:flutter_template/domain/repositories/<f>/<f>_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: XxxRepository)
class XxxRepositoryImpl implements XxxRepository {
  final XxxRemoteDataSource _remoteDataSource;
  final XxxRemapper _remapper;

  XxxRepositoryImpl(this._remoteDataSource, this._remapper);

  @override
  Future<XxxEntity> getXxx({required String id}) async {
    try {
      final response = await _remoteDataSource.getXxx(id);
      return _remapper.toXxxEntity(response);
    } catch (e) {
      throw ResponseError.from(e);
    }
  }

  @override
  Future<XxxEntity> createXxx({required String name}) async {
    try {
      final response = await _remoteDataSource.createXxx(
        XxxRequest(name: name),
      );
      return _remapper.toXxxEntity(response);
    } catch (e) {
      throw ResponseError.from(e);
    }
  }

  @override
  Future<void> deleteXxx({required String id}) async {
    try {
      await _remoteDataSource.deleteXxx(id);
    } catch (e) {
      throw ResponseError.from(e);
    }
  }
}
```

---

## Use Case (optional)
`lib/domain/usecases/<f>/get_<f>_use_case.dart`
```dart
import 'package:flutter_template/domain/entities/<f>/<f>_entity.dart';
import 'package:flutter_template/domain/repositories/<f>/<f>_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetXxxUseCase {
  final XxxRepository _repository;

  GetXxxUseCase(this._repository);

  Future<XxxEntity> run({required String id}) => _repository.getXxx(id: id);
}
```

---

## Cubit State
`lib/presentation/features/<f>/cubit/<f>_state.dart`
```dart
part of '<f>_cubit.dart';

@freezed
abstract class XxxState with _$XxxState {
  const factory XxxState({
    @Default(BaseStatus.initial()) BaseStatus initStatus,
    XxxEntity? xxx,
  }) = _XxxState;
}
```

---

## Cubit
`lib/presentation/features/<f>/cubit/<f>_cubit.dart`
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/data/response_objects/response_error.dart';
import 'package:flutter_template/domain/common/base_status/base_status.dart';
import 'package:flutter_template/domain/entities/<f>/<f>_entity.dart';
import 'package:flutter_template/domain/repositories/<f>/<f>_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part '<f>_state.dart';
part '<f>_cubit.freezed.dart';

@injectable
class XxxCubit extends Cubit<XxxState> {
  final XxxRepository _repository;

  XxxCubit(this._repository) : super(const XxxState());

  Future<void> loadXxx({required String id}) async {
    if (state.initStatus.isLoading) return;

    emit(state.copyWith(initStatus: const BaseStatus.loading()));

    try {
      final xxx = await _repository.getXxx(id: id);
      if (isClosed) return;
      emit(state.copyWith(
        initStatus: const BaseStatus.success(),
        xxx: xxx,
      ));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        initStatus: BaseStatus.failure(ResponseError.from(e)),
      ));
    }
  }
}
```

---

## Screen (BlocProvider wrapper)
`lib/presentation/features/<f>/<f>_screen.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/injection/injector.dart';
import 'package:flutter_template/presentation/features/<f>/cubit/<f>_cubit.dart';
import 'package:flutter_template/presentation/features/<f>/ui/<f>_body.dart';

class XxxScreen extends StatelessWidget {
  const XxxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<XxxCubit>(
      create: (context) => injector(),
      child: const XxxBody(),
    );
  }
}
```

---

## Body (BlocListener + context.select)
`lib/presentation/features/<f>/ui/<f>_body.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/presentation/features/<f>/cubit/<f>_cubit.dart';
import 'package:go_router/go_router.dart';

class XxxBody extends StatelessWidget {
  const XxxBody({super.key});

  @override
  Widget build(BuildContext context) {
    // Granular field subscriptions — only rebuild widget subtree that cares
    final xxx = context.select((XxxCubit c) => c.state.xxx);

    return BlocListener<XxxCubit, XxxState>(
      listenWhen: (previous, current) =>
          previous.initStatus != current.initStatus,
      listener: (context, state) {
        if (state.initStatus.isSuccess) {
          // Navigate or show success UI
        }
        if (state.initStatus.isFailure) {
          final error = (state.initStatus as Failure).error;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.getErrorMessage())),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Xxx')),
        body: BlocBuilder<XxxCubit, XxxState>(
          buildWhen: (prev, curr) => prev.initStatus != curr.initStatus,
          builder: (context, state) {
            if (state.initStatus.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return const Placeholder();
          },
        ),
      ),
    );
  }
}
```

---

## Router Entry
`lib/presentation/routes/app_router.dart`
```dart
// In AppRoutes abstract class:
static const xxx = '/xxx';

// In GoRouter routes list:
GoRoute(
  path: AppRoutes.xxx,
  builder: (context, state) => const XxxScreen(),
),
```

---

## Cubit Test
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

  final tEntity = XxxEntity(id: '1', name: 'Test');

  setUp(() {
    mockRepository = MockXxxRepository();
  });

  XxxCubit buildCubit() => XxxCubit(mockRepository);

  group('XxxCubit', () {
    group('loadXxx', () {
      blocTest<XxxCubit, XxxState>(
        'emits loading then success with entity',
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
              .thenThrow(Exception('error'));
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

---

## Repository Test
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
  setUpAll(() {
    registerFallbackValue(const XxxRequest(name: 'fallback'));
  });

  late MockXxxRemoteDataSource mockRemote;
  late MockXxxRemapper mockRemapper;
  late XxxRepositoryImpl sut;

  final tResponse = XxxResponse(id: '1', name: 'Test', createdAt: '2030-01-01T00:00:00.000Z');
  final tEntity = XxxEntity(id: '1', name: 'Test');

  setUp(() {
    mockRemote = MockXxxRemoteDataSource();
    mockRemapper = MockXxxRemapper();
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

    test('throws ResponseError on failure', () async {
      when(() => mockRemote.getXxx(any())).thenThrow(Exception('error'));

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

    test('returns XxxEntity on success', () async {
      when(() => mockRemote.createXxx(any())).thenAnswer((_) async => tResponse);

      final result = await sut.createXxx(name: 'Test');

      expect(result, equals(tEntity));
    });
  });
}
```
