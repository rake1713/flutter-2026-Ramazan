import 'package:flutter/material.dart';

import '../models/study_session.dart';

/// Subject icon in a circle with a badge: FULL, or "N left" when 5 or fewer.
class SessionAvatar extends StatelessWidget {
  const SessionAvatar({super.key, required this.session});

  final StudySession session;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (taken: _, :free) = session.places;
    return SizedBox(
      width: 56,
      height: 60,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: CircleAvatar(
              radius: 26,
              backgroundColor: session.subject.color(scheme),
              foregroundColor: scheme.onSurface,
              child: Icon(session.subject.icon),
            ),
          ),
          if (session.isFull)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _Badge(
                text: 'FULL',
                background: scheme.error,
                foreground: scheme.onError,
              ),
            )
          else if (free <= 5)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _Badge(
                text: '$free left',
                background: scheme.tertiary,
                foreground: scheme.onTertiary,
              ),
            ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.text,
    required this.background,
    required this.foreground,
  });

  final String text;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          maxLines: 1,
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: foreground),
        ),
      ),
    );
  }
}
