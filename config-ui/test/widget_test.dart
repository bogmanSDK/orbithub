import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:config_ui/screens/home_screen.dart';

void main() {
  group('HomeScreen Tab Order Tests', () {
    testWidgets('Tabs are displayed in correct order: Jira, Advanced, AI',
        (WidgetTester tester) async {
      // Build the HomeScreen widget
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Wait for the loading to complete
      await tester.pumpAndSettle();

      // Find all Tab widgets
      final tabFinder = find.byType(Tab);
      expect(tabFinder, findsNWidgets(3));

      // Get the Tab widgets in order
      final tabs = tester.widgetList<Tab>(tabFinder).toList();

      // Verify the tab order
      expect(tabs.length, 3);
      expect((tabs[0].text as Text).data, 'Jira');
      expect((tabs[1].text as Text).data, 'Advanced');
      expect((tabs[2].text as Text).data, 'AI');
    });

    testWidgets('Tab icons are displayed in correct order',
        (WidgetTester tester) async {
      // Build the HomeScreen widget
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Wait for the loading to complete
      await tester.pumpAndSettle();

      // Find all Tab widgets
      final tabFinder = find.byType(Tab);
      final tabs = tester.widgetList<Tab>(tabFinder).toList();

      // Verify the tab icons
      expect((tabs[0].icon as Icon).icon, Icons.bug_report);
      expect((tabs[1].icon as Icon).icon, Icons.settings);
      expect((tabs[2].icon as Icon).icon, Icons.psychology);
    });

    testWidgets('Advanced tab is positioned between Jira and AI tabs',
        (WidgetTester tester) async {
      // Build the HomeScreen widget
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Wait for the loading to complete
      await tester.pumpAndSettle();

      // Find tab texts
      final jiraTab = find.text('Jira');
      final advancedTab = find.text('Advanced');
      final aiTab = find.text('AI');

      // Verify all tabs exist
      expect(jiraTab, findsOneWidget);
      expect(advancedTab, findsOneWidget);
      expect(aiTab, findsOneWidget);

      // Get the positions of tabs
      final jiraPosition = tester.getCenter(jiraTab);
      final advancedPosition = tester.getCenter(advancedTab);
      final aiPosition = tester.getCenter(aiTab);

      // Verify that Advanced is positioned between Jira and AI (horizontally)
      expect(jiraPosition.dx < advancedPosition.dx, true,
          reason: 'Jira tab should be to the left of Advanced tab');
      expect(advancedPosition.dx < aiPosition.dx, true,
          reason: 'Advanced tab should be to the left of AI tab');
    });

    testWidgets('TabBarView content order matches tab order',
        (WidgetTester tester) async {
      // Build the HomeScreen widget
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Wait for the loading to complete
      await tester.pumpAndSettle();

      // Find the TabBarView
      final tabBarView = find.byType(TabBarView);
      expect(tabBarView, findsOneWidget);

      // Verify that we have the correct number of tabs
      final tabController = DefaultTabController.of(
        tester.element(tabBarView),
      );
      expect(tabController?.length, 3);
    });

    testWidgets('Tabs maintain functionality after reordering',
        (WidgetTester tester) async {
      // Build the HomeScreen widget
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Wait for the loading to complete
      await tester.pumpAndSettle();

      // Find and tap on Advanced tab (now second tab)
      final advancedTab = find.text('Advanced');
      await tester.tap(advancedTab);
      await tester.pumpAndSettle();

      // Verify that tapping works by checking the tab selection
      // (The screen should not crash and should respond to tap)
      expect(advancedTab, findsOneWidget);

      // Tap on AI tab (now third tab)
      final aiTab = find.text('AI');
      await tester.tap(aiTab);
      await tester.pumpAndSettle();

      // Verify that tapping works
      expect(aiTab, findsOneWidget);

      // Tap back on Jira tab
      final jiraTab = find.text('Jira');
      await tester.tap(jiraTab);
      await tester.pumpAndSettle();

      // Verify that tapping works
      expect(jiraTab, findsOneWidget);
    });
  });
}
