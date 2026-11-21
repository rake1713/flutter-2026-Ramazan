import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../auth/auth_model.dart';
import 'user.dart';

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({super.key, required this.user});

  final User user;

  Future<void> _open(BuildContext context, Uri uri) async {
    final ok = await launchUrl(uri);
    if (ok || !context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('No app can open this')));
  }

  Future<void> _copyToken(BuildContext context) async {
    final token = context.read<AuthModel>().token ?? '';
    await Clipboard.setData(ClipboardData(text: token));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Token copied')));
  }

  @override
  Widget build(BuildContext context) {
    final a = user.address;
    final website = user.website;
    return Scaffold(
      appBar: AppBar(title: Text(user.name)),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Username'),
            subtitle: Text(user.username),
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: Text(user.email),
            onTap: () =>
                _open(context, Uri(scheme: 'mailto', path: user.email)),
          ),
          ListTile(
            leading: const Icon(Icons.phone),
            title: Text(user.phone),
            subtitle: Text(user.phoneDigits),
            onTap: () =>
                _open(context, Uri(scheme: 'tel', path: user.phoneDigits)),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(website ?? '—'),
            onTap: website == null
                ? null
                : () => _open(context, Uri.parse('https://$website')),
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
          if (kDebugMode)
            ListTile(
              leading: const Icon(Icons.key),
              title: const Text('Copy token to clipboard'),
              onTap: () => _copyToken(context),
            ),
        ],
      ),
    );
  }
}
