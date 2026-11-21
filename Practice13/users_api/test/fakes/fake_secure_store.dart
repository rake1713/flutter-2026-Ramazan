import 'package:users_api/core/storage/secure_store.dart';

class FakeSecureStore extends SecureStore {
  String? token;

  @override
  Future<void> saveToken(String t) async => token = t;

  @override
  Future<String?> readToken() async => token;

  @override
  Future<void> clear() async => token = null;
}
