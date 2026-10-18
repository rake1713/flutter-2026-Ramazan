import 'dart:async';

import 'package:flutter/material.dart';

import '../models/countdown.dart';
import '../models/profile.dart';
import '../models/study_session.dart';
import '../routes.dart';
import '../utils/format.dart';
import '../widgets/empty_state.dart';
import '../widgets/info_tile.dart';

class DetailScreen extends StatefulWidget {
  final StudySession session;
  final Profile profile;
  final void Function(StudySession) onChanged;
  final void Function(StudySession) onDelete;
  final void Function() onOpenProfile;

  const DetailScreen({
    super.key,
    required this.session,
    required this.profile,
    required this.onChanged,
    required this.onDelete,
    required this.onOpenProfile,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late StudySession _session = widget.session;
  DateTime _now = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Once a minute: the countdown text changes.
    _timer = Timer.periodic(const Duration(minutes: 1), (t) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _myName => widget.profile.name;

  /// Keep our copy for this screen and tell the shell, which owns the list.
  void _update(StudySession session) {
    setState(() => _session = session);
    widget.onChanged(session);
  }

  void _openProfile() {
    Navigator.of(context).pop();
    widget.onOpenProfile();
  }

  Future<bool> _ask(String title, String yes) async {
    final answer = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(_session.title),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(yes),
          ),
        ],
      ),
    );
    return answer == true;
  }

  Future<void> _join() async {
    if (_myName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Enter your name in Profile first'),
          action: SnackBarAction(label: 'Profile', onPressed: _openProfile),
        ),
      );
      return;
    }
    final ok = await _ask('Join this session?', 'Join');
    if (!ok || !mounted) return;
    _update(_session.copyWith(members: [..._session.members, _myName]));
  }

  void _leave() {
    final others = _session.members.where((m) => m != _myName).toList();
    _update(_session.copyWith(members: others));
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
    final ok = await _ask('Delete this session?', 'Delete');
    if (!ok || !mounted) return;
    widget.onDelete(_session);
    Navigator.of(context).pop();
  }

  Widget _primaryButton() {
    if (_session.contains(_myName)) {
      return OutlinedButton.icon(
        onPressed: _leave,
        icon: const Icon(Icons.logout),
        label: const Text('Leave'),
      );
    }
    final canJoin = !_session.isFull && !_session.isPast;
    return FilledButton.icon(
      onPressed: canJoin ? _join : null, // null = disabled
      icon: const Icon(Icons.group_add),
      label: Text(_session.isFull ? 'Full' : 'Join'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_session.title, maxLines: 1),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') _edit();
                if (value == 'delete') _delete();
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            _Header(session: _session, now: _now),
            TabBar(
              tabs: [
                const Tab(text: 'About'),
                Tab(text: 'Members (${_session.count})'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _AboutTab(session: _session),
                  _MembersTab(session: _session, myName: _myName),
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
  final StudySession session;
  final DateTime now;

  const _Header({required this.session, required this.now});

  String _countdownText() {
    return switch (countdownOf(session, now)) {
      Upcoming(:var left) => 'Starts in ${formatDuration(left)}',
      Started(:var elapsed) => 'Started ${formatDuration(elapsed)} ago',
      Ended() => 'Ended',
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AspectRatio(
      aspectRatio: 16 / 6,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/header.png', fit: BoxFit.cover),
          Center(
            child: CircleAvatar(
              radius: 32,
              backgroundColor: session.subject.color(colorScheme),
              foregroundColor: colorScheme.onSurface,
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
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _countdownText(),
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutTab extends StatelessWidget {
  final StudySession session;

  const _AboutTab({required this.session});

  @override
  Widget build(BuildContext context) {
    final (:taken, :free) = session.places;
    final agenda = session.agenda;

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
        if (agenda != null)
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
  final StudySession session;
  final String myName;

  const _MembersTab({required this.session, required this.myName});

  @override
  Widget build(BuildContext context) {
    if (session.members.isEmpty) {
      return const EmptyState(
        icon: Icons.group_off,
        message: 'Nobody has joined yet',
      );
    }
    return ListView(
      children: [
        for (final name in session.members)
          InfoTile(
            icon: CircleAvatar(child: Text(name[0])),
            title: name == myName ? 'You' : name,
            highlighted: name == myName,
          ),
      ],
    );
  }
}
