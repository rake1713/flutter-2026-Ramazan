import 'package:flutter/material.dart';

import '../models/study_session.dart';
import 'session_card.dart';

/// A list on phones, a grid when this widget gets 600 px or more.
/// LayoutBuilder asks about MY box, not about the whole screen.
class SessionList extends StatelessWidget {
  final List<StudySession> sessions;
  final void Function(StudySession) onOpen;
  final void Function(StudySession) onToggleFavourite;

  const SessionList({
    super.key,
    required this.sessions,
    required this.onOpen,
    required this.onToggleFavourite,
  });

  Widget _card(BuildContext context, int index) {
    final session = sessions[index];
    return SessionCard(
      session: session,
      onTap: () => onOpen(session),
      onToggleFavourite: () => onToggleFavourite(session),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 600) {
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 360, // a cell is never wider than 360
              mainAxisExtent: 128, // a cell needs a height: two title lines
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: sessions.length,
            itemBuilder: _card,
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 88),
          itemCount: sessions.length,
          separatorBuilder: (context, index) => const SizedBox(height: 4),
          itemBuilder: _card,
        );
      },
    );
  }
}
