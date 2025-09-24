import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_tracker/main.dart';

void main() {
  testWidgets('Renders HomePage', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the "Balance" text is present.
    expect(find.text('Balance'), findsOneWidget);

    // Verify that the "Recent Activity" text is present.
    expect(find.text('Recent Activity'), findsOneWidget);
  });
}
