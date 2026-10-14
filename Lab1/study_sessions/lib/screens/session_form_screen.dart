import 'package:flutter/material.dart';

import '../models/study_session.dart';
import '../models/subject.dart';
import '../utils/format.dart';

/// New and edit in one screen. Takes a session or null; pops a session.
class SessionFormScreen extends StatefulWidget {
  const SessionFormScreen({super.key, this.session});

  final StudySession? session;

  @override
  State<SessionFormScreen> createState() => _SessionFormScreenState();
}

class _SessionFormScreenState extends State<SessionFormScreen> {
  final _formKey = GlobalKey<FormState>();

  /// What the form opened with; _dirty compares against it.
  late final StudySession _initial = widget.session ?? StudySession.empty();
  late final bool _isNew = widget.session == null;
  late final Subject? _initialSubject = widget.session?.subject;
  late final DateTime? _initialDate = widget.session?.startsAt;
  late final TimeOfDay? _initialTime = switch (widget.session) {
    final s? => TimeOfDay.fromDateTime(s.startsAt),
    null => null,
  };

  late final _titleController = TextEditingController(text: _initial.title);
  late final _placeController = TextEditingController(text: _initial.place);
  late final _capacityController = TextEditingController(
    text: '${_initial.capacity}',
  );
  late final _agendaController = TextEditingController(
    text: _initial.agenda ?? '',
  );
  late final _dateController = TextEditingController(
    text: switch (_initialDate) {
      final d? => formatDate(d),
      null => '',
    },
  );
  late final _timeController = TextEditingController(
    text: switch (_initialDate) {
      final d? => formatTime(d),
      null => '',
    },
  );

  final _titleFocus = FocusNode();
  final _placeFocus = FocusNode();
  final _capacityFocus = FocusNode();
  final _agendaFocus = FocusNode();

