import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_exception.dart';

class ApiClient {
  ApiClient(this._client, {this.host = 'jsonplaceholder.typicode.com'});

  final http.Client _client;
  final String host;

  http.Client get client => _client;

  Map<String, String> get headers => {'Accept': 'application/json'};

  Future<dynamic> request(
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
