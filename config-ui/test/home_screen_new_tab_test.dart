import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:config_ui/screens/home_screen.dart';
import 'package:config_ui/screens/new_tab_screen.dart';

void main() {
  group('HomeScreen - New Tab Integration', () {
    testWidgets('should display "New Tab" as fourth tab', (WidgetTester tester) async {
      // Build the HomeScreen widget
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Wait for the configuration to load
      await tester.pumpAndSettle();

      // Verify that the "New Tab" tab is present
      expect(find.text('New Tab'), findsOneWidget);
      
      // Verify tab position (should be the 4th tab)
      final tabBar = tester.widget<TabBar>(find.byType(TabBar));
      expect(tabBar.tabs.length, 4);
      
      // Verify the 4th tab is the New Tab
      final fourthTab = tabBar.tabs[3] as Tab;
      expect(fourthTab.text, 'New Tab');
      expect(fourthTab.icon, isA<Icon>());
    });

    testWidgets('should navigate to New Tab when clicked', (WidgetTester tester) async {
      // Build the HomeScreen widget
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Wait for the configuration to load
      await tester.pumpAndSettle();

      // Find and tap the "New Tab" tab
      await tester.tap(find.text('New Tab'));
      await tester.pumpAndSettle();

      // Verify that the NewTabScreen is displayed
      expect(find.byType(NewTabScreen), findsOneWidget);
    });

    testWidgets('should display empty page when New Tab is active', (WidgetTester tester) async {
      // Build the HomeScreen widget
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Wait for the configuration to load
      await tester.pumpAndSettle();

      // Tap the "New Tab" tab
      await tester.tap(find.text('New Tab'));
      await tester.pumpAndSettle();

      // Verify that the NewTabScreen displays "New Tab" text
      expect(find.text('New Tab'), findsAtLeastNWidgets(2)); // One in tab, one in screen
      
      // Verify no configuration fields are present (empty page)
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('should have correct icon for New Tab', (WidgetTester tester) async {
      // Build the HomeScreen widget
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Wait for the configuration to load
      await tester.pumpAndSettle();

      // Find the TabBar
      final tabBar = tester.widget<TabBar>(find.byType(TabBar));
      final fourthTab = tabBar.tabs[3] as Tab;
      
      // Verify the icon
      final icon = fourthTab.icon as Icon?;
      expect(icon, isNotNull);
      expect(icon!.icon, Icons.tab);
    });

    testWidgets('should have 4 tabs total including New Tab', (WidgetTester tester) async {
      // Build the HomeScreen widget
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Wait for the configuration to load
      await tester.pumpAndSettle();

      // Find all tabs
      expect(find.text('Jira'), findsOneWidget);
      expect(find.text('AI'), findsOneWidget);
      expect(find.text('Advanced'), findsOneWidget);
      expect(find.text('New Tab'), findsOneWidget);

      // Verify TabBar has exactly 4 tabs
      final tabBar = tester.widget<TabBar>(find.byType(TabBar));
      expect(tabBar.tabs.length, 4);
    });

    testWidgets('should be able to switch between tabs including New Tab', (WidgetTester tester) async {
      // Build the HomeScreen widget
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Wait for the configuration to load
      await tester.pumpAndSettle();

      // Initially on Jira tab - verify Jira screen is displayed
      expect(find.text('Jira Base Path'), findsOneWidget);

      // Switch to AI tab
      await tester.tap(find.text('AI'));
      await tester.pumpAndSettle();
      expect(find.text('AI Provider'), findsOneWidget);

      // Switch to Advanced tab
      await tester.tap(find.text('Advanced'));
      await tester.pumpAndSettle();
      expect(find.text('Confluence Base Path'), findsOneWidget);

      // Switch to New Tab
      await tester.tap(find.text('New Tab'));
      await tester.pumpAndSettle();
      expect(find.byType(NewTabScreen), findsOneWidget);

      // Switch back to Jira tab
      await tester.tap(find.text('Jira'));
      await tester.pumpAndSettle();
      expect(find.text('Jira Base Path'), findsOneWidget);
    });

    testWidgets('New Tab should be in position 4 (after Advanced)', (WidgetTester tester) async {
      // Build the HomeScreen widget
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Wait for the configuration to load
      await tester.pumpAndSettle();

      // Find the TabBar and verify tab order
      final tabBar = tester.widget<TabBar>(find.byType(TabBar));
      
      expect((tabBar.tabs[0] as Tab).text, 'Jira');
      expect((tabBar.tabs[1] as Tab).text, 'AI');
      expect((tabBar.tabs[2] as Tab).text, 'Advanced');
      expect((tabBar.tabs[3] as Tab).text, 'New Tab');
    });

    testWidgets('should display error if New Tab is not visible', (WidgetTester tester) async {
      // Build the HomeScreen widget
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Wait for the configuration to load
      await tester.pumpAndSettle();

      // Verify that the "New Tab" is visible - test should fail if it's not
      final newTabFinder = find.text('New Tab');
      expect(newTabFinder, findsOneWidget, 
        reason: 'New Tab should be visible in the tab bar');
      
      // Verify tab is at position defined (position 4)
      final tabBar = tester.widget<TabBar>(find.byType(TabBar));
      expect(tabBar.tabs.length, 4, 
        reason: 'TabBar should have 4 tabs including New Tab');
      expect((tabBar.tabs[3] as Tab).text, 'New Tab',
        reason: 'New Tab should be at position 4 (index 3)');
    });
  });
}
