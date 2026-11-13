import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

import 'package:users_api/core/api/api_client.dart';
import 'package:users_api/core/api/api_exception.dart';
import 'package:users_api/features/users/user.dart';
import 'package:users_api/features/users/user_repository.dart';
import 'package:users_api/features/users/users_model.dart';
import 'package:users_api/main.dart';

const _user1 = r'''
{
  "id": 1,
  "name": "Leanne Graham",
  "username": "Bret",
  "email": "Sincere@april.biz",
  "address": {
    "street": "Kulas Light",
    "suite": "Apt. 556",
    "city": "Gwenborough",
    "zipcode": "92998-3874",
    "geo": {"lat": "-37.3159", "lng": "81.1496"}
  },
  "phone": "1-770-736-8031 x56442",
  "website": "hildegard.org",
  "company": {
    "name": "Romaguera-Crona",
    "catchPhrase": "Multi-layered client-server neural-net",
    "bs": "harness real-time e-markets"
  }
}
''';

UserRepository _repo(int status, String body) {
  final client = MockClient((_) async => http.Response(body, status));
  return UserRepository(ApiClient(client));
}

void main() {
  test('fromJson / toJson round trip', () {
    final json = jsonDecode(_user1) as Map<String, dynamic>;
    final user = User.fromJson(json);
    expect(user.address.geo.lat, -37.3159);
    expect(user.company.name, 'Romaguera-Crona');
    expect(user.phoneDigits, '1770736803156442');
    final again = User.fromJson(user.toJson());
    expect(again, user);
    expect(again.address.city, 'Gwenborough');
  });

  test('statuses become my exceptions', () async {
    expect(_repo(404, '{}').getById(999), throwsA(isA<NotFoundException>()));
    expect(_repo(401, '').getAll(), throwsA(isA<UnauthorizedException>()));
    expect(_repo(503, '').getAll(), throwsA(isA<ServerException>()));
    expect(_repo(200, 'oops').getAll(), throwsA(isA<BadResponseException>()));
    expect(_repo(200, '{}').getById(1), throwsA(isA<BadResponseException>()));
  });

  testWidgets('the screen shows the list from the repository', (tester) async {
    final repo = _repo(200, '[$_user1]');
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => UsersModel(repo)..load(),
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Leanne Graham'), findsOneWidget);
  });
}
