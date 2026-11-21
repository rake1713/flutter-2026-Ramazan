import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:users_api/core/api/api_client.dart';
import 'package:users_api/core/api/api_exception.dart';
import 'package:users_api/features/users/user_repository.dart';
import 'package:users_api/features/users/users_cache.dart';

import '../../fakes/fake_secure_store.dart';

HttpUserRepository _repo(MockClient client) {
  return HttpUserRepository(
    ApiClient(FakeSecureStore(), client: client),
    const UsersCache(),
  );
}

void main() {
  group('HttpUserRepository', () {
    test('404 -> NotFoundException', () {
      final repo = _repo(
        MockClient((_) async => http.Response('{"error":"gone"}', 404)),
      );

      expect(repo.getById(99), throwsA(isA<NotFoundException>()));
    });

    test('500 -> ServerException', () {
      final repo = _repo(MockClient((_) async => http.Response('', 500)));

      expect(repo.getById(1), throwsA(isA<ServerException>()));
    });

    test('SocketException -> NoConnectionException', () {
      final repo = _repo(
        MockClient((_) async => throw const SocketException('down')),
      );

      expect(repo.getById(1), throwsA(isA<NoConnectionException>()));
    });
  });
}
