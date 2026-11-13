import 'package:flutter/material.dart';

import 'user.dart';

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final a = user.address;
    return Scaffold(
      appBar: AppBar(title: Text(user.name)),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Username'),
            subtitle: Text(user.username),
          ),
          ListTile(title: const Text('Email'), subtitle: Text(user.email)),
          ListTile(
            leading: const Icon(Icons.phone),
            title: Text(user.phone),
            subtitle: Text(user.phoneDigits),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(user.website ?? '—'),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Address'),
            subtitle: Text(
              '${a.street}, ${a.suite}\n${a.city} ${a.zipcode}\n'
              '${a.geo.lat}, ${a.geo.lng}',
            ),
            isThreeLine: true,
          ),
          ListTile(
            title: const Text('Company'),
            subtitle: Text('${user.company.name}\n${user.company.catchPhrase}'),
            isThreeLine: true,
          ),
        ],
      ),
    );
  }
}
