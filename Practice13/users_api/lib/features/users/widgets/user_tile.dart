import 'package:flutter/material.dart';
import 'package:users_api/features/users/user.dart';

class UserTile extends StatelessWidget {
  const UserTile({super.key, required this.user, required this.onTap});

  final User user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(user.name),
      subtitle: Text('${user.email}\n${user.address.city}'),
      isThreeLine: true,
      onTap: onTap,
    );
  }
}
