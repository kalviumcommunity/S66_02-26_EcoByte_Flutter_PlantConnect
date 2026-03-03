# plantconnect

 A Flutter project — PlantConnect app (inner `plantconnect` folder).

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
 [online documentation](https://docs.flutter.dev/).

---

## 🔥 Firebase Integration Setup

### Overview
PlantConnect is now integrated with **Firebase** for backend services including:
- **Authentication** - User login/signup and account management
- **Cloud Firestore** - Real-time database for plant data and user information
- **Cloud Storage** - Storing images and media files

This setup enables the app to have a scalable backend without managing servers.

### Setup Steps Completed

#### 1. **Initialize Firebase in main.dart**

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Firebase has been successfully initialized!');
  runApp(const MyApp());
}
```

**Key points:**
- `WidgetsFlutterBinding.ensureInitialized()` ensures Flutter engine is ready before async operations
- `Firebase.initializeApp()` initializes Firebase using platform-specific configuration
- `DefaultFirebaseOptions.currentPlatform` automatically selects the correct Firebase config for the platform

#### 2. **Firebase Configuration File**

**Location:** `plantconnect/lib/firebase_options.dart`

This auto-generated file contains platform-specific Firebase credentials:
- **Web**: API keys, Auth Domain, Storage Bucket, Measurement ID
- **Android**: API keys and project credentials
- **iOS**: API keys, Bundle ID, and app identifiers
- **Windows**: Web configuration adapted for Windows desktop

```dart
class DefaultFirebaseOptions {
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDE4TnwmTX5Y01q41yc2Gf9fYFDeOU2u6E',
    appId: '1:82423488286:web:5193239531141b6eeeb30f',
    projectId: 'plantconnect-7dd0c',
    authDomain: 'plantconnect-7dd0c.firebaseapp.com',
    storageBucket: 'plantconnect-7dd0c.firebasestorage.app',
  );
  // ... Android, iOS, Windows configs follow
}
```

#### 3. **Dependencies in pubspec.yaml**

The following Firebase packages were added:

```yaml
dependencies:
  firebase_core: ^3.15.2           # Core Firebase SDK
  firebase_auth: ^5.7.0             # Authentication
  cloud_firestore: ^5.6.12          # Real-time database
