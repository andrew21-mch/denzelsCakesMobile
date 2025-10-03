// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:denzels_cakes/main.dart';

void main() {
  testWidgets('App launches without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CakeShopApp());

    // Verify that the app launches and shows some basic content
    // (This is a basic smoke test to ensure the app doesn't crash on startup)
    await tester.pump();
    
    // Just check that the app contains some widget
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
