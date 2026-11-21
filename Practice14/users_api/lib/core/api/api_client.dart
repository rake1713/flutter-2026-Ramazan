import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../storage/secure_store.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient(
    this._store, {
    http.Client? client,
    this.host = 'jsonplaceholder.typicode.com',
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final SecureStore _store;
  final String host;

  Future<Map<String, String>> _headers() async => {
    'Accept': 'application/json',
    if (await _store.readToken() case final t?) 'Authorization': 'Bearer $t',
  };

  Uri uri(String path) => Uri.https(host, path);

  Future<dynamic> get(Uri url) async {
    final headers = await _headers();
    return _request(() => _client.get(url, headers: headers));
  }

  Future<dynamic> post(Uri url, Object body, {int? expect}) async {
    final headers = {...await _headers(), 'Content-Type': 'application/json'};
    return _request(
      () => _client.post(url, headers: headers, body: jsonEncode(body)),
      expect: expect,
    );
  }

  Future<dynamic> _request(
    Future<http.Response> Function() call, {
    int? expect,
  }) async {
    final r = await _send(call);
    if (kDebugMode) {
      log(
        '${r.request?.method} ${r.request?.url.path} → ${r.statusCode}',
        name: 'api',
      );
    }
    _check(r);
    if (expect != null && r.statusCode != expect) {
      throw BadResponseException('expected $expect, got ${r.statusCode}');
    }
    return _decode(r);
  }

  Future<http.Response> _send(Future<http.Response> Function() call) async {
    try {
      return await call().timeout(const Duration(seconds: 10));
    } on SocketException {
      throw const NoConnectionException();
    } on TimeoutException {
      throw const NoConnectionException();
    }
  }

  void _check(http.Response r) {
    if (r.statusCode == 401) throw const UnauthorizedException();
    if (r.statusCode == 404) throw const NotFoundException();
    if (r.statusCode >= 500) throw ServerException(r.statusCode);
  }

  dynamic _decode(http.Response r) {
    try {
      return jsonDecode(r.body);
    } on FormatException catch (e) {
      throw BadResponseException(e.message);
    }
  }
}