```

Run `flutter pub get` to install these dependencies.

#### 4. **Google Services Configuration**

**For Android:** `plantconnect/android/app/google-services.json`
- Contains Android-specific Firebase project credentials
- Downloaded from Firebase Console

**For iOS:** Configured via Flutter Firebase CLI

### Firebase Project Details

- **Project ID:** `plantconnect-7dd0c`
- **Apps Registered in Firebase Console:**
  - Android: `com.android.application`
  - iOS: `com.example.plantconnect`
  - Web: `plantconnect (web)`
  - Windows: `plantconnect (windows)`

### Verification

✅ **Firebase Initialization Confirmed**
- All apps are registered in Firebase Console under "Your Apps"
- Firebase is initialized on app startup (check console for "Firebase has been successfully initialized!" message)
- Services ready for authentication and data operations

### Folder Structure

```
plantconnect/
├── lib/
│   ├── firebase_options.dart          # Firebase configuration
│   ├── main.dart                      # Firebase initialization
│   ├── services/
│   │   ├── auth_service.dart          # Authentication logic
│   │   └── firestore_service.dart     # Firestore operations
│   └── ...
├── android/
│   └── app/google-services.json       # Android Firebase config
└── pubspec.yaml                       # Dependencies
```

---

## 🎯 Reflection

### Most Important Step in Firebase Integration

**Initializing Firebase in `main.dart` before `runApp()`** is the most critical step. Without this:
- The app cannot connect to Firebase services
- Authentication, Firestore, and Storage operations will fail
- The app will crash when trying to use Firebase features

Using `WidgetsFlutterBinding.ensureInitialized()` first is essential because Firebase initialization is asynchronous and requires Flutter's engine to be fully loaded.

### Errors Encountered and Fixes

1. **Icon Reference Error** (`Icons.assess` not found)
   - **Fix:** Replaced with valid `Icons.analytics` icon in responsive_layout.dart
   - **Lesson:** Always verify Flutter icon names from the Material Design icon library

2. **Visual Studio Not Installed** (Windows desktop build)
   - **Fix:** Tested app on Chrome web platform instead
   - **Lesson:** Environment setup varies by target platform; Flutter doctor helps identify missing dependencies

### How Firebase Setup Prepares the App

**Authentication Ready:**
- Users can sign up, log in, and manage accounts
- Firebase Auth service (`auth_service.dart`) can now handle user registration
- Session management and password reset flows are enabled

**Database Ready:**
- Cloud Firestore is initialized and can store plant data, user profiles, care schedules
- Real-time sync means changes are instant across devices
- Firestore service (`firestore_service.dart`) can read/write collections and documents

**Storage Ready:**
- Users can upload plant photos and documents
- Cloud Storage is connected for file uploads/downloads
- Plant images can be stored and retrieved securely

**Security Foundation:**
- Firebase Security Rules will protect data access
- Authentication ensures only authorized users access their data
- Project is ready for implementing role-based access control

Next step: Implement user login screen and Firestore operations to fully utilize Firebase capabilities.

---

## ⚙️ FlutterFire CLI Integration

### What is FlutterFire CLI?

The **FlutterFire CLI** is a command-line tool that simplifies connecting Flutter projects to Firebase by automating configuration across all platforms. Instead of manually editing files like `google-services.json` or Gradle configs, the CLI handles everything automatically.

**Advantages of using FlutterFire CLI:**
- ✅ Automatic generation of platform-specific config files (Android, iOS, macOS, Web, Windows)
- ✅ Prevents manual configuration errors that break builds
- ✅ Maintains consistent Firebase SDK versions across all platforms
- ✅ One command for multi-platform setup: `flutterfire configure`
- ✅ Automatically generates `lib/firebase_options.dart` with all credentials

### Installation Steps

#### Prerequisites
Before installing FlutterFire CLI, ensure you have:
- Flutter SDK and Dart installed
- Node.js and npm installed (required for Firebase tools)
- Google account with Firebase project created

#### Step 1: Install Firebase Tools

```bash
npm install -g firebase-tools
```

This installs the Firebase CLI globally, which manages Firebase authentication and project operations.

#### Step 2: Install FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

This activates the FlutterFire CLI tool in your Dart environment.

#### Step 3: Verify Installation

```bash
flutterfire --version
```

Expected output: `FlutterFire CLI v0.2.7` (version number may vary)

### Configuration and Setup

#### Step 1: Login to Firebase

```bash
firebase login
```

A browser window opens where you authenticate with your Google account. Use the same account that created your Firebase project (`plantconnect-7dd0c`).

#### Step 2: Run FlutterFire Configure

Inside your Flutter project directory (`plantconnect/`), run:

```bash
flutterfire configure
```

**What FlutterFire CLI does automatically:**
1. Detects all your Firebase projects
2. Asks you to select the project (we selected: `plantconnect-7dd0c`)
3. Detects target platforms (Android, iOS, Web, Windows, etc.)
4. Generates `lib/firebase_options.dart` with platform-specific credentials
5. Configures `android/` and other platform directories
6. Updates `pubspec.yaml` with required Firebase dependencies

#### Step 3: Verify Generated Configuration

After running `flutterfire configure`, check these files:

**Generated files:**
- `lib/firebase_options.dart` - Platform-specific Firebase options
- `android/app/google-services.json` - Android Firebase configuration
- `ios/Runner/GoogleService-Info.plist` - iOS Firebase configuration (if iOS target selected)

**Example structure in firebase_options.dart:**
```dart
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError('Platform not supported');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDE4TnwmTX5Y01q41yc2Gf9fYFDeOU2u6E',
    appId: '1:82423488286:web:5193239531141b6eeeb30f',
    projectId: 'plantconnect-7dd0c',
    authDomain: 'plantconnect-7dd0c.firebaseapp.com',
    storageBucket: 'plantconnect-7dd0c.firebasestorage.app',
    measurementId: 'G-PVC0CLCF8D',
  );
  // ... Android, iOS, Windows configs automatically generated
}
```

### Initialization in main.dart

Once `firebase_options.dart` is generated, initialize Firebase in your app:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('Firebase initialized via FlutterFire CLI!');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlantConnect',
      home: Scaffold(
        appBar: AppBar(title: const Text('Firebase Connected via CLI')),
        body: const Center(
          child: Text('Firebase SDK setup successful!'),
        ),
      ),
    );
  }
}
```

### Adding Additional Firebase Services

