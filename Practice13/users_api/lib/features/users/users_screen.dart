import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/loading_view.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_model.dart';
import '../settings/settings_screen.dart';
import 'new_user_screen.dart';
import 'users_model.dart';
import 'widgets/offline_banner.dart';
import 'widgets/user_list.dart';
import 'widgets/users_error_view.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  Widget _list(UsersModel m, String? city) {
    final shown = city == null
        ? m.items
        : m.items.where((u) => u.address.city == city).toList();
    return Column(
      children: [
        if (m.fromCache) OfflineBanner(onRetry: m.load),
        Expanded(
          child: RefreshIndicator(onRefresh: m.load, child: UserList(shown)),
        ),
      ],
    );
  }

  Widget _body(UsersModel m, String? city) {
    if (m.loading) return const LoadingView();
    if (m.error case final e?) {
      return UsersErrorView(error: e, onRetry: m.load);
    }
    return _list(m, city);
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final m = context.watch<UsersModel>();
    final city = context.watch<SettingsModel>().city;
    return Scaffold(
      appBar: AppBar(
        title: Text(city ?? 'Users'),
        actions: [
          IconButton(
            onPressed: () => _open(context, const NewUserScreen()),
            icon: const Icon(Icons.person_add),
          ),
          IconButton(
            onPressed: () => _open(context, const ProfileScreen()),
            icon: const Icon(Icons.account_circle),
          ),
          IconButton(
            onPressed: () => _open(context, const SettingsScreen()),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: _body(m, city),
    );
  }
}
