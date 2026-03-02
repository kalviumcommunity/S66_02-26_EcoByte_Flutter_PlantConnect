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
