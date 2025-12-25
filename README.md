# Islamic App

> Comprehensive guide for AI assistants working on this Islamic Flutter application

## Table of Contents

- [Project Overview](#project-overview)
- [Architecture Overview](#architecture-overview)
- [Directory Structure](#directory-structure)
- [Key Technologies](#key-technologies)
- [Development Conventions](#development-conventions)
- [Git Workflow](#git-workflow)
- [Common Tasks](#common-tasks)
- [API Integrations](#api-integrations)
- [Security Considerations](#security-considerations)
- [Testing Guidelines](#testing-guidelines)
- [Important Files Reference](#important-files-reference)

---

## Project Overview

**Islamic App** is a comprehensive Flutter mobile application providing Islamic resources and utilities including:

- **Authentication**: Email/password and Google OAuth via Firebase
- **Qibla Finder**: Compass-based direction to Mecca using device sensors
- **Nearest Mosques**: Google Maps integration for finding nearby mosques
- **Prayer Times**: Integration with Aladhan API (in progress)
- **Quran**: Quran Cloud API integration (in progress)
- **Hadith**: Islamic traditions and sayings (in progress)
- **Azkar**: Islamic remembrances and supplications (in progress)
- **Calendar**: Islamic calendar (in progress)
- **Community**: Social features for Muslim community (in progress)

**Version**: 1.0.0+1
**Dart SDK**: ^3.9.2
**Supported Platforms**: Android, iOS
**Languages**: Arabic (primary), English

---

## Architecture Overview

### Clean Architecture Layers

The project follows **Clean Architecture** principles with clear separation of concerns:

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  (UI, Screens, Widgets, State Updates)  │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│           Logic Layer                    │
│     (BLoC/Cubit, State Management)       │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│          Domain Layer                    │
│  (Business Logic, Repository Interfaces) │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│           Data Layer                     │
│ (Repository Impl, DataSources, Models)   │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│           Core Layer                     │
│ (Utils, Constants, Network, Theme, DI)   │
└──────────────────────────────────────────┘
```

### State Management

**Pattern**: BLoC (Business Logic Component) using `flutter_bloc` package

**Key Principles**:

- Each feature has its own Cubit/BLoC
- States are immutable (using `equatable`)
- Dependency injection via GetIt
- Reactive UI updates with BlocBuilder/BlocListener

**Example Flow**:

```
User Action → Cubit Method → Repository → DataSource → API/Database
                ↓
           Emit State
                ↓
        UI Rebuild (BlocBuilder)
```

---

## Directory Structure

```
lib/
├── core/                              # Cross-cutting concerns
│   ├── constants/                     # App-wide constants
│   │   ├── api_constants.dart         # API endpoints and keys
│   │   ├── app_colors.dart            # Color palette
│   │   ├── app_constants.dart         # General constants
│   │   └── storage_constants.dart     # Hive box names
│   ├── errors/
│   │   └── failures.dart              # Custom failure types
│   ├── network/
│   │   ├── connectivity_helper.dart   # Network status monitoring
│   │   └── dio_client.dart            # HTTP client singleton
│   ├── routes/
│   │   ├── app_routes.dart            # Route constants
│   │   └── app_router.dart            # GoRouter configuration
│   ├── services/
│   │   └── image_picker_service.dart  # Image selection utility
│   ├── theme/
│   │   └── app_theme.dart             # Light/Dark themes
│   └── utils/
│       ├── cache_helper.dart          # Hive abstraction layer
│       ├── image_helper.dart          # Image processing utilities
│       └── service_locator.dart       # GetIt DI setup
│
├── data/                              # Data layer
│   ├── datasources/
│   │   ├── local/
│   │   │   └── auth_local_datasource.dart     # Hive storage
│   │   └── remote/
│   │       ├── auth_remote_datasource.dart    # Firebase Auth
│   │       └── user_firestore_datasource.dart # Firestore operations
│   ├── models/
│   │   └── user/
│   │       └── user_model.dart        # User data model
│   └── repositories/
│       └── auth_repository_impl.dart  # Repository implementation
│
├── domain/                            # Business logic
│   └── repositories/
│       └── auth_repository.dart       # Abstract repository interface
│
├── logic/                             # State management
│   └── cubits/
│       └── auth/
│           ├── auth_cubit.dart        # Auth business logic
│           └── auth_state.dart        # Auth states
│
├── presentation/                      # UI layer
│   ├── screens/
│   │   ├── auth/                      # Login/Register screens
│   │   ├── home/                      # Main dashboard
│   │   ├── qibla/                     # Qibla finder feature
│   │   ├── nearest_masjed/            # Mosque locator feature
│   │   ├── prayer_times/              # Prayer schedule (WIP)
│   │   ├── quran/                     # Quran reader (WIP)
│   │   ├── hadith/                    # Hadith collection (WIP)
│   │   ├── azkar/                     # Islamic remembrances (WIP)
│   │   ├── calendar/                  # Islamic calendar (WIP)
│   │   ├── community/                 # Social features (WIP)
│   │   ├── profile/                   # User profile
│   │   └── settings/                  # App settings
│   └── widgets/
│       ├── auth/                      # Auth-specific widgets
│       └── common/                    # Reusable widgets
│
└── main.dart                          # App entry point
```

### Asset Structure

```
assets/
├── lang/                              # Localization files
│   ├── ar.json                        # Arabic translations
│   └── en.json                        # English translations
├── azkar_json/                        # Azkar data (planned)
├── images/                            # App images (planned)
└── sounds/
    └── adhan/                         # Prayer call audio (planned)
```

---

## Key Technologies

### Core Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_bloc` | ^8.1.6 | State management |
| `get_it` | ^7.6.7 | Dependency injection |
| `go_router` | ^14.7.0 | Navigation with auth guards |
| `firebase_core` | ^3.6.0 | Firebase initialization |
| `firebase_auth` | ^5.3.1 | User authentication |
| `cloud_firestore` | ^5.4.4 | Cloud database |
| `google_sign_in` | ^6.2.2 | Google OAuth |
| `hive` / `hive_flutter` | ^2.2.3 / ^1.1.0 | Local storage |
| `dio` | ^5.7.0 | HTTP client |
| `google_maps_flutter` | ^2.13.1 | Maps integration |
| `geolocator` | ^14.0.2 | Location services |
| `flutter_compass` | ^0.8.1 | Compass for Qibla |
| `easy_localization` | ^3.0.5 | Internationalization |
| `flutter_screenutil` | ^5.9.3 | Responsive UI |
| `dartz` | ^0.10.1 | Functional programming |
| `equatable` | ^2.0.7 | Value equality |
| `image_picker` | ^1.0.7 | Image selection |
| `flutter_image_compress` | ^2.1.0 | Image optimization |

### Design Patterns Used

1. **Singleton**: DioClient, ConnectivityHelper, Service Locator
2. **Repository Pattern**: Abstract interfaces in domain, implementations in data
3. **Data Source Pattern**: Separation of remote (Firebase/API) and local (Hive) data
4. **Service Locator**: GetIt for dependency injection
5. **Factory Pattern**: Cubit instances via GetIt factories
6. **BLoC Pattern**: State management throughout the app
7. **Either/Fold**: Functional error handling using Dartz

---

## Development Conventions

### Code Style

1. **Naming Conventions**:
   - Classes: `PascalCase` (e.g., `AuthCubit`, `UserModel`)
   - Files: `snake_case` (e.g., `auth_cubit.dart`, `user_model.dart`)
   - Variables/Functions: `camelCase` (e.g., `signInWithEmail`, `userData`)
   - Constants: `camelCase` or `SCREAMING_SNAKE_CASE` for compile-time constants
   - Private members: prefix with `_` (e.g., `_userId`)

2. **Linting**: Follow Flutter recommended lints (defined in `analysis_options.yaml`)

3. **Import Organization**:

   ```dart
   // Dart SDK imports
   import 'dart:async';

   // Flutter imports
   import 'package:flutter/material.dart';

   // Third-party package imports
   import 'package:flutter_bloc/flutter_bloc.dart';

   // Project imports
   import 'package:islamic_app/core/constants/app_colors.dart';
   ```

4. **File Organization**:
   - Each screen has its own directory
   - Related widgets stay with their parent screen
   - Shared widgets go in `presentation/widgets/common/`

### State Management Conventions

**Cubit/BLoC Structure**:

```dart
// State file (auth_state.dart)
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final UserModel user;
  AuthAuthenticated(this.user);
  @override
  List<Object?> get props => [user];
}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

// Cubit file (auth_cubit.dart)
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  AuthCubit(this._repository) : super(AuthInitial());

  Future<void> signIn(String email, String password) async {
    emit(AuthLoading());
    final result = await _repository.signIn(email, password);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }
}
```

**UI Integration**:

```dart
BlocBuilder<AuthCubit, AuthState>(
  builder: (context, state) {
    if (state is AuthLoading) {
      return CircularProgressIndicator();
    } else if (state is AuthAuthenticated) {
      return Text('Welcome ${state.user.name}');
    } else if (state is AuthError) {
      return Text('Error: ${state.message}');
    }
    return LoginForm();
  },
)
```

### Error Handling

Use **Either** pattern from Dartz for operations that can fail:

```dart
// Repository interface
abstract class AuthRepository {
  Future<Either<Failure, UserModel>> signIn({
    required String email,
    required String password,
  });
}

// Implementation
Future<Either<Failure, UserModel>> signIn({
  required String email,
  required String password,
}) async {
  try {
    final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = await _getUserData(userCredential.user!.uid);
    return Right(user);
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      return Left(UserNotFoundFailure('No user found with this email'));
    } else if (e.code == 'wrong-password') {
      return Left(InvalidCredentialsFailure('Incorrect password'));
    }
    return Left(AuthFailure(e.message ?? 'Authentication failed'));
  } catch (e) {
    return Left(ServerFailure(e.toString()));
  }
}
```

**Available Failure Types** (see `lib/core/errors/failures.dart`):

- `AuthFailure`
- `ServerFailure`
- `NetworkFailure`
- `CacheFailure`
- `InvalidCredentialsFailure`
- `UserNotFoundFailure`
- `EmailAlreadyInUseFailure`
- `WeakPasswordFailure`

### Dependency Injection

All services and cubits are registered in `lib/core/utils/service_locator.dart`:

```dart
final getIt = GetIt.instance;

void setupServiceLocator() {
  // Network services (singleton - same instance throughout app lifecycle)
  getIt.registerLazySingleton(() => DioClient.instance);
  getIt.registerLazySingleton(() => ConnectivityHelper());

  // Data sources (singleton)
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(),
  );

  // Repositories (singleton)
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
    ),
  );

  // Cubits (factory - new instance each time)
  getIt.registerFactory(
    () => AuthCubit(getIt<AuthRepository>()),
  );
}
```

**Usage in code**:

```dart
// Get a cubit instance
final authCubit = getIt<AuthCubit>();

// Get a singleton service
final dio = getIt<DioClient>();
```

### Localization

Use `easy_localization` package with `.tr()` extension:

```dart
// In JSON files (assets/lang/ar.json, assets/lang/en.json)
{
  "app_name": "Islamic App",
  "login": "Login",
  "register": "Register"
}

// In code
Text('login'.tr()),  // Displays localized text
```

**Supported locales**: Arabic (ar), English (en)
**Fallback locale**: Arabic

### Responsive Design

Use `flutter_screenutil` for responsive sizing:

```dart
// In main.dart, app is wrapped with ScreenUtilInit
ScreenUtilInit(
  designSize: const Size(375, 812), // iPhone X dimensions
  minTextAdapt: true,
  splitScreenMode: true,
  builder: (context, child) => MaterialApp(...),
)

// In widgets
Container(
  width: 200.w,      // Responsive width
  height: 100.h,     // Responsive height
  padding: EdgeInsets.all(16.r),  // Responsive padding
  child: Text(
    'Hello',
    style: TextStyle(fontSize: 18.sp),  // Responsive font size
  ),
)
```

---

## Git Workflow

### Branch Strategy

The project uses **Git Flow** with the following branch structure:

```
main (Production)
  ↑
  Merge from developer after full testing
  │
developer (Active Development)
  ↑
  Merge from feature branches after code review
  │
feature/* (Feature Branches)
  Examples:
  - feature/prayer-times-ui
  - feature/quran-reader
  - feature/fix-qibla-bug
```

### Workflow Steps

1. **Start New Feature**:

   ```bash
   # Update developer branch
   git checkout developer
   git pull origin developer

   # Create feature branch
   git checkout -b feature/feature-name
   ```

2. **Work on Feature**:

   ```bash
   # Make changes, then commit
   git add .
   git commit -m "feat: add prayer times calculation"

   # Push to remote
   git push origin feature/feature-name
   ```

3. **Create Pull Request**:
   - Go to GitHub repository
   - Click "Compare & pull request"
   - Set **base: developer** ← **compare: feature/feature-name**
   - Add clear description
   - Wait for code review approval

4. **After Merge**:

   ```bash
   # Switch back to developer
   git checkout developer
   git pull origin developer

   # Delete local feature branch
   git branch -d feature/feature-name
   ```

### Commit Message Convention

Follow this format: `<type>: <description>`

**Types**:

- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `style:` - Code formatting (no logic change)
- `refactor:` - Code restructuring
- `test:` - Adding/updating tests
- `chore:` - Build process, dependencies

**Examples**:

```bash
git commit -m "feat: add quran surah list with audio playback"
git commit -m "fix: resolve prayer time calculation for southern hemisphere"
git commit -m "refactor: extract common API logic to base service"
git commit -m "docs: update README with new features"
```

### Important Rules

- Never push directly to `main` or `developer`
- Never force push to shared branches
- All features must go through PR review
- Delete feature branches after merge
- Keep commits atomic and well-described

---

## Common Tasks

### Running the App

```bash
# Get dependencies
flutter pub get

# Run on connected device/emulator
flutter run

# Run on specific device
flutter devices
flutter run -d <device-id>

# Run in release mode
flutter run --release
```

### Building

```bash
# Build APK (Android)
flutter build apk --release

# Build App Bundle (Android - for Play Store)
flutter build appbundle --release

# Build iOS (requires macOS)
flutter build ios --release
```

### Firebase Configuration

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Configure FlutterFire
flutterfire configure
```

### Adding New Dependencies

1. Add to `pubspec.yaml`:

   ```yaml
   dependencies:
     new_package: ^1.0.0
   ```

2. Get packages:

   ```bash
   flutter pub get
   ```

### Creating a New Feature

1. **Create feature directory structure**:

   ```
   lib/presentation/screens/new_feature/
   ├── data/
   │   ├── models/
   │   └── repositories/
   ├── presentation/
   │   ├── cubit/
   │   ├── screens/
   │   └── widgets/
   ```

2. **Register routes** in `lib/core/routes/app_routes.dart`:

   ```dart
   static const String newFeature = '/new-feature';
   ```

3. **Add route configuration** in `lib/core/routes/app_router.dart`:

   ```dart
   GoRoute(
     path: AppRoutes.newFeature,
     builder: (context, state) => const NewFeatureScreen(),
   ),
   ```

4. **Create Cubit for state management**:

   ```dart
   // new_feature_state.dart
   abstract class NewFeatureState extends Equatable {}

   // new_feature_cubit.dart
   class NewFeatureCubit extends Cubit<NewFeatureState> {
     NewFeatureCubit() : super(NewFeatureInitial());
   }
   ```

5. **Register in service locator** (if needed):

   ```dart
   // In service_locator.dart
   getIt.registerFactory(() => NewFeatureCubit());
   ```

### Adding API Integration

1. **Add API endpoint** to `lib/core/constants/api_constants.dart`:

   ```dart
   static const String newApiBase = 'https://api.example.com/v1';
   ```

2. **Create data source**:

   ```dart
   // lib/data/datasources/remote/new_feature_remote_datasource.dart
   abstract class NewFeatureRemoteDataSource {
     Future<NewFeatureModel> fetchData();
   }

   class NewFeatureRemoteDataSourceImpl implements NewFeatureRemoteDataSource {
     final DioClient _dioClient;

     @override
     Future<NewFeatureModel> fetchData() async {
       final response = await _dioClient.get('/endpoint');
       return NewFeatureModel.fromJson(response.data);
     }
   }
   ```

3. **Create repository**:

   ```dart
   // lib/domain/repositories/new_feature_repository.dart
   abstract class NewFeatureRepository {
     Future<Either<Failure, NewFeatureModel>> fetchData();
   }

   // lib/data/repositories/new_feature_repository_impl.dart
   class NewFeatureRepositoryImpl implements NewFeatureRepository {
     final NewFeatureRemoteDataSource _remoteDataSource;

     @override
     Future<Either<Failure, NewFeatureModel>> fetchData() async {
       try {
         final data = await _remoteDataSource.fetchData();
         return Right(data);
       } catch (e) {
         return Left(ServerFailure(e.toString()));
       }
     }
   }
   ```

### Adding Localization Keys

1. **Add to both language files**:

   `assets/lang/en.json`:

   ```json
   {
     "new_key": "New Text"
   }
   ```

   `assets/lang/ar.json`:

   ```json
   {
     "new_key": "نص جديد"
   }
   ```

2. **Use in code**:

   ```dart
   Text('new_key'.tr())
   ```

---

## API Integrations

### Configured APIs

| API | Base URL | Purpose | Status |
|-----|----------|---------|--------|
| **Aladhan API** | `https://api.aladhan.com/v1` | Prayer times calculation | Configured |
| **Quran Cloud API** | `https://api.alquran.cloud/v1` | Quran verses and translations | Configured |
| **Google Maps API** | `https://maps.googleapis.com/maps/api` | Nearby mosques | Active |
| **Firebase Auth** | Firebase SDK | User authentication | Active |
| **Cloud Firestore** | Firebase SDK | User data storage | Active |

### API Keys Location

**File**: `lib/core/constants/api_constants.dart`

```dart
class ApiConstants {
  // Aladhan API for Prayer Times
  static const String aladhanBase = 'https://api.aladhan.com/v1';

  // Quran Cloud API
  static const String quranApiBase = 'https://api.alquran.cloud/v1';

  // Google Maps API
  static final String googleApiKey = 'AIzaSyAST6--iNxDrqzA80FCBHcuvsogcLgGxkk';
}
```

### Making API Calls

Use the `DioClient` singleton:

```dart
final dioClient = getIt<DioClient>();

// GET request
final response = await dioClient.get('/endpoint');

// POST request
final response = await dioClient.post(
  '/endpoint',
  data: {'key': 'value'},
);

// With query parameters
final response = await dioClient.get(
  '/endpoint',
  queryParameters: {'param1': 'value1'},
);
```

### Firebase Integration

**Authentication**:

```dart
// Sign in with email
final authRemoteDataSource = getIt<AuthRemoteDataSource>();
await authRemoteDataSource.signInWithEmail(email, password);

// Sign in with Google
await authRemoteDataSource.signInWithGoogle();

// Sign out
await authRemoteDataSource.signOut();
```

**Firestore Operations**:

```dart
// Get user data
final userFirestore = getIt<UserFirestoreDataSource>();
final userData = await userFirestore.getUserData(userId);

// Update user data
await userFirestore.updateUserData(userId, updatedData);
```

---

## Security Considerations

### API Keys

**CRITICAL SECURITY ISSUE**: Google Maps API key is currently exposed in source code at:

- `lib/core/constants/api_constants.dart:24`

**Recommendation for AI Assistants**:

- When adding new API keys, suggest using environment variables or backend proxy
- Never commit sensitive credentials to version control
- Consider moving API key to `.env` file with `flutter_dotenv` package

### Firebase Security

- Firebase Auth tokens are automatically managed by Firebase SDK
- User authentication state is persisted securely
- Firestore rules should be configured in Firebase Console (not in code)

### Local Storage Security

**Current Implementation**: Hive without encryption

**Recommendation**:

- For production, implement Hive encryption:

  ```dart
  import 'package:hive/hive.dart';
  import 'package:flutter_secure_storage/flutter_secure_storage.dart';

  final secureStorage = FlutterSecureStorage();
  final encryptionKey = await secureStorage.read(key: 'hive_key');
  final box = await Hive.openBox(
    'secure_box',
    encryptionCipher: HiveAesCipher(encryptionKey),
  );
  ```

### Image Upload Security

Images are:

1. Compressed to max 150KB
2. Converted to Base64
3. Stored in Firestore (current implementation)

**Recommendation**: Move to Firebase Storage for better scalability:

```dart
final storageRef = FirebaseStorage.instance.ref('user_photos/$userId.jpg');
await storageRef.putFile(imageFile);
final downloadUrl = await storageRef.getDownloadURL();
```

---

## Testing Guidelines

### Current Test Setup

**Test Framework**: Flutter Test
**Test Directory**: `test/`
**Coverage**: Minimal (only placeholder test exists)

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage

# View coverage report (requires lcov)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Writing Tests

**Unit Test Example** (for repositories):

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';

void main() {
  late AuthRepository repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
    );
  });

  group('signIn', () {
    test('should return UserModel when sign in is successful', () async {
      // Arrange
      final userModel = UserModel(id: '1', name: 'Test User');
      when(mockRemoteDataSource.signIn(any, any))
        .thenAnswer((_) async => userModel);

      // Act
      final result = await repository.signIn(
        email: 'test@test.com',
        password: 'password',
      );

      // Assert
      expect(result, Right(userModel));
      verify(mockRemoteDataSource.signIn('test@test.com', 'password'));
    });
  });
}
```

**Widget Test Example**:

```dart
void main() {
  testWidgets('LoginScreen shows error on invalid credentials', (tester) async {
    // Build the widget
    await tester.pumpWidget(
      MaterialApp(home: LoginScreen()),
    );

    // Find widgets
    final emailField = find.byType(TextField).first;
    final passwordField = find.byType(TextField).last;
    final loginButton = find.text('Login');

    // Enter text
    await tester.enterText(emailField, 'invalid@email.com');
    await tester.enterText(passwordField, 'wrong');

    // Tap button
    await tester.tap(loginButton);
    await tester.pump();

    // Verify error message appears
    expect(find.text('Invalid credentials'), findsOneWidget);
  });
}
```

### Test Coverage Priorities

1. **Critical**: Authentication flows (login, register, logout)
2. **High**: Repository implementations
3. **High**: Cubit/BLoC state transitions
4. **Medium**: Utility functions (cache_helper, image_helper)
5. **Medium**: Widget tests for custom widgets
6. **Low**: UI screens (can be tested manually)

---

## Important Files Reference

### Configuration Files

| File | Purpose | When to Modify |
|------|---------|----------------|
| `pubspec.yaml` | Dependencies, assets, app metadata | Adding packages, assets |
| `firebase.json` | Firebase project configuration | Changing Firebase project |
| `analysis_options.yaml` | Dart linting rules | Adjusting code standards |
| `lib/firebase_options.dart` | Auto-generated Firebase config | Never (regenerate with FlutterFire CLI) |

### Core Files

| File | Purpose | Key Responsibilities |
|------|---------|---------------------|
| `lib/main.dart` | App entry point | Initialization, root widget |
| `lib/core/utils/service_locator.dart` | Dependency injection | Register all services/cubits |
| `lib/core/routes/app_router.dart` | Navigation configuration | Route definitions, auth guards |
| `lib/core/constants/api_constants.dart` | API endpoints and keys | All external API configurations |
| `lib/core/theme/app_theme.dart` | App theming | Light/Dark theme definitions |
| `lib/core/network/dio_client.dart` | HTTP client | API call configuration |

### Feature Files (Example: Auth)

| File | Purpose |
|------|---------|
| `lib/logic/cubits/auth/auth_cubit.dart` | Auth business logic |
| `lib/logic/cubits/auth/auth_state.dart` | Auth state definitions |
| `lib/domain/repositories/auth_repository.dart` | Auth repository interface |
| `lib/data/repositories/auth_repository_impl.dart` | Auth repository implementation |
| `lib/data/datasources/remote/auth_remote_datasource.dart` | Firebase Auth operations |
| `lib/data/datasources/local/auth_local_datasource.dart` | Local auth cache |
| `lib/data/models/user/user_model.dart` | User data structure |
| `lib/presentation/screens/auth/login_screen.dart` | Login UI |

### Asset Files

| Path | Contents |
|------|----------|
| `assets/lang/ar.json` | Arabic translations |
| `assets/lang/en.json` | English translations |
| `android/app/google-services.json` | Android Firebase config |
| `ios/Runner/GoogleService-Info.plist` | iOS Firebase config |

---

## Tips for AI Assistants

### When Adding Features

1. **Always follow Clean Architecture**:
   - Start with domain (repository interface)
   - Implement data layer (repository impl, data sources)
   - Create logic layer (cubit/state)
   - Build presentation layer (screens, widgets)

2. **Use existing patterns**:
   - Check how Auth feature is structured
   - Look at Qibla or Nearest Mosque features for reference
   - Maintain consistency with existing code style

3. **Register dependencies**:
   - Add new services/cubits to `service_locator.dart`
   - Use singleton for services, factory for cubits

4. **Add routes**:
   - Define route constant in `app_routes.dart`
   - Configure route in `app_router.dart`

5. **Handle errors properly**:
   - Use Either<Failure, Success> pattern
   - Create specific Failure types if needed
   - Emit error states in cubits

### When Debugging

1. **Check these first**:
   - Is service registered in service_locator?
   - Is route configured in app_router?
   - Are BlocProviders set up correctly?
   - Are localization keys present in both language files?

2. **Common issues**:
   - Missing Firebase configuration: Regenerate with `flutterfire configure`
   - Build errors: Run `flutter clean && flutter pub get`
   - State not updating: Check if state is emitting correctly in cubit
   - Navigation not working: Verify route is defined in both app_routes and app_router

### When Refactoring

1. **Never break existing features** - test before committing
2. **Update tests** if changing logic
3. **Update documentation** if changing architecture
4. **Follow git workflow** - create feature branch for refactoring

### Code Quality Checklist

Before committing code, verify:

- [ ] No hardcoded strings (use localization or constants)
- [ ] No exposed API keys or secrets
- [ ] Error handling implemented (try-catch or Either)
- [ ] State management follows existing patterns
- [ ] Code follows Flutter lints (no warnings)
- [ ] Responsive sizing using ScreenUtil
- [ ] Comments added for complex logic
- [ ] Unused imports removed
- [ ] Debug print statements removed

---

## Quick Reference Commands

```bash
# Development
flutter pub get                    # Get dependencies
flutter run                        # Run app
flutter run -d chrome              # Run on web (if enabled)
flutter clean                      # Clean build artifacts

# Building
flutter build apk --release        # Build Android APK
flutter build appbundle            # Build Android App Bundle
flutter build ios --release        # Build iOS (macOS only)

# Testing
flutter test                       # Run all tests
flutter test --coverage            # Run tests with coverage

# Firebase
flutterfire configure              # Configure Firebase
firebase deploy --only firestore   # Deploy Firestore rules

# Git
git checkout developer             # Switch to developer branch
git pull origin developer          # Update developer branch
git checkout -b feature/name       # Create feature branch
git add .                          # Stage changes
git commit -m "feat: description"  # Commit with message
git push origin feature/name       # Push feature branch

# Code Analysis
flutter analyze                    # Run static analysis
dart format .                      # Format all Dart files
```

---

## Project Status Summary

### Implemented Features

- Authentication (Email, Google)
- User Profile Management
- Qibla Finder with Compass
- Nearest Mosques with Google Maps
- Basic Settings Screen

### In Progress

- Prayer Times (API configured, UI pending)
- Quran Reader (API configured, UI pending)
- Hadith Collection (UI pending)
- Azkar/Supplications (UI pending)
- Islamic Calendar (UI pending)
- Community Features (UI pending)

### Technical Debt

- Low test coverage (only placeholder test exists)
- Google Maps API key exposed in code
- Hive storage not encrypted
- Some duplicate code in main.dart (nested MaterialApp)
- Typo in folder name: "persentation" should be "presentation" (in qibla and nearest_masjed features)

---

## Resources

- **Flutter Documentation**: <https://docs.flutter.dev/>
- **Flutter BLoC Documentation**: <https://bloclibrary.dev/>
- **Firebase for Flutter**: <https://firebase.google.com/docs/flutter/setup>
- **Aladhan API Docs**: <https://aladhan.com/prayer-times-api>
- **Quran Cloud API**: <https://alquran.cloud/api>
- **Go Router Documentation**: <https://pub.dev/packages/go_router>

---

**Last Updated**: 2025-11-14
**App Version**: 1.0.0+1
**Maintainer**: Ahmed (@engAhmedSami)

---

*This document is intended for AI assistants to understand the codebase structure and development conventions. Keep it updated as the project evolves.*
