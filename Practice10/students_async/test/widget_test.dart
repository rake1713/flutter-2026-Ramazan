import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:students_async/api/fake_api.dart';
import 'package:students_async/main.dart';

void main() {
  test('every third fetch fails, every second save fails', () async {
    final api = FakeApi();
    expect((await api.fetchStudents()).length, 6);
    expect((await api.fetchStudents()).length, 6);
    expect(api.fetchStudents(), throwsA(isA<NoConnectionException>()));
    await Future.delayed(const Duration(seconds: 3));

    FakeApi.saves = 0;
    await api.save(6);
    expect(api.save(6), throwsA(isA<StateError>()));
    await Future.delayed(const Duration(seconds: 2));
  });

  testWidgets('by hand: loading, list, error, retry', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('By hand'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Loading students…'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Aida Nurlanova'), findsOneWidget);
    expect(find.text('—'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pump(const Duration(seconds: 2));
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Could not load students'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Aida Nurlanova'), findsOneWidget);
  });

  testWidgets('save: first ok and pops, second shows the error', (
    tester,
  ) async {
    FakeApi.saves = 0;
    await tester.pumpWidget(const MyApp());
    for (var i = 0; i < 2; i++) {
      await tester.tap(find.text('By hand'));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      await tester.pump(const Duration(seconds: 2));
      await tester.tap(find.byIcon(Icons.save));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
    }
    expect(find.text('server rejected 6'), findsOneWidget);
    expect(find.text('Students (by hand)'), findsOneWidget);
  });

  testWidgets('switch does not reload the FutureBuilder', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('FutureBuilder'));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    await tester.pump(const Duration(seconds: 2));
    for (var i = 0; i < 5; i++) {
      await tester.tap(find.byType(Switch));
      await tester.pump();
      expect(find.text('Aida Nurlanova'), findsOneWidget);
    }
  });
}
