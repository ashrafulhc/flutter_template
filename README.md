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
