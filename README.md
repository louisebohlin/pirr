# Pirr Mini App

A minimal Flutter + Firebase app demonstrating authentication, Firestore, Remote Config, and Analytics.

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
│   ├── models/
│   │   └── entry.dart         # Data model with Firestore serialization
│   ├── services/
│   │   ├── entry_service.dart      # Entry CRUD operations
│   │   ├── analytics_service.dart  # Analytics event management
│   │   └── remote_config_service.dart # Remote configuration
│   └── utils/
│       └── time_ago.dart      # Time formatting utility
├── test/                      # Widget + unit tests
└── android/ios/web/           # Platform-specific configurations
```

### Tech Stack
- **Frontend:** Flutter 3.x with Material 3 design
- **Backend:** Firebase (Auth, Firestore, Analytics, Remote Config)
- **State:** Service layer pattern with proper separation of concerns
- **Navigation:** MaterialApp with StreamBuilder for auth routing
- **Architecture:** Clean architecture with models, services, and UI separation

### Data Model
```dart
// Entry model with Firestore serialization
class Entry {
  final String id;
  final String text;
  final DateTime createdAt;
  final String userId;
  
  // Methods: fromFirestore(), toFirestore(), copyWith()
}
```

```javascript
// Firestore structure
users/{uid}/entries/{entryId}
├── text: string              // Entry text
├── createdAt: timestamp      // Server timestamp
├── userId: string           // User ID for security
└── (Remote Config controls date display)
```

### Firebase Services
- **Authentication:** Email/password with FirebaseAuth
- **Database:** Firestore with real-time updates and optimized indexes
- **Analytics:** Comprehensive event tracking with meaningful parameters
- **Remote Config:** Feature toggles and configuration management
- **Storage:** SharedPreferences for local state persistence

### Service Layer
- **EntryService:** Handles all CRUD operations for entries with optimized user authentication checks
- **AnalyticsService:** Consolidated analytics with 3 generic methods (logEvent, logScreenView, setUserProperties)
- **RemoteConfigService:** Manages feature flags and configuration with fallback defaults
- **Error Handling:** Comprehensive error management with user-friendly feedback throughout the app

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
- **Debug APK builds** for pull requests (no Firebase config needed)
- **Release APK builds** for main branch (with secure Firebase config from GitHub secrets)
- Automated testing with comprehensive coverage reporting
- Code quality checks and security scanning

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
- Service layer classes are designed for easy unit testing with dependency injection

## 📊 Analytics Events

The app logs comprehensive events to Firebase Analytics:

```dart
// Screen tracking
screen_view(screen_name: 'EntriesScreen')

// Authentication events
login(login_method: 'password')
sign_up(sign_up_method: 'password')
user_logout()

// Entry management
entry_created(entry_id: string, text_length: number, user_id: string)
entry_deleted(entry_id: string, user_id: string)
entry_updated(entry_id: string, text_length: number, user_id: string)

// Feature usage
feature_usage(feature_name: string, parameters: Map)
date_visibility_toggle(entry_id: string, show_date: bool)

// Error tracking
app_error(error_type: string, error_message: string)
```

**User Properties:**
- `app_version`: Current app version
- `user_type`: User classification

**Debugging:** Use Firebase Console → Analytics → DebugView for real-time viewing.

## 🔒 Security & Rules

### Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      // Allow the user to read/write their own user doc
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Nested "entries" collection for each user
      match /entries/{entryId} {
        // Only the owner can create, read, update, or delete entries
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

### Database Indexes
The app includes optimized Firestore indexes for better query performance:
- `entries` collection: `createdAt` (descending) - Used for real-time entry listing

### Data Validation
- **Client-side:** Email format, password length (6+ chars), entry text validation
- **Server-side:** Firestore rules ensure data access control with principle of least privilege
- **Error Handling:** User-friendly error messages with proper error boundaries

## 🚀 Next Steps

- [ ] **Offline support:** Cache entries locally with Hive/SQLite
- [ ] **Dark mode:** Theme toggle with SharedPreferences
- [ ] **Entry editing:** Edit existing entries (Remote Config ready)
- [ ] **Batch operations:** Delete multiple entries (Remote Config ready)
- [ ] **Search & filter:** Search functionality and categories
- [ ] **Push notifications:** Real-time updates and reminders

### Performance Optimizations
- [ ] **Lazy loading:** Pagination for large datasets
- [ ] **Caching:** Local data persistence

### Accessibility & UX
- [ ] **Screen reader support:** Accessibility labels and semantics
- [ ] **Keyboard navigation:** Full keyboard support
- [ ] **Internationalization:** Multi-language support

## 📚 Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Material 3 Design](https://m3.material.io/)
- [Firebase Emulator Suite](https://firebase.google.com/docs/emulator-suite)