import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:screens_lead/main.dart';

void main() {
  Future<void> openAidaEdit(WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Aida Akhmetova'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();
  }

  testWidgets('list has no back arrow, detail has one', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(ListTile), findsWidgets);
    expect(find.byType(BackButton), findsNothing);

    await tester.tap(find.text('Aida Akhmetova'));
    await tester.pumpAndSettle();
    expect(find.text('aida@kbtu.kz'), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Students'), findsOneWidget);
  });

  testWidgets('Save hands the new name back', (tester) async {
    await openAidaEdit(tester);
    await tester.enterText(find.byType(TextField), 'Aida K');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Aida K'), findsOneWidget);
    expect(find.text('Discard changes?'), findsNothing);
  });

  testWidgets('clean form pops without a dialog', (tester) async {
    await openAidaEdit(tester);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Discard changes?'), findsNothing);
    expect(find.text('Aida Akhmetova'), findsOneWidget);
  });

  testWidgets('dirty form asks; Keep editing stays, Discard leaves', (
    tester,
  ) async {
    await openAidaEdit(tester);
    await tester.enterText(find.byType(TextField), 'X');
    await tester.pump();

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Discard changes?'), findsOneWidget);

    await tester.tap(find.text('Keep editing'));
    await tester.pumpAndSettle();
    expect(find.text('Save'), findsOneWidget);
    expect(find.text('X'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(find.text('Save'), findsNothing);
    expect(find.text('Aida Akhmetova'), findsOneWidget);
  });
}
