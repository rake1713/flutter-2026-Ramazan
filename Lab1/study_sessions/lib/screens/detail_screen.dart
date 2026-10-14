import 'dart:async';

import 'package:flutter/material.dart';

import '../models/countdown.dart';
import '../models/profile.dart';
import '../models/study_session.dart';
import '../routes.dart';
import '../utils/format.dart';
import '../widgets/empty_state.dart';
import '../widgets/info_tile.dart';

enum _MenuAction { edit, delete }

class DetailScreen extends StatefulWidget {
  const DetailScreen({
    super.key,
    required this.session,
    required this.profile,
    required this.onChanged,
    required this.onDelete,
    required this.onOpenProfile,
  });

  final StudySession session;
  final Profile profile;
  final ValueChanged<StudySession> onChanged;
  final ValueChanged<StudySession> onDelete;
  final VoidCallback onOpenProfile;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late StudySession _session = widget.session;
  DateTime _now = DateTime.now();
  late final Timer _timer;

  String get _me => widget.profile.name;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => setState(() => _now = DateTime.now()),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  /// Keep our copy and tell the shell, which owns the list.
  void _update(StudySession session) {
    setState(() => _session = session);
    widget.onChanged(session);
  }

  void _openProfile() {
    Navigator.of(context).pop();
    widget.onOpenProfile();
  }

  Future<void> _join() async {
    if (_me.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Enter your name in Profile first'),
          action: SnackBarAction(label: 'Profile', onPressed: _openProfile),
        ),
      );
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Join this session?'),
        content: Text(_session.title),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Join'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    _update(_session.copyWith(members: [..._session.members, _me]));
  }

  void _leave() {
    _update(
      _session.copyWith(
        members: _session.members.where((m) => m != _me).toList(),
      ),
    );
  }

  Future<void> _edit() async {
    final edited = await Navigator.of(context).pushNamed<StudySession>(
      Routes.form,
      arguments: FormArgs(session: _session),
    );
    if (edited == null || !mounted) return;
    _update(edited);
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this session?'),
        content: Text(_session.title),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    widget.onDelete(_session);
    Navigator.of(context).pop();
  }

  void _onMenu(_MenuAction action) => switch (action) {
    _MenuAction.edit => _edit(),
    _MenuAction.delete => _delete(),
  };

  Widget _primaryButton() {
    if (_session.contains(_me)) {
      return OutlinedButton.icon(
        onPressed: _leave,
        icon: const Icon(Icons.logout),
        label: const Text('Leave'),
      );
    }
    final canJoin = !_session.isFull && !_session.isPast;
    return FilledButton.icon(
      onPressed: canJoin ? _join : null,
      icon: const Icon(Icons.group_add),
      label: Text(_session.isFull ? 'Full' : 'Join'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final (:taken, free: _) = _session.places;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_session.title, maxLines: 1),
          actions: [
            PopupMenuButton<_MenuAction>(
              onSelected: _onMenu,
              itemBuilder: (context) => const [
                PopupMenuItem(value: _MenuAction.edit, child: Text('Edit')),
                PopupMenuItem(value: _MenuAction.delete, child: Text('Delete')),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            _Header(session: _session, countdown: Countdown.of(_session, _now)),
            TabBar(
              tabs: [
                const Tab(text: 'About'),
                Tab(text: 'Members ($taken)'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _AboutTab(session: _session),
                  _MembersTab(session: _session, me: _me),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: _primaryButton(),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.session, required this.countdown});

  final StudySession session;
  final Countdown countdown;

  String get _countdownText => switch (countdown) {
    Upcoming(:final left) => 'Starts in ${formatDuration(left)}',
    Started(:final elapsed) => 'Started ${formatDuration(elapsed)} ago',
    Ended() => 'Ended',
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final labelStyle = Theme.of(context).textTheme.labelLarge;
    return AspectRatio(
      aspectRatio: 16 / 6,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/header.png', fit: BoxFit.cover),
          Center(
            child: CircleAvatar(
              radius: 32,
              backgroundColor: session.subject.color(scheme),
              foregroundColor: scheme.onSurface,
              child: Icon(session.subject.icon, size: 32),
            ),
          ),
          Positioned(
            left: 12,
            top: 12,
            child: Chip(
              avatar: Icon(session.subject.icon, size: 18),
              label: Text(session.subject.label),
            ),
          ),
          Positioned(
            right: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(_countdownText, style: labelStyle),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutTab extends StatelessWidget {
  const _AboutTab({required this.session});

  final StudySession session;

  @override
  Widget build(BuildContext context) {
    final (:taken, :free) = session.places;
    return ListView(
      children: [
        InfoTile(
          icon: const Icon(Icons.schedule),
          title: formatDateTime(session.startsAt),
          subtitle: 'Until ${formatTime(session.endsAt)}',
        ),
        InfoTile(
          icon: Icon(session.isOnline ? Icons.link : Icons.place),
          title: session.place,
          subtitle: session.isOnline ? 'Online' : 'In person',
        ),
        InfoTile(
          icon: const Icon(Icons.event_seat),
          title: '$taken of ${session.capacity} places taken',
          subtitle: free > 0 ? '$free free' : 'No free places',
        ),
        if (session.agenda case final agenda?)
          InfoTile(
            icon: const Icon(Icons.notes),
            title: 'Agenda',
            subtitle: agenda,
          ),
      ],
    );
  }
}

class _MembersTab extends StatelessWidget {
  const _MembersTab({required this.session, required this.me});

  final StudySession session;
  final String me;

  @override
  Widget build(BuildContext context) {
    final members = session.members;
    if (members.isEmpty) {
      return const EmptyState(
        icon: Icons.group_off,
        message: 'Nobody has joined yet',
      );
    }
    return ListView(
      children: [
        for (final name in members)
          InfoTile(
            selected: name == me,
            icon: CircleAvatar(child: Text(name[0])),
            title: name == me ? 'You' : name,
          ),
      ],
    );
  }
}
