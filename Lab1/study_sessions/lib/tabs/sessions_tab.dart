import 'package:flutter/material.dart';

import '../models/study_session.dart';
import '../models/subject.dart';
import '../widgets/empty_state.dart';
import '../widgets/session_list.dart';

/// Tab 1: search, subject chips, past filter and the list.
/// The sessions come from the shell; this tab only keeps its filters.
class SessionsTab extends StatefulWidget {
  const SessionsTab({
    super.key,
    required this.sessions,
    required this.onOpen,
    required this.onToggleFavourite,
  });

  final List<StudySession> sessions;
  final ValueChanged<StudySession> onOpen;
  final ValueChanged<StudySession> onToggleFavourite;

  @override
  State<SessionsTab> createState() => _SessionsTabState();
}

class _SessionsTabState extends State<SessionsTab> {
  final _searchController = TextEditingController();
  String _query = '';
  Subject? _subject; // null means All
  bool _showPast = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  List<StudySession> get _visible {
    final query = _query.trim().toLowerCase();
    return widget.sessions
        .where((s) => _showPast || !s.isPast)
        .where((s) => _subject == null || s.subject == _subject)
        .where((s) => s.title.toLowerCase().contains(query))
        .toList() // a new list, so sorting never touches the shell's state
      ..sort(StudySession.byDate);
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value),
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search by title',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      onPressed: _clearSearch,
                      tooltip: 'Clear',
                      icon: const Icon(Icons.clear),
                    ),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _subject == null,
                onSelected: (_) => setState(() => _subject = null),
              ),
              for (final subject in Subject.values)
                ChoiceChip(
                  avatar: Icon(subject.icon),
                  label: Text(subject.label),
                  selected: _subject == subject,
                  onSelected: (_) => setState(() => _subject = subject),
                ),
              FilterChip(
                label: const Text('Past'),
                selected: _showPast,
                onSelected: (value) => setState(() => _showPast = value),
              ),
            ],
          ),
        ),
        Expanded(
          child: visible.isEmpty
              ? EmptyState(
                  icon: Icons.search_off,
                  message: 'No sessions match',
                  actionLabel: _query.isEmpty ? null : 'Clear search',
                  onAction: _clearSearch,
                )
              : SessionList(
                  sessions: visible,
                  onOpen: widget.onOpen,
                  onToggleFavourite: widget.onToggleFavourite,
                ),
        ),
      ],
    );
  }
}
