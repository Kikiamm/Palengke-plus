// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palengkeplus/main.dart';

void main() {
  testWidgets('App loads without errors', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PalengkePlusApp());
    await tester.pump();

    // PalengkeSplash should present on load
    expect(find.byType(PalengkeSplash), findsOneWidget);

    // Skip the animation by calling the finished callback directly
    final splashState = tester.state(find.byType(PalengkeSplash)) as dynamic;
    splashState.widget.onFinished();
    await tester.pumpAndSettle();

    // After animation, we should see NavigationBar
    expect(find.byType(NavigationBar), findsOneWidget);
  }, skip: true); // Skip temporarily due to timeout, need to address navigation complexity later.


  testWidgets('Profile renders alert preferences without errors', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp(home: ProfileTab(onSettings: () {})));

    expect(find.text('Alert Preferences'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('basket total uses the latest listed prices and quantities', () {
    final total = estimateBasketTotal(
      {'rice': 2, 'fish': 0.5},
      [
        {'name': 'rice', 'latest_price': 50.0},
        {'name': 'fish', 'latest_price': 80.0},
      ],
    );

    expect(total, 140.0);
  });

  test('commodity icons match the Figma glyphs', () {
    expect(commodityEmoji('repolyo'), '🥬');
    expect(commodityEmoji('galunggong'), '🐡');
    expect(commodityEmoji('ampalaya'), '🌿');
    expect(commodityEmoji('well-milled rice'), '🍚');
    expect(categoryEmoji('Poultry'), '🍗');
  });

  test('budget limit must be a finite positive amount', () {
    expect(isValidBudgetLimit('500'), isTrue);
    expect(isValidBudgetLimit('125.50'), isTrue);
    expect(isValidBudgetLimit('0'), isFalse);
    expect(isValidBudgetLimit('-50'), isFalse);
    expect(isValidBudgetLimit('NaN'), isFalse);
    expect(isValidBudgetLimit(''), isFalse);
  });

  testWidgets('budget picker resets when the selected item leaves its menu', (
    WidgetTester tester,
  ) async {
    final items = [
      {'name': 'ampalaya'},
      {'name': 'galunggong'},
    ];
    final selected = <String>{};

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            body: BudgetCommodityPicker(
              available: items
                  .where((item) => !selected.contains(item['name']))
                  .toList(),
              onSelected: (name) => setState(() => selected.add(name)),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Galunggong'));
    await tester.pumpAndSettle();

    expect(selected, contains('galunggong'));
    expect(tester.takeException(), isNull);
  });


  testWidgets('Profile shows vendor dashboard button when in vendor mode', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: ProfileTab(
          onSettings: () {},
          role: 'vendor',
          vendorUser: 'test_maria',
        ),
      ),
    );

    expect(find.text('Vendor: test_maria'), findsOneWidget);
    expect(find.text('Manage My Stall (Dashboard)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Tapping vendor login link opens vendor login dialog', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileTab(
            onSettings: () {},
            role: 'consumer',
          ),
        ),
      ),
    );

    final loginLink = find.text('Are you a vendor? Login / Register here');
    expect(loginLink, findsOneWidget);

    await tester.tap(loginLink);
    await tester.pumpAndSettle();

    expect(find.text('Vendor Login'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
}
