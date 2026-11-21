import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_model.dart';
import '../users/users_model.dart';
import 'settings_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsModel>();
    final cities = {
      for (final u in context.watch<UsersModel>().items) u.address.city,
    }.toList()..sort();
    final city = cities.contains(settings.city) ? settings.city : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Dark mode'),
            value: settings.dark,
            onChanged: (v) => settings.setDark(v),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String?>(
            initialValue: city,
            decoration: const InputDecoration(labelText: 'City'),
            items: [
              const DropdownMenuItem(value: null, child: Text('All cities')),
              for (final c in cities)
                DropdownMenuItem(value: c, child: Text(c)),
            ],
            onChanged: (c) => settings.setCity(c),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign out'),
            onTap: () async {
              await context.read<AuthModel>().logout();
              if (!context.mounted) return;
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
    );
  }
}
