import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:users_api/features/users/user.dart';

import 'user_json.dart';

void main() {
  group('User.fromJson', () {
    test('parses the real user 1', () {
      final json = jsonDecode(user1Json) as Map<String, dynamic>;

      final user = User.fromJson(json);

      expect(user.name, 'Leanne Graham');
      expect(user.address.city, 'Gwenborough');
      expect(user.address.geo.lat, -37.3159);
    });

    test('id as a string throws', () {
      final json = jsonDecode(user1Json) as Map<String, dynamic>;
      json['id'] = '1';

      expect(() => User.fromJson(json), throwsA(isA<TypeError>()));
    });
  });
}
