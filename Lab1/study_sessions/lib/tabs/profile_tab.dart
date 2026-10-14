import 'package:flutter/material.dart';

import '../models/profile.dart';
import '../models/study_session.dart';

/// Tab 3: name, group and the theme. Everything goes up through callbacks.
class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required this.profile,
    required this.sessions,
    required this.themeMode,
    required this.onProfileChanged,
    required this.onThemeModeChanged,
  });

  final Profile profile;
  final List<StudySession> sessions;
  final ThemeMode themeMode;
  final ValueChanged<Profile> onProfileChanged;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  static final _groupPattern = RegExp(r'^[A-Z]{2,4}-\d{4}$');

  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.profile.name);
  late final _groupController = TextEditingController(
    text: widget.profile.group,
  );

  @override
  void didUpdateWidget(ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset data replaces the profile from above: show the new values.
    if (widget.profile != oldWidget.profile) {
      _nameController.text = widget.profile.name;
      _groupController.text = widget.profile.group;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _groupController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) =>
      (value?.trim().isEmpty ?? true) ? 'Enter your name' : null;

  String? _validateGroup(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null; // the group is optional
    return _groupPattern.hasMatch(text) ? null : 'Like IT-2302';
  }

  void _save(String _) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    widget.onProfileChanged(
      Profile(
        name: _nameController.text.trim(),
        group: _groupController.text.trim(),
      ),
    );
  }

  String _label(ThemeMode mode) => switch (mode) {
    ThemeMode.system => 'System',
    ThemeMode.light => 'Light',
    ThemeMode.dark => 'Dark',
  };

  @override
  Widget build(BuildContext context) {
    final name = widget.profile.name;
    final lists = widget.sessions.fold(
      0,
      (n, s) => s.contains(name) ? n + 1 : n,
    );
    final textTheme = Theme.of(context).textTheme;

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              helperText: 'Press Enter to save',
              prefixIcon: Icon(Icons.person),
            ),
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            onFieldSubmitted: _save,
            validator: _validateName,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _groupController,
            decoration: const InputDecoration(
              labelText: 'Group',
              helperText: 'Press Enter to save',
              prefixIcon: Icon(Icons.groups),
            ),
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.done,
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            onFieldSubmitted: _save,
            validator: _validateGroup,
          ),
          const SizedBox(height: 24),
          Text(
            name.isEmpty
                ? 'Enter your name to join sessions'
                : 'You are on $lists lists',
            style: textTheme.titleMedium,
          ),
          const SizedBox(height: 24),
          Text('Theme', style: textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final mode in ThemeMode.values)
                ChoiceChip(
                  label: Text(_label(mode)),
                  selected: widget.themeMode == mode,
                  onSelected: (_) => widget.onThemeModeChanged(mode),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
