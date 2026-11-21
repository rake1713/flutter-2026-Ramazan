import 'package:flutter/material.dart';
import 'package:users_api/features/users/user.dart';
import 'package:users_api/features/users/user_detail_screen.dart';
import 'package:users_api/features/users/widgets/user_tile.dart';

class UserList extends StatelessWidget {
  const UserList(this.users, {super.key});

  final List<User> users;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: users.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final u = users[i];
        return UserTile(
          user: u,
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => UserDetailScreen(user: u))),
        );
      },
    );
  }
}