After initial setup with FlutterFire CLI, you can add more Firebase services:

```yaml
dependencies:
  firebase_core: ^3.15.2
  firebase_auth: ^5.7.0              # For authentication
  cloud_firestore: ^5.6.12           # For real-time database
  firebase_storage: ^11.0.0          # For file storage
  firebase_analytics: ^11.0.0        # For analytics (optional)
```

Run `flutter pub get` after updating `pubspec.yaml`. All services automatically use the credentials from `firebase_options.dart`.

### Common Issues and Solutions

| Issue | Cause | Solution |
|-------|-------|----------|
| `flutterfire: command not found` | CLI not in PATH | Run `dart pub global activate flutterfire_cli` again or add `~/.pub-cache/bin` to PATH |
| `Firebase project not found` | Not logged in to Firebase | Run `firebase login` first |
| `Build fails on Android` | Missing google-services.json or incorrect Gradle config | Re-run `flutterfire configure` and select Android platform |
| `MissingPluginException` during runtime | Firebase not initialized properly | Ensure `await Firebase.initializeApp()` runs before `runApp()` |
| Platform mismatch error | Selected wrong Firebase project | Delete `firebase_options.dart` and re-run `flutterfire configure` with correct project |

---

## 🎯 FlutterFire CLI Reflection

### How FlutterFire CLI Simplified Firebase Integration

**Before FlutterFire CLI (Manual Setup):**
- Had to manually download `google-services.json` from Firebase Console
- Manually edited `android/build.gradle.kts` and `android/app/build.gradle.kts` to add Google Services Gradle plugin
- Had to create `firebase_options.dart` by hand, copying credentials
- High risk of configuration errors and typos
- Different setup process needed for each platform

**After FlutterFire CLI (Automated Setup):**
- Single command: `flutterfire configure`
- CLI automatically detects platforms and generates all configs
- Credentials injected directly into Dart code
- No manual Gradle editing needed
- All platforms configured consistently in one pass
- Easy to update if Firebase credentials change

**Time saved:** Manual setup could take 30+ minutes per platform; FlutterFire CLI completes in <2 minutes for all platforms.

### Errors Encountered and Resolutions

1. **Icon Reference Error (`Icons.assess` not valid)**
   - **Cause:** Used deprecated icon that doesn't exist in Material Design
   - **Resolution:** Replaced with `Icons.analytics`
   - **Learning:** Always verify icon names in Flutter Material Design documentation

2. **Visual Studio Not Installed**
   - **Cause:** Windows desktop development requires Visual Studio with C++ workload
   - **Resolution:** Tested on Chrome web platform instead
   - **Learning:** `flutter doctor` reveals all missing dependencies; environment setup varies by target platform

3. **Firebase Initialization Timing Issue**
   - **Cause:** Firebase initialization attempted before Flutter engine was ready
   - **Resolution:** Added `WidgetsFlutterBinding.ensureInitialized()` before Firebase.initializeApp()
   - **Learning:** Async initialization in main() requires proper timing with Flutter lifecycle

### Why CLI-Based Setup is Preferred Over Manual Configuration

**1. Accuracy & Consistency**
   - CLI reads directly from Firebase Console, no transcription errors
   - All platforms get identical, verified credentials
   - One source of truth prevents sync issues

**2. Maintainability**
   - If you need to reconfigure (switch Firebase projects), run CLI again
   - No hunting through multiple config files
   - All credentials in one generated file (`firebase_options.dart`)

**3. Platform Support**
   - CLI handles Android, iOS, macOS, Windows, Web in one command
   - Different platforms need different credential formats; CLI handles this automatically
   - Manual setup would require platform-specific knowledge

**4. Development Speed**
   - One command vs. 10+ manual steps
   - Less time debugging config issues, more time coding features
   - Especially valuable for teams with multiple developers

**5. IDE Integration**
   - Generated `firebase_options.dart` is properly formatted Dart code
   - Full IDE support with autocompletion
   - Type safety ensures no string typos in credentials

**6. Future Updates**
   - If Firebase changes service requirements, FlutterFire CLI updates automatically
   - Manual setup would require you to track Firebase documentation changes

### Conclusion

FlutterFire CLI transforms Firebase setup from an error-prone manual process into a simple automated workflow. For **PlantConnect**, using the CLI ensured that:
- ✅ All platforms (Android, iOS, Web, Windows) are configured identically
- ✅ The app can initialize Firebase reliably on startup
- ✅ Future developers can regenerate configs without manual intervention
- ✅ The integration is production-ready and secure

