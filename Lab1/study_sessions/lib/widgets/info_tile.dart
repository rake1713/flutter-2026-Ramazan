import 'package:flutter/material.dart';

/// A row: icon on the left, a title and an optional subtitle.
/// Like ListTile, but without a leading parameter.
class InfoTile extends StatelessWidget {
  final Widget icon;
  final String title;
  final String? subtitle;
  final bool highlighted;
  final VoidCallback? onTap;

  const InfoTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.highlighted = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final sub = subtitle;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.bodyLarge?.copyWith(
                      color: highlighted ? colorScheme.primary : null,
                      fontWeight: highlighted ? FontWeight.bold : null,
                    ),
                  ),
                  if (sub != null)
                    Text(
                      sub,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
