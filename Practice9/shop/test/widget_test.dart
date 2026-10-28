import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:shop/main.dart';
import 'package:shop/models/book.dart';
import 'package:shop/models/cart.dart';

void main() {
  test('cart model works without widgets', () {
    final cart = Cart();
    expect(cart.add(books[0]), true);
    expect(cart.add(books[1]), true);
    expect(cart.add(books[0]), false);
    cart.remove(books[0]);
    expect(cart.count, 1);
    expect(cart.total, 3100);
    cart.increment(books[1]);
    expect(cart.qtyOf(books[1]), 2);
    expect(cart.total, 6200);
    expect(() => cart.items.add(books[0]), throwsUnsupportedError);
  });

  testWidgets('add, open the cart, plus, clear', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(create: (_) => Cart(), child: const Shell()),
    );

    await tester.tap(find.text('Add').at(0));
    await tester.pump();
    await tester.tap(find.text('Add').at(0));
    await tester.pump();
    expect(find.text('Added'), findsWidgets);
    expect(find.text('2'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.shopping_cart));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pump();
    expect(find.text('11500 ₸'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_sweep));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear'));
    await tester.pumpAndSettle();
    expect(find.text('0 ₸'), findsOneWidget);
  });
}
