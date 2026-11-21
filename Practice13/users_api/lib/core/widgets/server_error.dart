import 'package:flutter/material.dart';

import 'message_view.dart';

class ServerError extends StatelessWidget {
  const ServerError(this.status, {super.key, required this.onRetry});

  final int status;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return MessageView(
      icon: Icons.cloud_off,
      text: 'Server error ($status)',
      onRetry: onRetry,
    );
  }
}
