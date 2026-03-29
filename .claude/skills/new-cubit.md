# Skill: Add a New Cubit + Screen

Use this skill when adding **presentation-layer only** — when the repository already exists and you only need the cubit, state, screen, and body.

Replace `Xxx`/`xxx` with your feature name (e.g., `Profile`/`profile`).

---

## Files to Create (4 files)

| # | File Path |
|---|-----------|
| 1 | `lib/presentation/features/<f>/cubit/<f>_state.dart` |
| 2 | `lib/presentation/features/<f>/cubit/<f>_cubit.dart` |
| 3 | `lib/presentation/features/<f>/<f>_screen.dart` (or `_page.dart`) |
| 4 | `lib/presentation/features/<f>/ui/<f>_body.dart` |

**Screen vs Page:**
- `XxxScreen` — for full-screen routes (login, register, splash, detail)
- `XxxPage` — for tab-resident widgets inside `MainScreen`

---

## Critical Rules

1. **`@injectable` not `@LazySingleton`** on the Cubit — each page gets a fresh instance
2. **`XxxState` is `part of` the cubit** — not a standalone class. It must begin with `part of '<f>_cubit.dart';`
3. **Cubit declares both part files:** `part '<f>_state.dart';` and `part '<f>_cubit.freezed.dart';`
4. **Loading guard:** `if (state.someStatus.isLoading) return;` before starting any async operation
5. **isClosed guard:** `if (isClosed) return;` after every `await` before emitting
6. **Error wrapping:** `BaseStatus.failure(ResponseError.from(e))` — never emit raw exceptions

---

## BaseStatus Quick Reference

| Variant | When to use |
|---------|-------------|
| `BaseStatus.initial()` | Default — nothing has happened yet |
| `BaseStatus.loading()` | Full-screen async operation in flight |
| `BaseStatus.lazyLoading()` | Paginated fetch / infinite scroll append |
| `BaseStatus.success()` | Completed successfully |
| `BaseStatus.valid()` | Sync validation passed |
| `BaseStatus.invalid()` | Sync validation failed |
| `BaseStatus.failure(error)` | Failed; `error` is a `ResponseError` |

---

## UI Observation Patterns

| Pattern | When to use |
|---------|-------------|
| `context.select((XxxCubit c) => c.state.field)` | Single field — only that subtree rebuilds |
| `BlocBuilder<XxxCubit, XxxState>(buildWhen: ...)` | Complex condition / multiple fields needed in builder |
| `BlocListener<XxxCubit, XxxState>(listenWhen: ...)` | Side effects: navigation, snackbars, dialogs |

Prefer `context.select` for simple fields — it's more efficient than `BlocBuilder` when you only care about one value.

---

## Step 1 — Cubit State

**File:** `lib/presentation/features/<f>/cubit/<f>_state.dart`

```dart
part of '<f>_cubit.dart';

@freezed
abstract class XxxState with _$XxxState {
  const factory XxxState({
    @Default(BaseStatus.initial()) BaseStatus initStatus,
    XxxEntity? xxx,
    // Add form field defaults:
    // @Default('') String name,
    // String? nameError,
  }) = _XxxState;
}
```

> Always use `@Default(...)` for primitive fields. Nullable fields without defaults are `null` by default.

---

## Step 2 — Cubit

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
    if (state.initStatus.isLoading) return;  // guard double-trigger

    emit(state.copyWith(initStatus: const BaseStatus.loading()));

    try {
      final xxx = await _repository.getXxx(id: id);
      if (isClosed) return;  // guard disposed cubit
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

### Form Validation Pattern (when the cubit has input fields)

```dart
// Synchronous validation — no loading guard needed
void onNameChanged(String name) {
  final error = name.trim().isEmpty ? 'Name is required' : null;
  emit(state.copyWith(name: name, nameError: error));
}

Future<void> onSubmit() async {
  // Re-validate to surface errors for untouched fields
  onNameChanged(state.name);

  if (state.nameError != null || state.name.isEmpty) return;
  if (state.initStatus.isLoading) return;

  emit(state.copyWith(initStatus: const BaseStatus.loading()));
  try {
    final result = await _repository.createXxx(name: state.name);
    if (isClosed) return;
    emit(state.copyWith(initStatus: const BaseStatus.success(), xxx: result));
  } catch (e) {
    if (isClosed) return;
    emit(state.copyWith(
      initStatus: BaseStatus.failure(ResponseError.from(e)),
    ));
  }
}
```

---

## Step 3 — Screen

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

> Use `injector()` (without the type parameter) — Injectable infers the type from `BlocProvider<XxxCubit>`.

---

## Step 4 — Body

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
    // Granular rebuild subscriptions
    final xxx = context.select((XxxCubit c) => c.state.xxx);

    return BlocListener<XxxCubit, XxxState>(
      listenWhen: (previous, current) =>
          previous.initStatus != current.initStatus,
      listener: (context, state) {
        if (state.initStatus.isSuccess) {
          // e.g. context.go(AppRoutes.home)
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
            // Build your UI here using `xxx` from context.select above
            return const Placeholder();
          },
        ),
      ),
    );
  }
}
```

---

## After Creating Files

```bash
dart run build_runner build --delete-conflicting-outputs
```

Then add the route in `lib/presentation/routes/app_router.dart`:
```dart
// AppRoutes constant:
static const xxx = '/xxx';

// Routes list:
GoRoute(
  path: AppRoutes.xxx,
  builder: (context, state) => const XxxScreen(),
),
```

Write tests with `/new-tests`.
