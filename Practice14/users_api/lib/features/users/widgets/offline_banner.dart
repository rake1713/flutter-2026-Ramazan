import 'package:flutter/material.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return MaterialBanner(
      content: const Text('Saved data · no connection'),
      leading: const Icon(Icons.cloud_off),
      actions: [TextButton(onPressed: onRetry, child: const Text('Retry'))],
    );
  }
}
