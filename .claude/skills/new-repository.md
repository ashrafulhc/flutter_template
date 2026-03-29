# Skill: Add a New Repository

Use this skill when adding the **data + domain layers** for a new resource. Invoke before writing any code.

Replace `Xxx`/`xxx` with your feature name (e.g., `Profile`/`profile`).

---

## Files to Create (7 files)

| # | File Path | Type |
|---|-----------|------|
| 1 | `lib/domain/entities/<f>/<f>_entity.dart` | Domain entity |
| 2 | `lib/domain/repositories/<f>/<f>_repository.dart` | Abstract interface |
| 3 | `lib/data/response_objects/<f>_response/<f>_response.dart` | Response DTO |
| 4 | `lib/data/request_objects/<f>_request/<f>_request.dart` | Request DTO (if mutations) |
| 5 | `lib/data/remappers/<f>_remapper.dart` | DTO → Entity mapper |
| 6 | `lib/data/services/<f>/source/remote/<f>_remote_data_source.dart` | Retrofit API client |
| 7 | `lib/data/repositories/<f>/<f>_repository_impl.dart` | Repository implementation |

## DI Annotation Cheat-Sheet

| File | Annotation |
|------|-----------|
| Entity | none |
| Repository interface | none (abstract) |
| Response/Request DTO | none (pure data) |
| Remapper | `@lazySingleton` |
| Remote data source | `@RestApi()` + `@lazySingleton` |
| Local data source | `@lazySingleton` |
| Repository impl | `@LazySingleton(as: XxxRepository)` |

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

> Entities are immutable Freezed value objects. No `fromJson` unless persisting locally.

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

> Use named parameters for all methods — it makes call sites readable and stubs in tests easier to match.

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

> Always use `@JsonKey(name: 'snake_case')` — JSON field names come from the API, Dart fields are camelCase.

---

## Step 4 — Request Object (if mutations needed)

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

> Skip this file for read-only repositories with no POST/PUT/PATCH endpoints.

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
    );
  }
}
```

> One method per response type. If the entity has a `DateTime`, parse it here: `DateTime.parse(response.createdAt)`.

---

## Step 6 — Remote Data Source (CRITICAL PATTERN)

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

> **Critical:** The `@factoryMethod factory` line with `@Named(dioClient)` is mandatory — without it, Injectable cannot resolve the Dio instance. Never use a plain `Dio` without `@Named`.

---

## Step 7 — Repository Implementation

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

> Always wrap every method body in `try/catch` and rethrow with `ResponseError.from(e)`. Never let raw exceptions leak to the domain layer.

---

## After Creating All Files

```bash
dart run build_runner build --delete-conflicting-outputs
```

Then write tests with `/new-tests`.
