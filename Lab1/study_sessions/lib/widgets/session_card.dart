import 'package:flutter/material.dart';

import '../models/study_session.dart';
import '../utils/format.dart';
import 'session_avatar.dart';

class SessionCard extends StatelessWidget {
  final StudySession session;
  final VoidCallback onTap;
  final VoidCallback onToggleFavourite;

  const SessionCard({
    super.key,
    required this.session,
    required this.onTap,
    required this.onToggleFavourite,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final greyText = textTheme.bodyMedium?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );

    String date = formatDateTime(session.startsAt);
    if (session.isPast) {
      date = '$date · ended';
    }

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
                      style: textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(date, style: greyText),
                    Text(
                      session.place,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: greyText,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onToggleFavourite,
                tooltip: 'Favourite',
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