---

## 📦 Firebase CLI & SDK Installation

### Installation Completed ✅

Both Firebase CLI tools have been successfully installed and verified:

#### Firebase CLI (Firebase Tools)
- **Version:** 15.8.0
- **Installed via:** `npm install -g firebase-tools`
- **Location:** `C:\Users\Acer\AppData\Roaming\npm\firebase.cmd`
- **Test Command:** 
  ```bash
  "C:\Users\Acer\AppData\Roaming\npm\firebase.cmd" --version
  # Output: 15.8.0
  ```

#### FlutterFire CLI
- **Version:** 1.3.1 
- **Installed via:** `dart pub global activate flutterfire_cli`
- **Status:** Built with working executables
- **Test Command:**
  ```bash
  dart pub global run flutterfire_cli:flutterfire --version
  # Output: FlutterFire CLI 1.3.1
  ```

### Firebase SDK (Already in Project)

Your Flutter project already includes all necessary Firebase packages:

```yaml
dependencies:
  firebase_core: ^3.0.0           # Core Firebase SDK
  firebase_auth: ^5.0.0            # Authentication
  cloud_firestore: ^5.0.0          # Real-time database
```

**Status:** ✅ All dependencies installed via `flutter pub get`

### How to Use the CLI Tools

#### Login to Firebase
```bash
"C:\Users\Acer\AppData\Roaming\npm\firebase.cmd" login
```

#### List Your Firebase Projects
```bash
"C:\Users\Acer\AppData\Roaming\npm\firebase.cmd" projects:list
```

#### Reconfigure Firebase for This Project
If you need to switch Firebase projects or regenerate credentials:

```bash
cd plantconnect
dart pub global run flutterfire_cli:flutterfire configure
```

This will:
1. Ask which Firebase project to use
2. Ask which platforms to configure (Android, iOS, Web, Windows, etc.)
3. Automatically regenerate `lib/firebase_options.dart` with new credentials
4. Update Android/iOS/Web configs as needed

#### Get FlutterFire CLI Help
```bash
dart pub global run flutterfire_cli:flutterfire --help
```

Available commands:
- `configure` - Configure Firebase for your Flutter app (generates firebase_options.dart)
- `install` - Install compatible version of Firebase plugins
- `reconfigure` - Update existing Firebase configuration
- `update` - Update Firebase plugin versions to latest

### Verification Steps Completed

✅ **Node.js & npm** - v22.20.0 and v10.9.3 installed  
✅ **Firebase CLI** - v15.8.0 installed successfully  
✅ **FlutterFire CLI** - v1.3.1 installed and built with executables  
✅ **Firebase SDK** - All packages installed in pubspec.yaml  
✅ **Firebase Config** - firebase_options.dart generated and credentials loaded  
✅ **App Registration** - All 4 apps registered in Firebase Console (Android, iOS, Web, Windows)  

### Next Steps

1. **Test the App:** Run `flutter run -d chrome` to launch on web
2. **Check Console:** Look for "Firebase has been successfully initialized!" message
3. **Monitor Firebase:** Visit Firebase Console to see real-time activity
4. **Implement Features:** Use auth_service.dart and firestore_service.dart to add login and data features

### Troubleshooting

If Firebase CLI is not recognized in your terminal:
- Use full path: `"C:\Users\Acer\AppData\Roaming\npm\firebase.cmd" login`
- Or add to PATH environment variable for global access

If FlutterFire CLI needs to be re-activated:
```bash
dart pub global deactivate flutterfire_cli
dart pub global activate flutterfire_cli
```

---

## ⚡ Hot Reload & DevTools Demo

This folder contains the PlantConnect Flutter app used for the demo. Follow these steps to demonstrate Flutter's **Hot Reload**, the **Debug Console**, and **Flutter DevTools**.

Quick steps to reproduce the demo (run inside the `plantconnect` folder):

1. Pull latest `main` and create/use the feature branch (done already, but include for reproducibility):

```bash
git checkout main
git fetch origin
git pull origin main
git checkout -b feat/hot-reload-devtools-demo
```

2. Run the app:

```bash
flutter pub get
flutter run
```

3. Apply Hot Reload:

