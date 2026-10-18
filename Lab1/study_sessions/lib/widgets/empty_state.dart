import 'package:flutter/material.dart';

/// One look for every "nothing here": no match, no favourites, no members.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? buttonLabel;
  final VoidCallback? onButton;

  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.buttonLabel,
    this.onButton,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = buttonLabel;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: theme.colorScheme.outline),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            if (label != null) const SizedBox(height: 12),
            if (label != null)
              FilledButton.tonal(onPressed: onButton, child: Text(label)),
          ],
        ),
      ),
    );
  }
}
