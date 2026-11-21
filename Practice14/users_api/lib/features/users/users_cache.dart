import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'user.dart';

class UsersCache {
  const UsersCache();

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/users.json');
  }

  Future<void> save(List<User> list) async {
    final file = await _file();
    await file.writeAsString(jsonEncode([for (final u in list) u.toJson()]));
  }

  Future<List<User>?> load() async {
    final file = await _file();
    if (!await file.exists()) return null;
    final data = jsonDecode(await file.readAsString()) as List;
    return [
      for (final item in data) User.fromJson(item as Map<String, dynamic>),
    ];
  }
}
