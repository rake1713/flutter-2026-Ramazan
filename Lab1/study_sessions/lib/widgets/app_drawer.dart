import 'package:flutter/material.dart';

import 'info_tile.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, required this.onAbout, required this.onReset});

  final VoidCallback onAbout;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text('Study Sessions', style: theme.textTheme.titleLarge),
            ),
          ),
          InfoTile(
            icon: const Icon(Icons.info_outline),
            title: 'About',
            onTap: () {
              Navigator.pop(context);
              onAbout();
            },
          ),
          InfoTile(
            icon: const Icon(Icons.restore),
            title: 'Reset data',
            onTap: () {
              Navigator.pop(context);
              onReset();
            },
          ),
        ],
      ),
    );
  }
}