  late Subject? _subject = _initialSubject;
  late bool _isOnline = _initial.isOnline;
  late DateTime? _date = _initialDate;
  late TimeOfDay? _time = _initialTime;
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _placeController.dispose();
    _capacityController.dispose();
    _agendaController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _titleFocus.dispose();
    _placeFocus.dispose();
    _capacityFocus.dispose();
    _agendaFocus.dispose();
    super.dispose();
  }

  /// The date and the time as one DateTime, or null while one is missing.
  DateTime? get _startsAt => _startsAtOf(_date, _time);

  /// Current values differ from the ones the form opened with.
  bool get _dirty =>
      _titleController.text != _initial.title ||
      _placeController.text != _initial.place ||
      _capacityController.text != '${_initial.capacity}' ||
      _agendaController.text != (_initial.agenda ?? '') ||
      _subject != _initialSubject ||
      _isOnline != _initial.isOnline ||
      _startsAt != _startsAtOf(_initialDate, _initialTime);

  static DateTime? _startsAtOf(DateTime? d, TimeOfDay? t) => switch ((d, t)) {
    (final d?, final t?) => DateTime(d.year, d.month, d.day, t.hour, t.minute),
    _ => null,
  };

  // ---------- validators ----------

  String? _validateTitle(String? value) {
    final length = value?.trim().length ?? 0;
    if (length < 3) return 'At least 3 characters';
    if (length > 60) return 'At most 60 characters';
    return null;
  }

  String? _validatePlace(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return _isOnline ? 'Enter a link' : 'Enter a room';
    if (_isOnline && !text.contains('://')) return 'A link contains ://';
    return null;
  }

  String? _validateCapacity(String? value) {
    final number = int.tryParse(value?.trim() ?? '');
    if (number == null) return 'Enter a whole number';
    if (number < 1 || number > 500) return 'From 1 to 500';
    if (number < _initial.count) return '${_initial.count} already joined';
    return null;
  }

  String? _validateSubject(Subject? value) =>
      value == null ? 'Choose a subject' : null;

  String? _validateDate(String? _) => _date == null ? 'Pick a date' : null;

  String? _validateTime(String? _) {
    if (_time == null) return 'Pick a time';
    final startsAt = _startsAt;
    if (_isNew && startsAt != null && !startsAt.isAfter(DateTime.now())) {
      return 'Must be in the future';
    }
    return null;
  }

  // ---------- pickers ----------

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1, 12, 31),
    );
    if (picked == null || !mounted) return; // Cancel keeps the old value
    setState(() {
      _date = picked;
      _dateController.text = formatDate(picked);
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
    );
    if (picked == null || !mounted) return; // Cancel keeps the old value
    setState(() {
      _time = picked;
      _timeController.text = formatTime(
        DateTime(2000, 1, 1, picked.hour, picked.minute),
      );
    });
  }

  // ---------- save and leave ----------

  Future<void> _save() async {
    final valid = _formKey.currentState?.validate() ?? false;
    final subject = _subject;
    final startsAt = _startsAt;
    // The validators already reject a missing subject, date or time.
    if (!valid || subject == null || startsAt == null) return;

    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    final agenda = _agendaController.text.trim();
    Navigator.of(context).pop(
      StudySession(
        id: _isNew ? '${DateTime.now().microsecondsSinceEpoch}' : _initial.id,
        title: _titleController.text.trim(),
        subject: subject,
        startsAt: startsAt,
        place: _placeController.text.trim(),
        capacity: int.parse(_capacityController.text.trim()),
        members: _initial.members,
        isOnline: _isOnline,
        agenda: agenda.isEmpty ? null : agenda,
        isFavourite: _initial.isFavourite,
      ),
    );
  }

  Future<void> _confirmDiscard() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep editing'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (discard != true || !mounted) return;
    Navigator.of(context).pop();
  }

  void _hideKeyboard(PointerDownEvent _) => FocusScope.of(context).unfocus();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _confirmDiscard();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(_isNew ? 'New session' : 'Edit session')),
        body: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: () => setState(() {}), // re-evaluate _dirty
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  focusNode: _titleFocus,
                  decoration: const InputDecoration(labelText: 'Title'),
                  maxLength: 60,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => _placeFocus.requestFocus(),
                  onTapOutside: _hideKeyboard,
                  validator: _validateTitle,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<Subject>(
                  initialValue: _subject,
                  decoration: const InputDecoration(labelText: 'Subject'),
                  items: [
                    for (final subject in Subject.values)
                      DropdownMenuItem(
                        value: subject,
                        child: Row(
                          children: [
                            Icon(subject.icon),
                            const SizedBox(width: 12),
                            Text(subject.label),
                          ],
                        ),
                      ),
                  ],
                  onChanged: (value) => setState(() => _subject = value),
                  validator: _validateSubject,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Online session'),
                  subtitle: const Text('The place becomes a link'),
                  value: _isOnline,
                  onChanged: (value) => setState(() => _isOnline = value),
                ),
                TextFormField(
                  controller: _placeController,
                  focusNode: _placeFocus,
                  decoration: InputDecoration(
                    labelText: _isOnline ? 'Link' : 'Room',
                    prefixIcon: Icon(_isOnline ? Icons.link : Icons.place),
                  ),
                  keyboardType: _isOnline
                      ? TextInputType.url
                      : TextInputType.text,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => _capacityFocus.requestFocus(),
                  onTapOutside: _hideKeyboard,
                  validator: _validatePlace,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _capacityController,
                  focusNode: _capacityFocus,
                  decoration: const InputDecoration(
                    labelText: 'Places',
                    prefixIcon: Icon(Icons.event_seat),
                  ),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => _agendaFocus.requestFocus(),
                  onTapOutside: _hideKeyboard,
                  validator: _validateCapacity,
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _dateController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        onTap: _pickDate,
                        validator: _validateDate,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _timeController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Time',
                          prefixIcon: Icon(Icons.schedule),
                        ),
                        onTap: _pickTime,
                        validator: _validateTime,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _agendaController,
                  focusNode: _agendaFocus,
                  decoration: const InputDecoration(
                    labelText: 'Agenda (optional)',
                    prefixIcon: Icon(Icons.notes),
                  ),
                  minLines: 1,
                  maxLines: 4,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _agendaFocus.unfocus(),
                  onTapOutside: _hideKeyboard,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
