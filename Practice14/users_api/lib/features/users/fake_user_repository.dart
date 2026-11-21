import '../../core/api/api_exception.dart';
import 'user.dart';
import 'user_repository.dart';
import 'users_result.dart';

class FakeUserRepository implements UserRepository {
  FakeUserRepository({this.fail = false, this.delay = Duration.zero});

  final bool fail;
  final Duration delay;

  static const _users = [
    User(
      id: 1,
      name: 'Aida Nurlanova',
      username: 'aida',
      email: 'aida@kbtu.kz',
      phone: '+7 701 111 2233',
      website: 'kbtu.kz',
      address: Address(
        street: 'Tole bi 59',
        suite: 'Room 101',
        city: 'Almaty',
        zipcode: '050000',
        geo: Geo(lat: 43.2567, lng: 76.9286),
      ),
      company: (name: 'KBTU', catchPhrase: 'Study hard'),
    ),
    User(
      id: 2,
      name: 'Dias Seitkali',
      username: 'dias',
      email: 'dias@kbtu.kz',
      phone: '+7 702 444 5566',
      address: Address(
        street: 'Abay 10',
        suite: 'Apt. 5',
        city: 'Astana',
        zipcode: '010000',
        geo: Geo(lat: 51.1694, lng: 71.4491),
      ),
      company: (name: 'KBTU', catchPhrase: 'Code every day'),
    ),
  ];

  Future<void> _wait() async {
    if (delay > Duration.zero) await Future.delayed(delay);
    if (fail) throw const NoConnectionException();
  }

  @override
  Future<UsersResult> getAll() async {
    await _wait();
    return const UsersResult(items: _users, fromCache: false);
  }

  @override
  Future<User> getById(int id) async {
    await _wait();
    for (final u in _users) {
      if (u.id == id) return u;
    }
    throw const NotFoundException();
  }

  @override
  Future<User> create(User draft) async {
    await _wait();
    return User(
      id: 11,
      name: draft.name,
      username: draft.username,
      email: draft.email,
      phone: draft.phone,
      website: draft.website,
      address: draft.address,
      company: draft.company,
    );
  }
}
