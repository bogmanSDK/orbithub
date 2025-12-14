import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:config_ui/screens/option_a_screen.dart';

void main() {
  group('OptionAScreen Tests', () {
    testWidgets('Placeholder page is successfully created with centered text',
        (WidgetTester tester) async {
      // Build the OptionAScreen widget
      await tester.pumpWidget(
        const MaterialApp(
          home: OptionAScreen(),
        ),
      );

      // Verify that the page displays the placeholder text
      expect(find.text('Here is the start page'), findsOneWidget);
    });

    testWidgets('Placeholder text is centered on the screen',
        (WidgetTester tester) async {
      // Build the OptionAScreen widget
      await tester.pumpWidget(
        const MaterialApp(
          home: OptionAScreen(),
        ),
      );

      // Find the Center widget
      final centerFinder = find.byType(Center);
      expect(centerFinder, findsOneWidget);

      // Verify that the text is inside a Center widget
      final textFinder = find.text('Here is the start page');
      expect(textFinder, findsOneWidget);

      // Verify that the text widget is a descendant of Center
      expect(
        find.descendant(
          of: centerFinder,
          matching: textFinder,
        ),
        findsOneWidget,
      );
    });

    testWidgets('Placeholder text has correct styling',
        (WidgetTester tester) async {
      // Build the OptionAScreen widget
      await tester.pumpWidget(
        const MaterialApp(
          home: OptionAScreen(),
        ),
      );

      // Find the Text widget
      final textWidget = tester.widget<Text>(
        find.text('Here is the start page'),
      );

      // Verify text styling
      expect(textWidget.style?.fontSize, 24);
      expect(textWidget.style?.fontWeight, FontWeight.w500);
      expect(textWidget.style?.color, Colors.white);
    });

    testWidgets('Screen renders without errors',
        (WidgetTester tester) async {
      // Build the OptionAScreen widget
      await tester.pumpWidget(
        const MaterialApp(
          home: OptionAScreen(),
        ),
      );

      // Pump and settle to ensure all animations complete
      await tester.pumpAndSettle();

      // Verify no errors occurred and the widget tree is valid
      expect(find.byType(OptionAScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Screen is a StatelessWidget',
        (WidgetTester tester) async {
      // Verify that OptionAScreen is a StatelessWidget
      const screen = OptionAScreen();
      expect(screen, isA<StatelessWidget>());
    });

    testWidgets('Text content is exactly "Here is the start page"',
        (WidgetTester tester) async {
      // Build the OptionAScreen widget
      await tester.pumpWidget(
        const MaterialApp(
          home: OptionAScreen(),
        ),
      );

      // Find the text widget
      final textWidget = tester.widget<Text>(
        find.text('Here is the start page'),
      );

      // Verify exact text content
      expect(textWidget.data, 'Here is the start page');
    });

    testWidgets('Screen adapts to different screen sizes',
        (WidgetTester tester) async {
      // Test with a small screen size
      await tester.pumpWidget(
        const MaterialApp(
          home: OptionAScreen(),
        ),
      );

      // Find text and verify it's centered
      final textFinder = find.text('Here is the start page');
      expect(textFinder, findsOneWidget);

      // The Center widget should position the text in the middle
      final centerWidget = tester.widget<Center>(find.byType(Center));
      expect(centerWidget, isNotNull);
    });
  });
}
