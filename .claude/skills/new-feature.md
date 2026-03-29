# Skill: Add a New Feature (End-to-End)

Use this skill before scaffolding a **full new feature** across all layers. For partial work, use `/new-repository` (data layer only) or `/new-cubit` (presentation layer only).

Replace `Xxx`/`xxx` with your feature name (e.g., `Profile`/`profile`).

---

## 16-Step Checklist

- [ ] 1. Domain entity
- [ ] 2. Domain repository interface
- [ ] 3. Response DTO
- [ ] 4. Request object (if mutations)
- [ ] 5. Remapper
- [ ] 6. Remote data source
- [ ] 7. Local data source (if needed)
- [ ] 8. Repository implementation
- [ ] 9. Use case (if needed)
- [ ] 10. Cubit state
- [ ] 11. Cubit
- [ ] 12. Screen/Page
- [ ] 13. Body
- [ ] 14. Route
- [ ] 15. Run build_runner
- [ ] 16. Tests

---

## Step 1 — Domain Entity

**File:** `lib/domain/entities/<f>/<f>_entity.dart`

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

## Step 2 — Domain Repository Interface

**File:** `lib/domain/repositories/<f>/<f>_repository.dart`

```dart
import 'package:flutter_template/domain/entities/<f>/<f>_entity.dart';

abstract interface class XxxRepository {
  Future<XxxEntity> getXxx({required String id});
  Future<XxxEntity> createXxx({required String name});
  Future<void> deleteXxx({required String id});
}
```

---

## Step 3 — Response DTO

**File:** `lib/data/response_objects/<f>_response/<f>_response.dart`

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

## Step 4 — Request Object (skip if read-only)

**File:** `lib/data/request_objects/<f>_request/<f>_request.dart`

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

## Step 5 — Remapper

**File:** `lib/data/remappers/<f>_remapper.dart`

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
      // For DateTime fields: expiresAt: DateTime.parse(response.expiresAt)
    );
  }
}
```

---

## Step 6 — Remote Data Source

**File:** `lib/data/services/<f>/source/remote/<f>_remote_data_source.dart`

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

> **Critical:** `@factoryMethod factory XxxRemoteDataSource(@Named(dioClient) Dio dio)` — exact syntax required.

---

## Step 7 — Local Data Source (skip if no local storage needed)

**File:** `lib/data/services/<f>/source/local/<f>_local_data_source.dart`

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class XxxLocalDataSource {
  final FlutterSecureStorage _storage;

  const XxxLocalDataSource(this._storage);

  static const _key = 'xxx_value';

  Future<void> save(String value) => _storage.write(key: _key, value: value);
  Future<String?> get() => _storage.read(key: _key);
  Future<void> clear() => _storage.delete(key: _key);
}
```

---

## Step 8 — Repository Implementation

**File:** `lib/data/repositories/<f>/<f>_repository_impl.dart`

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

## Step 9 — Use Case (skip unless cross-repository logic or complex shared logic)

**File:** `lib/domain/usecases/<f>/get_<f>_use_case.dart`

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

## Step 10 — Cubit State

**File:** `lib/presentation/features/<f>/cubit/<f>_state.dart`

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

> This file must begin with `part of '<f>_cubit.dart';` — it is NOT a standalone file.

---

## Step 11 — Cubit

**File:** `lib/presentation/features/<f>/cubit/<f>_cubit.dart`

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

## Step 12 — Screen

**File:** `lib/presentation/features/<f>/<f>_screen.dart`

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

## Step 13 — Body

**File:** `lib/presentation/features/<f>/ui/<f>_body.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/presentation/features/<f>/cubit/<f>_cubit.dart';
import 'package:go_router/go_router.dart';

class XxxBody extends StatelessWidget {
  const XxxBody({super.key});

  @override
  Widget build(BuildContext context) {
    final xxx = context.select((XxxCubit c) => c.state.xxx);

    return BlocListener<XxxCubit, XxxState>(
      listenWhen: (previous, current) =>
          previous.initStatus != current.initStatus,
      listener: (context, state) {
        if (state.initStatus.isSuccess) {
          // Navigate: context.go(AppRoutes.someRoute)
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

## Step 14 — Add Route

**File:** `lib/presentation/routes/app_router.dart`

```dart
// 1. Add constant to AppRoutes:
static const xxx = '/xxx';

// 2. Add GoRoute to the routes list:
GoRoute(
  path: AppRoutes.xxx,
  builder: (context, state) => const XxxScreen(),
),
```

---

## Step 15 — Run build_runner

```bash
dart run build_runner build --delete-conflicting-outputs
```

This regenerates:
- `<f>_entity.freezed.dart`
- `<f>_response.freezed.dart`, `<f>_response.g.dart`
- `<f>_request.freezed.dart`, `<f>_request.g.dart`
- `<f>_remote_data_source.g.dart`
- `<f>_cubit.freezed.dart`
- `lib/injection/injector.config.dart`

---

## Step 16 — Write Tests

Use `/new-tests` for complete test templates.

Test files to create:
- `test/data/repositories/<f>/<f>_repository_impl_test.dart`
- `test/presentation/features/<f>/cubit/<f>_cubit_test.dart`

Run tests:
```bash
flutter test
flutter analyze
```
