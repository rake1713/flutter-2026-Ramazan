import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:users_api/core/api/api_client.dart';
import 'package:users_api/core/api/api_exception.dart';
import 'package:users_api/core/storage/secure_store.dart';
import 'package:users_api/features/users/user.dart';
import 'package:users_api/features/users/user_repository.dart';
import 'package:users_api/features/users/users_cache.dart';
import 'package:users_api/features/users/users_model.dart';

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

class FakeStore extends SecureStore {
  String? token;

  @override
  Future<void> saveToken(String t) async => token = t;

  @override
  Future<String?> readToken() async => token;

  @override
  Future<void> clear() async => token = null;
}

class FakeCache extends UsersCache {
  List<User>? saved;

  @override
  Future<void> save(List<User> list) async => saved = list;

  @override
  Future<List<User>?> load() async => saved;
}

UserRepository _repo(int status, String body, [FakeCache? cache]) {
  final client = MockClient((_) async => http.Response(body, status));
  return UserRepository(ApiClient(client, FakeStore()), cache ?? FakeCache());
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

  test('the token goes into the Authorization header', () async {
    final store = FakeStore()..token = 'tok_42';
    String? header;
    final client = MockClient((r) async {
      header = r.headers['Authorization'];
      return http.Response('[$_user1]', 200);
    });
    await UserRepository(ApiClient(client, store), FakeCache()).getAll();
    expect(header, 'Bearer tok_42');
  });

  test('no connection returns the saved list, or rethrows', () async {
    final cache = FakeCache();
    final online = await _repo(200, '[$_user1]', cache).getAll();
    expect(online.fromCache, false);

    final offline = UserRepository(
      ApiClient(
        MockClient((_) async => throw const SocketException('down')),
        FakeStore(),
      ),
      cache,
    );
    final result = await offline.getAll();
    expect(result.fromCache, true);
    expect(result.items.length, 1);

    final empty = UserRepository(
      ApiClient(
        MockClient((_) async => throw const SocketException('down')),
        FakeStore(),
      ),
      FakeCache(),
    );
    expect(empty.getAll(), throwsA(isA<NoConnectionException>()));
  });

  test('the model says when the data is from the cache', () async {
    final cache = FakeCache();
    await _repo(200, '[$_user1]', cache).getAll();
    final model = UsersModel(
      UserRepository(
        ApiClient(
          MockClient((_) async => throw const SocketException('down')),
          FakeStore(),
        ),
        cache,
      ),
    );
    await model.load();
    expect(model.fromCache, true);
    expect(model.items.length, 1);
    expect(model.error, isNull);
  });
}
