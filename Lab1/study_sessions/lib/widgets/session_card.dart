import 'package:flutter/material.dart';

import '../models/study_session.dart';
import '../utils/format.dart';
import 'session_avatar.dart';

/// The one card used by the list, the grid and favourites.
class SessionCard extends StatelessWidget {
  const SessionCard({
    super.key,
    required this.session,
    required this.onTap,
    required this.onToggleFavourite,
  });

  final StudySession session;
  final VoidCallback onTap;
  final VoidCallback onToggleFavourite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondary = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SessionAvatar(session: session),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      session.isPast
                          ? '${formatDateTime(session.startsAt)} · ended'
                          : formatDateTime(session.startsAt),
                      style: secondary,
                    ),
                    Text(
                      session.place,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: secondary,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onToggleFavourite,
                tooltip: session.isFavourite
                    ? 'Remove from favourites'
                    : 'Add to favourites',
                icon: Icon(
                  session.isFavourite ? Icons.favorite : Icons.favorite_border,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
