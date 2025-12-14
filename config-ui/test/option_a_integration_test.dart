import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:config_ui/screens/home_screen.dart';
import 'package:config_ui/screens/option_a_screen.dart';

void main() {
  group('Option A Integration Tests - Acceptance Criteria', () {
    testWidgets(
        'Scenario 1: Placeholder page is successfully created and visible in Option A tab',
        (WidgetTester tester) async {
      // Build the HomeScreen widget
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Wait for loading to complete
      await tester.pumpAndSettle();

      // Find and tap on "Option A" tab
      final optionATab = find.text('Option A');
      expect(optionATab, findsOneWidget);

      await tester.tap(optionATab);
      await tester.pumpAndSettle();

      // Verify that the placeholder text is displayed
      expect(find.text('Here is the start page'), findsOneWidget);

      // Verify that OptionAScreen is rendered
      expect(find.byType(OptionAScreen), findsOneWidget);
    });

    testWidgets(
        'Scenario 2: Placeholder page is visible in the correct section',
        (WidgetTester tester) async {
      // Build the HomeScreen widget
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Wait for loading to complete
      await tester.pumpAndSettle();

      // Navigate to "Option A" section
      final optionATab = find.text('Option A');
      await tester.tap(optionATab);
      await tester.pumpAndSettle();

      // User should be able to see the placeholder page
      final placeholderText = find.text('Here is the start page');
      expect(placeholderText, findsOneWidget);

      // Verify the text is visible (not obscured)
      final textWidget = tester.widget<Text>(placeholderText);
      expect(textWidget.data, 'Here is the start page');
    });

    testWidgets(
        'Scenario 3: Placeholder page is not visible in other sections',
        (WidgetTester tester) async {
      // Build the HomeScreen widget
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Wait for loading to complete
      await tester.pumpAndSettle();

      // Test Jira tab - placeholder should not be visible
      final jiraTab = find.text('Jira');
      await tester.tap(jiraTab);
      await tester.pumpAndSettle();
      expect(find.text('Here is the start page'), findsNothing);

      // Test Advanced tab - placeholder should not be visible
      final advancedTab = find.text('Advanced');
      await tester.tap(advancedTab);
      await tester.pumpAndSettle();
      expect(find.text('Here is the start page'), findsNothing);

      // Test AI tab - placeholder should not be visible
      final aiTab = find.text('AI');
      await tester.tap(aiTab);
      await tester.pumpAndSettle();
      expect(find.text('Here is the start page'), findsNothing);

      // Now navigate to Option A - placeholder should be visible
      final optionATab = find.text('Option A');
      await tester.tap(optionATab);
      await tester.pumpAndSettle();
      expect(find.text('Here is the start page'), findsOneWidget);
    });

    testWidgets(
        'Scenario 4: Placeholder page layout matches "Option A" specifications',
        (WidgetTester tester) async {
      // Build the HomeScreen widget
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Wait for loading to complete
      await tester.pumpAndSettle();

      // Navigate to Option A tab
      final optionATab = find.text('Option A');
      await tester.tap(optionATab);
      await tester.pumpAndSettle();

      // Verify the layout - text should be centered
      final centerWidget = find.byType(Center);
      expect(centerWidget, findsWidgets);

      // Verify styling matches specifications
      final textWidget = tester.widget<Text>(
        find.text('Here is the start page'),
      );
      expect(textWidget.style?.fontSize, 24);
      expect(textWidget.style?.fontWeight, FontWeight.w500);
      expect(textWidget.style?.color, Colors.white);

      // Verify the text is a descendant of Center (centered layout)
      expect(
        find.descendant(
          of: find.byType(OptionAScreen),
          matching: find.byType(Center),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Option A tab is displayed in the tab bar',
        (WidgetTester tester) async {
      // Build the HomeScreen widget
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Wait for loading to complete
      await tester.pumpAndSettle();

      // Verify that Option A tab exists
      final optionATab = find.text('Option A');
      expect(optionATab, findsOneWidget);

      // Verify the tab has an icon
      final tabs = tester.widgetList<Tab>(find.byType(Tab)).toList();
      expect(tabs.length, 4);

      // Find the Option A tab (should be the 4th tab)
      final optionATabWidget = tabs[3];
      expect((optionATabWidget.text as Text).data, 'Option A');
      expect((optionATabWidget.icon as Icon).icon, Icons.home);
    });

    testWidgets('Tab bar has exactly 4 tabs including Option A',
        (WidgetTester tester) async {
      // Build the HomeScreen widget
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Wait for loading to complete
      await tester.pumpAndSettle();

      // Find all tabs
      final tabFinder = find.byType(Tab);
      expect(tabFinder, findsNWidgets(4));

      // Verify tab order: Jira, Advanced, AI, Option A
      final tabs = tester.widgetList<Tab>(tabFinder).toList();
      expect((tabs[0].text as Text).data, 'Jira');
      expect((tabs[1].text as Text).data, 'Advanced');
      expect((tabs[2].text as Text).data, 'AI');
      expect((tabs[3].text as Text).data, 'Option A');
    });

    testWidgets('Tab switching functionality works with Option A',
        (WidgetTester tester) async {
      // Build the HomeScreen widget
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Wait for loading to complete
      await tester.pumpAndSettle();

      // Navigate through all tabs
      final jiraTab = find.text('Jira');
      await tester.tap(jiraTab);
      await tester.pumpAndSettle();
      expect(find.text('Here is the start page'), findsNothing);

      final advancedTab = find.text('Advanced');
      await tester.tap(advancedTab);
      await tester.pumpAndSettle();
      expect(find.text('Here is the start page'), findsNothing);

      final aiTab = find.text('AI');
      await tester.tap(aiTab);
      await tester.pumpAndSettle();
      expect(find.text('Here is the start page'), findsNothing);

      final optionATab = find.text('Option A');
      await tester.tap(optionATab);
      await tester.pumpAndSettle();
      expect(find.text('Here is the start page'), findsOneWidget);

      // Navigate back to Jira
      await tester.tap(jiraTab);
      await tester.pumpAndSettle();
      expect(find.text('Here is the start page'), findsNothing);
    });

    testWidgets('Option A tab maintains state after navigation',
        (WidgetTester tester) async {
      // Build the HomeScreen widget
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Wait for loading to complete
      await tester.pumpAndSettle();

      // Navigate to Option A
      final optionATab = find.text('Option A');
      await tester.tap(optionATab);
      await tester.pumpAndSettle();
      expect(find.text('Here is the start page'), findsOneWidget);

      // Navigate to another tab
      final jiraTab = find.text('Jira');
      await tester.tap(jiraTab);
      await tester.pumpAndSettle();

      // Navigate back to Option A
      await tester.tap(optionATab);
      await tester.pumpAndSettle();

      // Verify the placeholder is still displayed
      expect(find.text('Here is the start page'), findsOneWidget);
    });
  });
}
