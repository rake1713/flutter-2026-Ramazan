import 'package:flutter_test/flutter_test.dart';
import 'package:users_api/core/api/api_exception.dart';
import 'package:users_api/features/users/users_model.dart';

import '../../fakes/fake_user_repository.dart';

void main() {
  group('UsersModel.load', () {
    test('items from the repository', () async {
      final model = UsersModel(FakeUserRepository());

      await model.load();

      expect(model.items.length, 2);
      expect(model.loading, false);
      expect(model.error, isNull);
    });

    test('NoConnection sets error', () async {
      final model = UsersModel(FakeUserRepository(fail: true));

      await model.load();

      expect(model.error, isA<NoConnectionException>());
      expect(model.loading, false);
    });
  });
}