- In the terminal running `flutter run`, press `r` to hot reload the app.
- In VS Code, click the ⚡ Hot Reload button in the debug toolbar.

4. Use the Debug Console:

- Add `debugPrint('My debug message');` in your code (for example in a button handler or `setState`).
- Observe output in the Debug Console in VS Code or in the terminal running `flutter run`.

5. Open Flutter DevTools:

- In VS Code while debugging, run the command "Open DevTools" and choose the Widget Inspector or Performance tab.
- Or from the terminal:

```bash
flutter pub global activate devtools
flutter pub global run devtools
```

Files to include in your PR

- `plantconnect/README.md` (this file — includes demo steps)
- `plantconnect/screenshots/hot_reload_after.png`
- `plantconnect/screenshots/debug_console_logs.png`
- `plantconnect/screenshots/devtools_widget_inspector.png`

Suggested commit message

```
chore: demonstrated use of Hot Reload, Debug Console, and DevTools
```

Suggested PR title

```
[Sprint-2] Hot Reload & DevTools Demonstration – TeamName
```

Next steps

- Add screenshots and a short 1–2 minute demo video link into the PR description.
- Commit and push the `plantconnect/screenshots/` directory and updated `plantconnect/README.md` to the existing branch so they appear in the same PR.

---

## Reusable Custom Widgets

This demo adds two reusable widgets under `lib/widgets/`:

- `InfoCard` — a `StatelessWidget` for displaying titled card rows.
- `CustomButton` — a small configurable button used across screens.

Files added:

- `plantconnect/lib/widgets/info_card.dart`
- `plantconnect/lib/widgets/custom_button.dart`

How I reused them

- `plantconnect/lib/screens/home_screen.dart` now shows `InfoCard` for account info.
- `plantconnect/lib/screens/second_screen.dart` uses `CustomButton` for navigation.

Try it locally

```bash
cd plantconnect
flutter pub get
flutter run
```

Suggested commit message for this change:

```
feat: created and reused custom widgets for modular UI design
```

---

## Responsive Design Demo

This repository includes a small responsive layout demo using `MediaQuery` and `LayoutBuilder`.

File added:

- `plantconnect/lib/screens/responsive_demo.dart`

How it works:

- Uses `MediaQuery.of(context).size` for relative sizing (width/height percentages).
- Uses `LayoutBuilder` to pick a mobile column layout for widths under 600px and a two-panel row for larger screens.

Quick run:

```bash
cd plantconnect
flutter pub get
flutter run
```

Testing tips:

- Use emulator/device rotation to check portrait/landscape behavior.
- Resize the window when running on desktop/web to see layout switch.

Suggested commit message for responsive changes:

```
feat: implemented responsive design using MediaQuery and LayoutBuilder
```

---

## 📁 Asset Management Demo

A new screen shows how to load **local images** and use Flutter's built-in
icons. Access it by tapping the image icon in the home screen app bar or
by navigating to `/assets_demo`.

Make sure assets are registered in `pubspec.yaml` before running:

```yaml
flutter:
  assets:
    - assets/images/
    - assets/icons/
```

Placeholder PNGs are included under `assets/images` and `assets/icons` –
replace them with your own logo, banner or icons. After adding new files run
`flutter pub get` to update the asset bundle.

Screenshots can be placed in `plantconnect/screenshots/` and referenced in
the PR description.

---

## 🎞️ Animation Demo

This repository now contains a simple animation playground illustrating
implicit and explicit animations plus a custom slide transition between pages.

- **Implicit demo**: an `AnimatedContainer` and `AnimatedOpacity` toggle
  size/color/opacity when you tap the toggle button.
- **Explicit demo**: a separate page (accessible via button) that rotates the
  logo using an `AnimationController` with a `RotationTransition`.
- **Custom page transition**: the rotation page slides in from the right
  using `PageRouteBuilder` and a `SlideTransition`.

You open the animation screen by tapping the 🎬 icon in the app bar or by
navigating to `/animations_demo`.

Reflection prompts:

* Why are animations helpful for UX?
* When is an implicit animation sufficient vs requiring an explicit controller?
* How would you apply these techniques in the main PlantConnect app?

Commit message suggestion:
```
feat: added animations and transitions for improved UX
```

PR title:
```
[Sprint-2] Flutter Animations & Transitions – TeamName
```

Add a brief summary and at least one screenshot or GIF to your PR description.
