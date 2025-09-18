# Pirr Mini App

A minimal Flutter + Firebase app demonstrating authentication, Firestore, Remote Config, and Analytics. Perfect as a code sample or educational material.

## 🚀 Running the App

### With Firebase Emulator (Recommended for Development)

1. **Prerequisites:**
   - Flutter 3.x installed
   - Firebase CLI installed (`npm install -g firebase-tools`)
   - Node.js 16+ for the emulator

2. **Start the emulator:**
   ```bash
   # In project root
   firebase emulators:start --only firestore
   ```

3. **Run the app:**
   ```bash
   cd pirr_app
   flutter pub get
   flutter run
   ```

### With Your Own Firebase Project

1. **Create Firebase project:**
   - Go to [Firebase Console](https://console.firebase.google.com)
   - Create new project
   - Enable Authentication (Email/Password) and Firestore

2. **Configure platforms:**
   - **Android:** Download `google-services.json` → `pirr_app/android/app/`
   - **iOS:** Download `GoogleService-Info.plist` → `pirr_app/ios/Runner/`

3. **Update Firestore rules:**
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{userId}/entries/{entryId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
     }
   }
   ```

4. **Run the app:**
   ```bash
   cd pirr_app
   flutter pub get
   flutter run
   ```

## 🏗️ Architecture

### Folder Structure
```
pirr_app/
├── lib/
│   ├── main.dart              # App entry point + Firebase init
│   ├── login_screen.dart      # Auth UI (login/signup)
│   ├── entries_screen.dart    # Main screen with entries
│   └── utils/
│       └── time_ago.dart      # Time formatting utility
├── test/                      # Widget + unit tests
└── android/ios/web/           # Platform-specific configurations
```

### Tech Stack
- **Frontend:** Flutter 3.x with Material 3 design
- **Backend:** Firebase (Auth, Firestore, Analytics, Remote Config)
- **State:** StatelessWidgets with setState (simple state management)
- **Navigation:** MaterialApp with StreamBuilder for auth routing

### Data Model
```javascript
// Firestore structure
users/{uid}/entries/{entryId}
├── text: string              // Entry text
├── createdAt: timestamp      // Server timestamp
└── (Remote Config controls date display)
```

### Firebase Services
- **Authentication:** Email/password with FirebaseAuth
- **Database:** Firestore with real-time updates
- **Analytics:** Automatic screen tracking + custom events
- **Remote Config:** Toggle for date display per entry
- **Storage:** SharedPreferences for local state

## 🔧 Configuration

### Linting & Code Quality
```yaml
# analysis_options.yaml
linter:
  rules:
    avoid_print: true
    prefer_const_constructors: true
    prefer_single_quotes: true
    # ... more rules for code quality
```

### CI/CD
- GitHub Actions runs `flutter analyze` and `flutter test` on push/PR
- Workflow: `.github/workflows/flutter.yml`

### Environment Variables
- **Emulator:** `10.0.2.2:8080` (Android), `localhost:8080` (iOS/Web)
- **Production:** Uses Firebase project settings

## 🧪 Testing

```bash
cd pirr_app
flutter test
```

**Test coverage:**
- `login_screen_test.dart`: Email/password validation
- `time_ago_test.dart`: Time formatting utility
- `smoke_test.dart`: Basic app startup

## 📊 Analytics Events

The app logs the following events to Firebase Analytics:

```dart
// Automatic events
screen_view(screen_name: 'EntriesScreen')

// Custom events
login(login_method: 'password')
sign_up(sign_up_method: 'password') 
entry_created(entry_id: string, text_length: number)
entry_deleted(entry_id: string)
```

**Debugging:** Use Firebase Console → Analytics → DebugView for real-time viewing.

## 🔒 Security & Rules

### Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Only authenticated users can read/write their own entries
    match /users/{userId}/entries/{entryId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### Data Validation
- **Client-side:** Email format, password length (6+ chars)
- **Server-side:** Firestore rules ensure data access control

## 🚀 Next Steps

- [ ] **Offline support:** Cache entries locally with Hive/SQLite
- [ ] **Dark mode:** Theme toggle with SharedPreferences
- [ ] **Entry editing:** Edit existing entries
- [ ] **State management:** Migrate to Riverpod/Bloc for better state
- [ ] **Search & filter:** Search functionality and categories

### Technical Debt
- [ ] **Error handling:** Centralized error handling with try/catch
- [ ] **Performance:** Lazy loading and pagination for large datasets
- [ ] **Accessibility:** Screen reader support and keyboard navigation

## 📚 Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Material 3 Design](https://m3.material.io/)
- [Firebase Emulator Suite](https://firebase.google.com/docs/emulator-suite)