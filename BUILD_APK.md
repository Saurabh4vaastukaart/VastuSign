# Build the installable Android APK

## Recommended: GitHub Actions

1. Create an empty private GitHub repository named `VastuSign-App`.
2. Upload this source folder to its `main` branch.
3. Open **Actions → Build and verify VastuSign → Run workflow**.
4. Leave `api_base_url` empty for the offline edition, or enter the deployed
   backend URL for account and sync support.
5. When the workflow completes, download the `VastuSign-Android-APK` artifact.
6. Extract it and install `app-release.apk` on Android. Android may ask you to
   allow installs from your browser or file manager.

The workflow generates the missing platform runner, applies camera/compass
permissions, runs tests, and builds a release APK.

## Local build

Install the current stable Flutter release with Dart 3.10+ and Java 17, then
run from the project root:

```bash
flutter create --platforms=android --org com.vastusign --project-name vastusign .
python3 tool/prepare_android.py
flutter pub get
flutter test
flutter build apk --release
```

For cloud sync, replace the last command with:

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://your-api.example
```

The output is `build/app/outputs/flutter-apk/app-release.apk`.

## Build status in this delivery

The backend smoke test and available syntax checks pass. The supplied workspace
did not contain Flutter, Dart, Gradle, or an Android SDK, so the binary itself
must be produced by the included workflow or another configured Android build
machine.
