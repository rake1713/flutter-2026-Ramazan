import 'package:flutter/material.dart';

import '../models/study_session.dart';
import 'session_card.dart';

/// A list on phones, a grid from 600 px. The width that matters is the one
/// this widget gets, not the screen's, so it is a LayoutBuilder.
class SessionList extends StatelessWidget {
  const SessionList({
    super.key,
    required this.sessions,
    required this.onOpen,
    required this.onToggleFavourite,
  });

  static const gridBreakpoint = 600.0;
  static const maxCellWidth = 360.0;

  final List<StudySession> sessions;
  final ValueChanged<StudySession> onOpen;
  final ValueChanged<StudySession> onToggleFavourite;

  Widget _card(StudySession s) => SessionCard(
    key: ValueKey(s.id),
    session: s,
    onTap: () => onOpen(s),
    onToggleFavourite: () => onToggleFavourite(s),
  );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= gridBreakpoint) {
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: maxCellWidth,
              // A grid cell needs a height; this fits two title lines.
              mainAxisExtent: 128,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: sessions.length,
            itemBuilder: (context, i) => _card(sessions[i]),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 88),
          itemCount: sessions.length,
          separatorBuilder: (context, i) => const SizedBox(height: 4),
          itemBuilder: (context, i) => _card(sessions[i]),
        );
      },
    );
  }
}
