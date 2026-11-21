import 'package:flutter/foundation.dart';

import '../../core/storage/secure_store.dart';

class AuthModel extends ChangeNotifier {
  AuthModel(this._store, {this._token});

  final SecureStore _store;
  String? _token;

  bool get signedIn => _token != null;

  String? get token => _token;

  Future<void> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (password.length < 8) {
      throw ArgumentError('Password must be at least 8 characters');
    }
    final t = 'tok_${email.hashCode}';
    await _store.saveToken(t);
    _token = t;
    notifyListeners();
  }

  Future<void> logout() async {
    await _store.clear();
    _token = null;
    notifyListeners();
  }
}
