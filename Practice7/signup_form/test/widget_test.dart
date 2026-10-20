import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:signup_form/main.dart';

void main() {
  testWidgets('empty form shows every error at once', (tester) async {
    await tester.pumpWidget(const MyApp());

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);

    await tester.ensureVisible(find.text('I agree to the rules'));
    await tester.tap(find.text('I agree to the rules'));
    await tester.pump();
    await tester.ensureVisible(find.byType(FilledButton));
    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(find.text('At least 2 characters'), findsOneWidget);
    expect(find.text('Enter a valid email'), findsOneWidget);
    expect(find.text('Choose a group'), findsOneWidget);
    expect(find.text('Pick your date of birth'), findsOneWidget);
  });
}
