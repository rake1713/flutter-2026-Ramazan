import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:users_api/core/widgets/loading_view.dart';
import 'package:users_api/features/profile/profile_screen.dart';
import 'package:users_api/features/settings/settings_model.dart';
import 'package:users_api/features/settings/settings_screen.dart';
import 'package:users_api/features/users/new_user_screen.dart';
import 'package:users_api/features/users/users_model.dart';
import 'package:users_api/features/users/widgets/city_filter_row.dart';
import 'package:users_api/features/users/widgets/empty_users.dart';
import 'package:users_api/features/users/widgets/offline_banner.dart';
import 'package:users_api/features/users/widgets/user_list.dart';
import 'package:users_api/features/users/widgets/users_error_view.dart';
import 'package:users_api/features/users/widgets/users_header.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final m = context.watch<UsersModel>();
    final settings = context.watch<SettingsModel?>();
    final city = settings?.city;
    final shown = m.itemsIn(city);

    Widget body;
    if (m.loading) {
      body = const LoadingView();
    } else if (m.error case final e?) {
      body = UsersErrorView(error: e, onRetry: m.load);
    } else {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (m.fromCache) OfflineBanner(onRetry: m.load),
          UsersHeader(count: shown.length),
          if (city != null)
            CityFilterRow(city: city, onClear: () => settings?.setCity(null)),
          Expanded(
            child: RefreshIndicator(
              onRefresh: m.load,
              child: shown.isEmpty ? const EmptyUsers() : UserList(shown),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
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
      body: body,
    );
  }
}
