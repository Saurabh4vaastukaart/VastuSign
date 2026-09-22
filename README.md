# VastuSign

VastuSign is an original, offline-first Flutter app for guided Vastu
self-analysis. It includes the Android client, a local SQLite database, PDF
reports, and a zero-dependency Node.js cloud API.

## What works

- onboarding, dashboard, categories, reports, plans, and profile flows;
- live device compass with 16 directions and 32 entrance padas;
- calibration quality, boundary warnings, and manual fallback;
- optional camera overlay and photo capture;
- versioned starter rules for 19 property areas;
- persistent measurements and completed reports in SQLite;
- A4 PDF creation and Android share sheet;
- optional email/password account and explicit cloud sync;
- backend users, properties, measurements, and server reports;
- CI tests plus an installable release APK artifact.

The app remains usable when `API_BASE_URL` is omitted. Cloud account and sync
buttons become active only in builds configured with a deployed API URL.

## Build Android locally

Use the current stable Flutter release with Dart 3.10+ and Java 17:

```bash
flutter create --platforms=android --org com.vastusign --project-name vastusign .
python3 tool/prepare_android.py
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter build apk --release --dart-define=API_BASE_URL=https://your-api.example
```

The APK is written to `build/app/outputs/flutter-apk/app-release.apk`.

## Build with GitHub Actions

Push this folder to a GitHub repository and run **Build and verify VastuSign**.
The workflow generates the Android runner, tests the app, builds the release
APK, and publishes it as the `VastuSign-Android-APK` artifact. Enter the
deployed API URL when starting the workflow, or leave it blank for an
offline-only APK.

## Run the backend

Node 24 or later is required:

```bash
cd backend
AUTH_SECRET="replace-with-a-long-random-secret" npm start
```

See `backend/README.md` for its routes and production notes.

## Important domain note

The included `starter-rules-2026.09` rules are transparent placeholder domain
content, not a claim of scientific validation or professional advice. Have a
qualified Vastu expert review the rules and remedies before a commercial
release. Do not make structural, health, safety, or financial decisions from an
app report alone.

## Clean-room boundary

VastuWheels was used only to understand common product flows. No source code,
brand assets, credentials, or proprietary rule text is copied here.
