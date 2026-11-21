import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:users_api/core/env.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  late final Future<PackageInfo> _info;

  @override
  void initState() {
    super.initState();
    _info = PackageInfo.fromPlatform();
  }

  String get _mode {
    if (kReleaseMode) return 'release';
    if (kProfileMode) return 'profile';
    return 'debug';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: FutureBuilder<PackageInfo>(
        future: _info,
        builder: (context, snapshot) {
          final info = snapshot.data;
          final version = info == null
              ? '…'
              : '${info.version} (${info.buildNumber})';
          return ListView(
            children: [
              ListTile(title: const Text('Version'), subtitle: Text(version)),
              ListTile(title: const Text('Build mode'), subtitle: Text(_mode)),
              const ListTile(
                title: Text('Environment'),
                subtitle: Text(Env.name),
              ),
              const ListTile(title: Text('API host'), subtitle: Text(Env.host)),
              ListTile(
                leading: const Icon(Icons.description),
                title: const Text('Licences'),
                onTap: () => showLicensePage(context: context),
              ),
            ],
          );
        },
      ),
    );
  }
}
