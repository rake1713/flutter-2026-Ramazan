import 'package:flutter/material.dart';

import '../models/study_session.dart';
import '../widgets/empty_state.dart';
import '../widgets/session_list.dart';

/// Tab 2: only the favourites, same card, same list.
class FavouritesTab extends StatelessWidget {
  const FavouritesTab({
    super.key,
    required this.sessions,
    required this.onOpen,
    required this.onToggleFavourite,
    required this.onBrowse,
  });

  final List<StudySession> sessions;
  final ValueChanged<StudySession> onOpen;
  final ValueChanged<StudySession> onToggleFavourite;

  /// Asks the shell to switch to the first tab.
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final favourites = sessions.where((s) => s.isFavourite).toList()
      ..sort(StudySession.byDate);
    if (favourites.isEmpty) {
      return EmptyState(
        icon: Icons.favorite_border,
        message: 'No favourites yet',
        actionLabel: 'Browse sessions',
        onAction: onBrowse,
      );
    }
    return SessionList(
      sessions: favourites,
      onOpen: onOpen,
      onToggleFavourite: onToggleFavourite,
    );
  }
}
