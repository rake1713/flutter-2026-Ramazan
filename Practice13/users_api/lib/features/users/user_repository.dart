import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import 'user.dart';
import 'users_cache.dart';
import 'users_result.dart';

class UserRepository {
  UserRepository(this._api, this._cache);

  final ApiClient _api;
  final UsersCache _cache;

  Future<List<User>> _fetch() async {
    final data = await _api.get(_api.uri('/users'));
    try {
      return [
        for (final item in data as List)
          User.fromJson(item as Map<String, dynamic>),
      ];
    } catch (e) {
      throw BadResponseException('users: $e');
    }
  }

  Future<UsersResult> getAll() async {
    try {
      final fresh = await _fetch();
      await _cache.save(fresh);
      return UsersResult(items: fresh, fromCache: false);
    } on NoConnectionException {
      final saved = await _cache.load();
      if (saved == null) rethrow;
      return UsersResult(items: saved, fromCache: true);
    }
  }

  Future<User> getById(int id) async {
    final data = await _api.get(_api.uri('/users/$id'));
    try {
      return User.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      throw BadResponseException('users/$id: $e');
    }
  }

  Future<User> create(User draft) async {
    final data = await _api.post(
      _api.uri('/users'),
      draft.toJson(),
      expect: 201,
    );
    try {
      return User.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      throw BadResponseException('users (create): $e');
    }
  }
}
