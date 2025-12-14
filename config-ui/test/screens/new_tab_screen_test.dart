import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:config_ui/screens/new_tab_screen.dart';

void main() {
  group('NewTabScreen', () {
    testWidgets('should render with "New Tab" text', (WidgetTester tester) async {
      // Build the NewTabScreen widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NewTabScreen(),
          ),
        ),
      );

      // Verify that the "New Tab" text is displayed
      expect(find.text('New Tab'), findsOneWidget);
    });

    testWidgets('should display text centered on screen', (WidgetTester tester) async {
      // Build the NewTabScreen widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NewTabScreen(),
          ),
        ),
      );

      // Verify that the Center widget exists
      expect(find.byType(Center), findsOneWidget);
      
      // Verify that the text is inside the Center widget
      final centerWidget = tester.widget<Center>(find.byType(Center));
      expect(centerWidget.child, isA<Text>());
    });

    testWidgets('should have correct text styling', (WidgetTester tester) async {
      // Build the NewTabScreen widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NewTabScreen(),
          ),
        ),
      );

      // Find the Text widget
      final textWidget = tester.widget<Text>(find.text('New Tab'));
      
      // Verify text style properties
      expect(textWidget.style?.fontSize, 24);
      expect(textWidget.style?.fontWeight, FontWeight.w300);
    });

    testWidgets('should render empty page without errors', (WidgetTester tester) async {
      // Build the NewTabScreen widget and verify no exceptions are thrown
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NewTabScreen(),
          ),
        ),
      );

      // Verify the widget tree is built successfully
      expect(tester.takeException(), isNull);
    });
  });
}
