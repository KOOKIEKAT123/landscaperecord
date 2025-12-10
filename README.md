# LandscapeRecord

LandscapeRecord is a Flutter app that displays landmarks on OpenStreetMap. The app allows users to add, edit, and delete landmarks and view them on a map.

## Features

- View landmarks on an OpenStreetMap map
- Add new landmarks with a name and description
- Edit existing landmarks
- Delete landmarks

## Prerequisites

- Flutter SDK (stable channel) installed: https://flutter.dev/docs/get-started/install
- An Android or iOS device/emulator configured for development

## Setup

1. Clone the repository:

   git clone https://github.com/KOOKIEKAT123/landscaperecord.git
   cd landscaperecord

2. Install dependencies:

   flutter pub get

## Running the app

- Run on connected device or emulator:

  flutter run

- To build a release APK for Android:

  flutter build apk --release

## Development notes

- The project uses the `flutter_map` package with OpenStreetMap tiles (or similar). Check pubspec.yaml for exact dependencies.
- If you add new packages, run `flutter pub get` before running the app.

## Contributing

Contributions are welcome. Please open an issue to discuss major changes and submit pull requests for fixes and features.

## License

This project is provided as-is. Add a LICENSE file to specify a license if needed.
