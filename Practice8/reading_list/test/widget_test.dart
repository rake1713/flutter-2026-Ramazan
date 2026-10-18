import 'package:flutter_test/flutter_test.dart';

import 'package:reading_list/main.dart';
import 'package:reading_list/models/book.dart';

void main() {
  test('model functions', () {
    expect(totalPages(seed), 1220);
    expect(unread(seed).length, 4);
    expect(
      Book.fromMap({'title': 'X', 'author': 'Y', 'pages': 10}).toString(),
      'X — Y, 10 pp.',
    );
  });

  testWidgets('the filter changes the count in the title', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Reading list (5)'), findsOneWidget);

    await tester.tap(find.text('Unread').last);
    await tester.pump();
    expect(find.text('Reading list (4)'), findsOneWidget);
  });
}
