# flutter_application_1

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

### Prerequisites

- Flutter SDK (^3.5.0)
- Dart SDK (^3.5.0)
- Android Studio / VS Code with Flutter extensions
- Xcode (for iOS development)

### Installation

```bash
flutter pub get
```

### Running the app

```bash
# Mobile
flutter run

# Web
flutter run -d chrome

# Desktop
flutter run -d windows
flutter run -d macos
flutter run -d linux
```

### Testing

```bash
flutter test
```

### Building

```bash
# Android
flutter build apk
flutter build appbundle

# iOS
flutter build ios

# Web
flutter build web

# Desktop
flutter build windows
flutter build macos
flutter build linux
```

## Project Structure

```
lib/
  main.dart          # Entry point
test/
  widget_test.dart   # Widget tests
android/             # Android configuration
ios/                 # iOS configuration
web/                 # Web configuration
windows/             # Windows configuration
macos/               # macOS configuration
linux/               # Linux configuration
```