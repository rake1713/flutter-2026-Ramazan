import 'package:flutter/material.dart';

import '../models/study_session.dart';
import '../widgets/empty_state.dart';
import '../widgets/session_list.dart';

class FavouritesTab extends StatelessWidget {
  final List<StudySession> sessions;
  final void Function(StudySession) onOpen;
  final void Function(StudySession) onToggleFavourite;

  final VoidCallback onBrowse;

  const FavouritesTab({
    super.key,
    required this.sessions,
    required this.onOpen,
    required this.onToggleFavourite,
    required this.onBrowse,
  });

  @override
  Widget build(BuildContext context) {
    final favourites = sessions.where((s) => s.isFavourite).toList();
    favourites.sort(StudySession.byDate);

    if (favourites.isEmpty) {
      return EmptyState(
        icon: Icons.favorite_border,
        message: 'No favourites yet',
        buttonLabel: 'Browse sessions',
        onButton: onBrowse,
      );
    }
    return SessionList(
      sessions: favourites,
      onOpen: onOpen,
      onToggleFavourite: onToggleFavourite,
    );
  }
}
