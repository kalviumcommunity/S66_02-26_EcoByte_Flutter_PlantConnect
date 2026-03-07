// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:plantconnect/main.dart';
import 'package:plantconnect/screens/asset_demo_screen.dart';
import 'package:plantconnect/screens/animations_demo.dart';
import 'package:plantconnect/screens/rotate_logo_demo.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('Asset demo screen displays local image and icons', (
    WidgetTester tester,
  ) async {
    // pump the standalone screen instead of full app
    await tester.pumpWidget(const MaterialApp(home: AssetDemoScreen()));

    expect(find.text('Assets Demo'), findsOneWidget);
    // the image asset might not render, but the widget should exist
    expect(find.byType(Image), findsOneWidget);
    expect(find.byIcon(Icons.flutter_dash), findsOneWidget);
  });

  testWidgets('Implicit animation screen toggles and shows widgets', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AnimationsDemoScreen()));

    expect(
      find.text('Implicit animation (AnimatedContainer + Opacity)'),
      findsOneWidget,
    );
    expect(find.byType(AnimatedContainer), findsOneWidget);
    expect(find.byType(AnimatedOpacity), findsOneWidget);

    // tap toggle button and pump to animate
    await tester.tap(find.text('Toggle animation'));
    await tester.pumpAndSettle();

    // opacity change may require pumpAndSettle; ensure widget still present
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('Rotation demo screen builds and contains rotation widget', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: RotateLogoDemo()));
    expect(find.text('Rotation Animation Demo'), findsOneWidget);
    expect(find.byType(RotationTransition), findsOneWidget);
  });
}
