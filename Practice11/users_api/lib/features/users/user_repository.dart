import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import 'user.dart';

class UserRepository {
  UserRepository(this._api);

  final ApiClient _api;

  Uri _uri(String path) => Uri.https(_api.host, path);

  Future<dynamic> _call(Future<http.Response> Function() call, {int? expect}) {
    return _api.request(call, expect: expect);
  }

  Future<dynamic> _get(Uri url) {
    return _call(() => _api.client.get(url, headers: _api.headers));
  }

  Future<List<User>> getAll() async {
    final data = await _get(_uri('/users'));
    try {
      return [
        for (final item in data as List)
          User.fromJson(item as Map<String, dynamic>),
      ];
    } catch (e) {
      throw BadResponseException('users: $e');
    }
  }

  Future<User> getById(int id) async {
    final data = await _get(_uri('/users/$id'));
    try {
      return User.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      throw BadResponseException('users/$id: $e');
    }
  }

  Future<User> create(User draft) async {
    final url = _uri('/users');
    final data = await _call(
      () => _api.client.post(
        url,
        headers: {..._api.headers, 'Content-Type': 'application/json'},
        body: jsonEncode(draft.toJson()),
      ),
      expect: 201,
    );
    try {
      return User.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      throw BadResponseException('users (create): $e');
    }
  }
}
