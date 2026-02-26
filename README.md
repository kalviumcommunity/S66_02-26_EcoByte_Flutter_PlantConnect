
---

# 🌿 PlantConnect – Smart Plant Care Companion

## 📱 Project Overview

**PlantConnect** is a Flutter-based mobile application built using Firebase that helps local plant nurseries provide digital plant care guidance to customers after purchase.

The app enables users to:

* Securely register and log in
* Browse plant care information
* Save plants they own
* Track watering schedules with reminders
* Manage personal plant collections

By digitizing plant care instructions, PlantConnect improves plant survival rates and enhances customer satisfaction through real-time cloud integration.

---

# 🎯 Project Objective

To deliver a stable, demo-ready MVP that demonstrates:

* Firebase Authentication
* Cloud Firestore integration
* Real-time CRUD operations
* Clean modular Flutter architecture
* Scalable folder structure

---

# 🛠 Tech Stack

**Frontend**

* Flutter
* Dart
* Provider (State Management)

**Backend**

* Firebase Authentication
* Cloud Firestore
* Firebase Storage (optional for images)

**Tools**

* GitHub
* GitHub Actions (CI/CD)
* Android Studio / VS Code
* Firebase Console

---

# 📂 Project Folder Structure

```
plantconnect/
│
├── android/
├── ios/
├── web/
│
├── lib/
│   ├── main.dart
│   ├── config/
│   ├── models/
│   ├── services/
│   ├── providers/
│   ├── screens/
│   ├── widgets/
│   ├── utils/
│
├── assets/
│   ├── images/
│   └── icons/
│
├── test/
│
├── pubspec.yaml
└── README.md
```

---

# 📁 Purpose of Each Directory

## 🔹 android/

Contains Android-specific configuration and native platform code required to build the APK.

## 🔹 ios/

Contains iOS-specific configuration files and native build settings.

## 🔹 web/

Includes configuration files for Flutter Web builds (if deployed on web).

---

## 🔹 lib/ (Core Application Code)

This is the heart of the application where all Dart code resides.

---

### 📄 main.dart

* Entry point of the application
* Initializes Firebase
* Configures app routes
* Sets up Provider state management

---

### 📁 config/

Stores application-level configuration:

* App themes
* Route definitions
* Firebase setup files
* Constants related to global configuration

Keeps setup logic separate from business logic.

---

### 📁 models/

Contains Dart data models representing Firestore documents.

Examples:

* `UserModel`
* `PlantModel`
* `UserPlantModel`

Purpose:

* Convert Firestore JSON to Dart objects
* Maintain strong typing
* Improve code readability and consistency

---

### 📁 services/

Handles all backend communication and business logic.

Includes:

* `auth_service.dart`
* `plant_service.dart`
* `user_plant_service.dart`

Responsibilities:

* Firebase Authentication logic
* Firestore CRUD operations
* Data transformation
* Error handling

This prevents UI from directly interacting with Firebase.

---

### 📁 providers/

Manages application state using Provider.

Examples:

* `auth_provider.dart`
* `plant_provider.dart`
* `user_plant_provider.dart`

Responsibilities:

* Manage UI state
* Notify listeners on changes
* Connect services to UI

Ensures reactive and maintainable UI updates.

---

### 📁 screens/

Contains full-page UI screens.

Examples:

* `login_screen.dart`
* `register_screen.dart`
* `dashboard_screen.dart`
* `plant_list_screen.dart`
* `plant_detail_screen.dart`
* `my_plants_screen.dart`
* `profile_screen.dart`

Each screen:

* Represents a complete user flow
* Uses providers for data
* Contains minimal business logic

---

### 📁 widgets/

Reusable UI components shared across screens.

Examples:

* `custom_button.dart`
* `plant_card.dart`
* `input_field.dart`
* `loading_indicator.dart`

Purpose:

* Reduce code duplication
* Improve UI consistency
* Follow reusable component architecture

---

### 📁 utils/

Utility and helper functions.

Includes:

* Form validators
* Date formatting helpers
* Constants
* Reusable methods

Keeps helper logic organized and reusable.

---

## 🔹 assets/

Stores static resources used in the app.

### images/

Plant images, illustrations, and UI assets.

### icons/

Custom icons used throughout the UI.

All assets are registered inside `pubspec.yaml`.

---

## 🔹 test/

Contains unit and widget tests for:

* Authentication flows
* Firestore operations
* Provider logic
* UI components

Ensures reliability and stability.

---

# 🏗 How This Structure Supports Modular App Design

Our project follows **Separation of Concerns** principles.

### 1️⃣ UI Layer (Screens + Widgets)

* Handles presentation only
* Does not directly access Firebase
* Uses Providers for data

### 2️⃣ State Management Layer (Providers)

* Manages app state
* Connects UI to services
* Ensures reactive updates

### 3️⃣ Business Logic Layer (Services)

* Handles authentication
* Manages Firestore CRUD
* Processes data

### 4️⃣ Data Layer (Models)

* Defines structured objects
* Converts JSON to Dart objects

---

### ✅ Benefits of This Structure

* Clean separation between UI and backend
* Easy debugging
* Scalable for future features
* Clear team ownership
* Reduced merge conflicts
* Easier testing
* Better maintainability

This modular approach ensures that new features (e.g., push notifications or analytics) can be added without restructuring the entire project.

---

# 📝 Naming Conventions

To maintain consistency and readability, the following naming standards are used:

---

## 📄 File Naming

All Dart files use **snake_case**.

Examples:

* `login_screen.dart`
* `auth_service.dart`
* `plant_provider.dart`
* `user_model.dart`

Reason:

* Follows Flutter community standards
* Improves clarity and consistency

---

## 🏷 Class Naming

All classes use **PascalCase**.

Examples:

* `LoginScreen`
* `AuthService`
* `PlantProvider`
* `UserPlantModel`

Reason:

* Standard Dart class naming convention

---

## 🧩 Widget Naming

* Screens end with `Screen`
* Reusable components are named based on function

Examples:

* `LoginScreen`
* `PlantDetailScreen`
* `CustomButton`
* `PlantCard`
* `InputField`

Reason:

* Makes widget purpose immediately clear
* Improves readability in large projects

---

## 🔑 Provider Naming

Pattern:

```
<FeatureName>Provider
```

Examples:

* `AuthProvider`
* `PlantProvider`
* `UserPlantProvider`

---

## 🔧 Service Naming

Pattern:

```
<FeatureName>Service
```

Examples:

* `AuthService`
* `PlantService`
* `UserPlantService`

---

# 🔐 Architecture Pattern Summary

PlantConnect follows a **modular layered architecture**:

UI → Provider → Service → Firebase

This ensures:

* Clean data flow
* Testable logic
* Maintainable codebase
* Scalable project structure

---

# 🚀 Future Scalability

This structure allows easy integration of:

* Push Notifications
* AI-based plant recommendations
* Nursery Admin Panel
* Payment integration
* Analytics dashboard
* Offline caching

---

# 📦 Build & Run

```bash
flutter pub get
flutter run
```

To generate APK:

```bash
flutter build apk --release
```

---

# 🎯 Conclusion

PlantConnect is built with a scalable, modular architecture that promotes clean code practices, team collaboration, and production-ready structure.

This README reflects our design decisions, folder organization, naming conventions, and architectural approach to ensure a maintainable and demo-ready Flutter + Firebase application.

---

