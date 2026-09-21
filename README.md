# GOZY Platform Mobile

This repository contains the GOZY Flutter mobile application for Android and iOS, including authentication, listings, reservations, payments, messaging, notifications, and account management.

## Requirements

- Flutter `3.41.2`
- Dart SDK `>=3.2.0 <4.0.0`
- Android Studio and Android SDK
- Xcode and CocoaPods for iOS development

The supported platform versions and signing requirements are maintained in the native Android and iOS project configuration.

## Local setup

### 1) Install dependencies

```bash
flutter pub get
```

### 2) Configure environment values

Create the local environment file from the safe template:

```bash
cp .env.example .env
```

Set the GraphQL endpoint, upload URL, package identifiers, app version, and local API key in `.env`. The file is used as a Flutter asset and must remain local.

### 3) Add platform configuration

The following files are required for Firebase-enabled builds but are intentionally not stored in Git:

- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `ios/firebase_app_id_file.json`

Obtain these files through the team’s secure configuration process. Android and iOS signing files and provisioning profiles must also be configured locally.

### 4) Run the application

```bash
flutter run
```

For iOS, install CocoaPods dependencies when needed:

```bash
cd ios
pod install
cd ..
```

## Tests and checks

```bash
flutter analyze
flutter test
```

## Repository structure

- `lib/` — Flutter application source
- `android/` — Android project and build configuration
- `ios/` — iOS project and build configuration
- `res/` — images, fonts, icons, and other application assets
- `customization/` — local customization package
- `.env.example` — safe environment template

## Sensitive files

Environment files, Firebase configuration, signing keys, certificates, provisioning profiles, and local build output are ignored by Git. Never commit credentials or production configuration.

## License

This project is maintained for internal GOZY development use. Please refer to the licensing terms supplied with the original product acquisition before any external distribution or reuse.# GOZY Platform Mobile

This repository contains the GOZY Flutter mobile application for Android and iOS, including authentication, listings, reservations, payments, messaging, notifications, and account management.

## Requirements

- Flutter `3.41.2`
- Dart SDK `>=3.2.0 <4.0.0`
- Android Studio and Android SDK
- Xcode and CocoaPods for iOS development

The supported platform versions and signing requirements are maintained in the native Android and iOS project configuration.

## Local setup

### 1) Install dependencies

```bash
flutter pub get
```

### 2) Configure environment values

Create the local environment file from the safe template:

```bash
cp .env.example .env
```

Set the GraphQL endpoint, upload URL, package identifiers, app version, and local API key in `.env`. The file is used as a Flutter asset and must remain local.

### 3) Add platform configuration

The following files are required for Firebase-enabled builds but are intentionally not stored in Git:

- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `ios/firebase_app_id_file.json`

Obtain these files through the team’s secure configuration process. Android and iOS signing files and provisioning profiles must also be configured locally.

### 4) Run the application

```bash
flutter run
```

For iOS, install CocoaPods dependencies when needed:

```bash
cd ios
pod install
cd ..
```

## Tests and checks

```bash
flutter analyze
flutter test
```

## Repository structure

- `lib/` — Flutter application source
- `android/` — Android project and build configuration
- `ios/` — iOS project and build configuration
- `res/` — images, fonts, icons, and other application assets
- `customization/` — local customization package
- `.env.example` — safe environment template

## Sensitive files

Environment files, Firebase configuration, signing keys, certificates, provisioning profiles, and local build output are ignored by Git. Never commit credentials or production configuration.

## License

This project is maintained for internal GOZY development use. Please refer to the licensing terms supplied with the original product acquisition before any external distribution or reuse.
