import 'package:flutter/material.dart';

import '../models/profile.dart';
import '../models/study_session.dart';

/// Tab 3: name, group and the theme. Changes go up through callbacks.
class ProfileTab extends StatefulWidget {
  final Profile profile;
  final List<StudySession> sessions;
  final ThemeMode themeMode;
  final void Function(Profile) onProfileChanged;
  final void Function(ThemeMode) onThemeModeChanged;

  const ProfileTab({
    super.key,
    required this.profile,
    required this.sessions,
    required this.themeMode,
    required this.onProfileChanged,
    required this.onThemeModeChanged,
  });

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _groupController = TextEditingController();

  /// Like IT-2302: 2–4 capital letters, a dash, 4 digits.
  final _groupPattern = RegExp(r'^[A-Z]{2,4}-\d{4}$');

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.profile.name;
    _groupController.text = widget.profile.group;
  }

  @override
  void didUpdateWidget(ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset data gives us a new empty profile: show it in the fields.
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

  String? _validateName(String? v) {
    return (v ?? '').trim().isEmpty ? 'Enter your name' : null;
  }

  String? _validateGroup(String? v) {
    final text = (v ?? '').trim();
    if (text.isEmpty) return null; // the group is optional
    if (!_groupPattern.hasMatch(text)) return 'Like IT-2302';
    return null;
  }

  void _save(String value) {
    // ! is safe: the Form is already built when a field is submitted.
    if (!_formKey.currentState!.validate()) return;
    widget.onProfileChanged(
      Profile(
        name: _nameController.text.trim(),
        group: _groupController.text.trim(),
      ),
    );
  }

  String _themeLabel(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => 'System',
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark',
    };
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.profile.name;
    // Counted again on every build, from the list itself.
    final lists = widget.sessions.fold(
      0,
      (count, s) => s.contains(name) ? count + 1 : count,
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
            textInputAction: TextInputAction.next,
            onTapOutside: (event) =>
                FocusManager.instance.primaryFocus?.unfocus(),
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
            textInputAction: TextInputAction.done,
            onTapOutside: (event) =>
                FocusManager.instance.primaryFocus?.unfocus(),
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
                  label: Text(_themeLabel(mode)),
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
