import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shop/main.dart';

void main() {
  testWidgets('add, open the cart, remove', (tester) async {
    await tester.pumpWidget(const Shell());

    await tester.tap(find.text('Add').at(0));
    await tester.pump();
    await tester.tap(find.text('Add').at(0));
    await tester.pump();
    expect(find.text('Added'), findsNWidgets(2));
    expect(find.text('2'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.shopping_cart));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.close).first);
    await tester.pump();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Added'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });
}
