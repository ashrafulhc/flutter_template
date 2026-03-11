# Flutter Template

## Overview

This project is built using Flutter and supports multiple environments (flavors) to facilitate different stages of development, testing, and production deployment. The project setup includes three flavors:

- **development**
- **staging**
- **production**

Each flavor allows you to configure different environments with specific configurations.

## Getting Started

### Prerequisites

Ensure you have Flutter installed on your machine. You can check this by running:

```bash
flutter --version
```

If Flutter is not installed, follow the [official installation guide](https://flutter.dev/docs/get-started/install).

### Clone the Repository

Clone the project from the repository:

```bash
git clone git@github.com:ashrafulhc/flutter_template.git
```

Navigate to the project:

```bash
cd flutter_template
```

### Install Dependencies

Run the following command to install the necessary packages:

```bash
flutter pub get
```

### Generate Necessary Files

The project uses code generation. To generate the required files, run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

This command will generate files needed for various functionalities and ensure there are no conflicting outputs.

## Running the Project

### Using VSCode or Android Studio

You can run the desired flavor using the launch configurations provided in VSCode or Android Studio.

### Using the Command Line

Alternatively, you can run the project using the terminal with the following commands:

#### For Development:

```bash
flutter run --flavor development --target lib/main_development.dart
```

#### For Staging:

```bash
flutter run --flavor staging --target lib/main_staging.dart
```

#### For Production:

```bash
flutter run --flavor production --target lib/main_production.dart
```

## Running Tests

```bash
flutter test
```

## Architecture

This project follows Flutter's official [app architecture guidelines](https://docs.flutter.dev/app-architecture) using a layered Clean Architecture approach.

### Layers

```
lib/
├── data/                        # Data layer
│   ├── repositories/            # Repository implementations (SSOT for app data)
│   ├── services/                # Low-level API wrappers (Retrofit/Dio)
│   ├── remappers/               # DTO → domain model mappers
│   └── response_objects/        # API response DTOs + error types
├── domain/                      # Domain layer
│   ├── repositories/            # Abstract repository interfaces
│   ├── entities/                # Immutable domain models (Freezed)
│   ├── usecases/                # Business logic use-cases
│   └── common/                  # Shared domain primitives (BaseStatus)
├── presentation/                # UI layer
│   ├── features/                # Feature modules (page + cubit + ui/)
│   ├── resources/               # Theme, colors, text styles
│   ├── routes/                  # GoRouter configuration
│   └── widgets/                 # Shared reusable widgets
└── injection/                   # Dependency injection (GetIt + Injectable)
```

### Key Conventions

| Concern | Convention |
|---|---|
| State management | Flutter BLoC (Cubit) with Freezed states |
| Repository pattern | Abstract interface in `domain/repositories/`, impl in `data/repositories/` |
| Services | Retrofit API clients in `data/services/` — lowest layer, no state |
| DI | GetIt singletons registered via `@injectable` annotations; `injector.config.dart` is generated |
| Routing | GoRouter with `ShellRoute` for tab navigation |
| Models | Freezed for immutability; separate DTOs (`response_objects/`) from domain entities |
| Async state | `BaseStatus<T>` sealed class: `initial / loading / success / failure` |
| Error handling | `ResponseError` sealed class maps `DioException` → typed errors with localized messages |
| Theming | `ThemeExtension` pattern via `theme_tailor`; `AppColors` and `AppTextStyles` per brightness |
| Flavors | Three entry points: `main_development.dart`, `main_staging.dart`, `main_production.dart` |

### Adding a New Feature

1. **Data layer**: Create `data/services/<feature>/source/remote/<feature>_remote_data_source.dart` (Retrofit), `data/remappers/<feature>_remapper.dart`, and `data/repositories/<feature>/<feature>_repository_impl.dart`
2. **Domain layer**: Create `domain/repositories/<feature>/<feature>_repository.dart` (abstract interface), `domain/entities/<feature>/<feature>_entity.dart` (Freezed), and optionally `domain/usecases/<feature>/` use-cases
3. **Presentation layer**: Create `presentation/features/<feature>/` with `<feature>_page.dart`, `cubit/<feature>_cubit.dart`, `cubit/<feature>_state.dart`, and `ui/<feature>_body.dart`
4. Register the new repository via `@LazySingleton(as: FeatureRepository)` and run `dart run build_runner build --delete-conflicting-outputs`
