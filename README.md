## Pirr Mini App

Small Flutter + Firebase code case. Includes Email/Password auth and a simple entries list backed by Firestore. Remote Config toggles a date chip per entry. Basic analytics events are logged for create/delete.

### Run locally

1. Flutter 3.x installed and Firebase CLI configured.
2. Ensure platform configs are present (Android `google-services.json`, iOS `GoogleService-Info.plist`). They are already checked in.
3. Start Firestore Emulator (optional):
   - Android emulator uses `10.0.2.2:8080`; iOS/macOS/web use `localhost:8080` (wired in `pirr_app/lib/main.dart`).
4. Run:

```bash
cd pirr_app
flutter pub get
flutter run
```

### Tests

```bash
cd pirr_app
flutter test
```

Includes:
- Widget test: login validation shows friendly messages.
- Unit test: `formatTimeAgo` utility.

### Notes

- Minimal linting enabled via `analysis_options.yaml` to keep code tidy (consts, single quotes, no prints).
- Firestore structure: `users/{uid}/entries/{entryId}` with fields `text` and `createdAt`.