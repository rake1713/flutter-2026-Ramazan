import 'package:flutter/material.dart';

import 'message_view.dart';

class Offline extends StatelessWidget {
  const Offline({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return MessageView(
      icon: Icons.wifi_off,
      text: 'No connection',
      onRetry: onRetry,
    );
  }
}
