# Flutter Template — Claude Code Guide

## Project Overview

Flutter template with multi-flavor support (development / staging / production) following Flutter's official app architecture guidelines.

## Common Commands

```bash
# Run (pick a flavor)
flutter run --flavor development --target lib/main_development.dart

# Regenerate code (Freezed, Retrofit, Injectable, ThemeTailor)
dart run build_runner build --delete-conflicting-outputs

# Tests
flutter test

# Static analysis
flutter analyze
```

> Always run `build_runner` after adding `@freezed`, `@injectable`, `@RestApi()`, or `@tailor` annotations.

## Architecture

Follows Flutter's official [app architecture guidelines](https://docs.flutter.dev/app-architecture) — layered Clean Architecture with MVVM in the UI layer.

### Layer Responsibilities

| Layer | Path | Role |
|---|---|---|
| Data | `lib/data/` | API clients (Retrofit), DTOs, mappers, repository implementations |
| Domain | `lib/domain/` | Abstract repository interfaces, entities, use-cases, shared types |
| Presentation | `lib/presentation/` | Cubits (ViewModels), pages, UI widgets, theming, routing |
| Injection | `lib/injection/` | GetIt + Injectable DI setup |

### Naming Conventions

- `XxxRepository` (abstract in `domain/repositories/`) + `XxxRepositoryImpl` (`data/repositories/`) — source of truth for a data type
- `XxxRemoteDataSource` (`data/services/.../source/remote/`) — Retrofit API client, no state, wraps a single endpoint group
- `XxxRemapper` (`data/remappers/`) — maps DTOs → domain entities
- `XxxEntity` (`domain/entities/`) — immutable Freezed domain model
- `XxxUseCase` (`domain/usecases/`) — optional; encapsulates cross-repository logic or complex shared business logic
- `XxxCubit` / `XxxState` (`presentation/features/xxx/cubit/`) — ViewModel equivalent; manages UI state
- `XxxScreen` — full-screen route (login, register, splash) — no tab chrome; BlocProvider wrapper injecting Cubit via `injector()`
- `XxxPage` — tab-resident widget inside `MainScreen`; same BlocProvider wrapper pattern as XxxScreen
- `XxxBody` — StatelessWidget that reads from the Cubit and contains all UI

### State Management

Flutter BLoC (Cubit). State objects are Freezed sealed classes.

Async state uses `BaseStatus<T>` (`domain/common/base_status/`):
```dart
BaseStatus.initial()      // before any action
BaseStatus.loading()      // full-screen request in flight
BaseStatus.lazyLoading()  // pagination / infinite-scroll appends
BaseStatus.success()      // completed successfully
BaseStatus.valid()        // synchronous validation passed
BaseStatus.invalid()      // synchronous validation failed
BaseStatus.failure(error) // failed with a ResponseError
```

Guard against double-triggers in Cubits:
```dart
if (state.someStatus.isLoading) return;
```
Always check `isClosed` before emitting after an `await`.

**File structure:** `XxxState` lives in a separate `xxx_state.dart` file that begins with `part of 'xxx_cubit.dart';`. The cubit file declares both `part 'xxx_state.dart';` and `part 'xxx_cubit.freezed.dart';` at the top.

### Data Layer Patterns

- **Request objects:** `data/request_objects/<f>_request/<f>_request.dart` — `@freezed abstract class XxxRequest` with `fromJson` factory
- **Remote data source DI:** The `@RestApi()` abstract class uses `@factoryMethod` with `@Named(dioClient)` for injection:
  ```dart
  @RestApi()
  @lazySingleton
  abstract class XxxRemoteDataSource {
    @factoryMethod
    factory XxxRemoteDataSource(@Named(dioClient) Dio dio) = _XxxRemoteDataSource;
  }
  ```
- **Named Dio clients** (constants in `network_module.dart`):
  - `dioClient` — authenticated Dio with `AuthInterceptor` — used by all remote data sources
  - `dioRefreshClient` — bare Dio with no interceptors — used only for token refresh inside `AuthInterceptor`
- **Singleton services with StreamController:** annotate dispose with `@disposeMethod`:
  ```dart
  @disposeMethod
  void dispose() => _controller.close();
  ```

### Error Handling

`ResponseError` (`data/response_objects/response_error.dart`) is a Freezed sealed class covering all API error cases. Convert any exception with `ResponseError.from(e)`.

Global Flutter/Dart errors are caught in `lib/main_common.dart` via `FlutterError.onError` and `PlatformDispatcher.instance.onError` — add crash reporting (e.g. Firebase Crashlytics) there.

### Dependency Injection

GetIt + Injectable. `lib/injection/injector.config.dart` is **generated** — never hand-edit it.

Registration rules:
- `@LazySingleton` — stateless singletons (repositories, services, remappers)
- `@injectable` (factory) — Cubits and use-cases (new instance per page)
- `@singleton` — eager singletons (Dio client)
- `@module` — for third-party types (see `network_module.dart`)

`AppFlavor` is registered manually in `DependencyManager.inject()` (not via annotation) because it's an enum.

### Routing

GoRouter (`lib/presentation/routes/app_router.dart`). Tab navigation uses `ShellRoute` wrapping `MainScreen`. Route constants are in `AppRoutes`.

### Theming

`ThemeExtension` pattern via `theme_tailor`. Access in widgets:
```dart
context.colors.primary
context.textStyles.body
```

### Code Generation

Triggers:
- `@freezed` → Freezed (entities, states, DTOs, errors)
- `@RestApi()` → Retrofit (remote data sources)
- `@injectable` / `@module` → Injectable (DI config)
- `@tailor` → ThemeTailor (theme extensions)
- `@JsonSerializable` → json_serializable (JSON mapping)

Generated files (`*.freezed.dart`, `*.g.dart`) appear beside their source file. `lib/injection/injector.config.dart` is also regenerated. Never hand-edit any of these.

## Testing Conventions

- **Unit tests** for: repositories, use-cases, cubits
- **Widget tests** for: complex views (routing, DI integration)
- Test files mirror `lib/` structure under `test/`
- Use `mocktail` for mocks, `bloc_test` for cubit state assertions
- Mock the abstract repository interface, not the impl
- Instantiate the impl directly in tests: `sut = XxxRepositoryImpl(mockRemote, mockLocal, mockRemapper)`
- `setUpAll(() { registerFallbackValue(const XxxRequest(...)); })` is required when using `any()` matchers with Freezed request objects
- Failure assertions: `throwsA(isA<ResponseError>())` — not `thenThrow(ResponseError(...))`
- Partial state matching: `isA<XxxState>().having((s) => s.status.isFailure, 'isFailure', true)` — use direct equality only when ALL fields match exactly
- Cubit test `seed:` parameter sets the initial state before `act:` runs

## Adding a New Feature Checklist

1. `data/services/<f>/source/remote/<f>_remote_data_source.dart` — `@RestApi() @lazySingleton`
2. `data/response_objects/<f>_response/` — Freezed DTO + JSON
3. `data/remappers/<f>_remapper.dart` — `@lazySingleton`
4. `data/repositories/<f>/<f>_repository_impl.dart` — `@LazySingleton(as: FRepository)`
5. `domain/repositories/<f>/<f>_repository.dart` — `abstract interface class`
6. `domain/entities/<f>/<f>_entity.dart` — Freezed entity
7. (optional) `domain/usecases/<f>/` — if cross-repo or reused logic
8. `presentation/features/<f>/<f>_page.dart` + `cubit/` + `ui/<f>_body.dart`
9. Add route in `app_router.dart`
10. Run `build_runner`
11. Add unit tests under `test/`
