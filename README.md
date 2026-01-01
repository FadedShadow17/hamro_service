# hamro_service

A customer friendly home service booking app that lets you book different home services in Kathmandu.

## Architecture

This project follows Clean Architecture pattern with:

- **app/** - App configuration, routes, and theme
- **core/** - Shared services, providers, utilities, and error handling
- **features/** - Feature modules with data/domain/presentation layers

### State Management
- **Riverpod** - Used for state management with NotifierProvider pattern

### Local Storage
- **Hive** - Local database for storing user data
- **SharedPreferences** - Session persistence

## Getting Started

### Prerequisites
- Flutter SDK (3.9.2 or higher)
- Dart SDK

### Setup

1. Install dependencies:
```bash
flutter pub get
```

2. Generate code (Hive adapters):
```bash
dart run build_runner build --delete-conflicting-outputs
```

3. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── app/              # App configuration
│   ├── routes/       # Navigation utilities
│   └── theme/        # App theming
├── core/             # Shared code
│   ├── constants/    # App constants
│   ├── error/        # Error handling
│   ├── providers/    # Riverpod providers
│   ├── services/     # Core services (Hive, Storage)
│   └── utils/        # Utilities
└── features/         # Feature modules
    └── auth/         # Authentication feature
        ├── data/     # Data layer (models, datasources, repositories)
        ├── domain/   # Domain layer (entities, usecases)
        └── presentation/ # Presentation layer (pages, viewmodels, state)
```

## Authentication

The app uses Hive for local authentication:
- User registration saves data to Hive
- Login verifies credentials from Hive
- Session is persisted using SharedPreferences
- On app restart, session is checked and user is auto-logged in if valid

## Code Generation

After modifying Hive models, run:
```bash
dart run build_runner build --delete-conflicting-outputs
```

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Riverpod Documentation](https://riverpod.dev/)
- [Hive Documentation](https://docs.hivedb.dev/)
