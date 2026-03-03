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
