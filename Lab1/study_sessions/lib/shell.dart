import 'package:flutter/material.dart';

import 'data/seed.dart';
import 'models/profile.dart';
import 'models/study_session.dart';
import 'routes.dart';
import 'tabs/favourites_tab.dart';
import 'tabs/profile_tab.dart';
import 'tabs/sessions_tab.dart';
import 'widgets/app_drawer.dart';

/// Owns the sessions, the profile and the selected tab.
/// Tabs get data through constructors and send changes back as callbacks.
class Shell extends StatefulWidget {
  const Shell({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  static const _profileTab = 2;

  List<StudySession> _sessions = seedSessions();
  Profile _profile = const Profile.empty();
  int _tab = 0;

  // ---------- changes from tabs and pushed screens ----------

  void _goToTab(int index) => setState(() => _tab = index);

  void _replace(StudySession updated) => setState(
    () => _sessions = [
      for (final s in _sessions) s.id == updated.id ? updated : s,
    ],
  );

  void _toggleFavourite(StudySession session) =>
      _replace(session.copyWith(isFavourite: !session.isFavourite));

  void _delete(StudySession session) => setState(
    () => _sessions = _sessions.where((s) => s.id != session.id).toList(),
  );

  void _setProfile(Profile profile) => setState(() => _profile = profile);

  // ---------- navigation ----------

  void _open(StudySession session) {
    Navigator.of(context).pushNamed(
      Routes.detail,
      arguments: DetailArgs(
        session: session,
        profile: _profile,
        onChanged: _replace,
        onDelete: _delete,
        onOpenProfile: () => _goToTab(_profileTab),
      ),
    );
  }

  Future<void> _create() async {
    final created = await Navigator.of(context)
        .pushNamed<StudySession>(Routes.form, arguments: const FormArgs());
    if (created == null || !mounted) return;
    setState(() => _sessions = [..._sessions, created]);
  }

  // ---------- drawer ----------

  void _showAbout() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Study Sessions'),
        content: const Text(
          'Find a study session at KBTU or online, join it and keep your '
          'favourites. Lab 1, Mobile Development, 2026.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetData() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset data?'),
        content: const Text(
          'All sessions go back to the start and the profile is cleared.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() {
      _sessions = seedSessions();
      _profile = const Profile.empty();
    });
  }

  @override
  Widget build(BuildContext context) {
    const titles = ['Study sessions', 'Favourites', 'Profile'];
    return Scaffold(
      appBar: AppBar(title: Text(titles[_tab])),
      drawer: AppDrawer(onAbout: _showAbout, onReset: _resetData),
      body: IndexedStack(
        index: _tab,
        children: [
          SessionsTab(
            sessions: _sessions,
            onOpen: _open,
            onToggleFavourite: _toggleFavourite,
          ),
          FavouritesTab(
            sessions: _sessions,
            onOpen: _open,
            onToggleFavourite: _toggleFavourite,
            onBrowse: () => _goToTab(0),
          ),
          ProfileTab(
            profile: _profile,
            sessions: _sessions,
            themeMode: widget.themeMode,
            onProfileChanged: _setProfile,
            onThemeModeChanged: widget.onThemeModeChanged,
          ),
        ],
      ),
      floatingActionButton: _tab == 0
          ? FloatingActionButton(
              onPressed: _create,
              tooltip: 'New session',
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: _goToTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note),
            label: 'Sessions',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favourites',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
