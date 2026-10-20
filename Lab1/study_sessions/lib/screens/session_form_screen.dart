import 'package:flutter/material.dart';

import '../models/study_session.dart';
import '../models/subject.dart';
import '../utils/format.dart';

class SessionFormScreen extends StatefulWidget {
  final StudySession? session;

  const SessionFormScreen({super.key, this.session});

  @override
  State<SessionFormScreen> createState() => _SessionFormScreenState();
}

class _SessionFormScreenState extends State<SessionFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _placeController = TextEditingController();
  final _capacityController = TextEditingController();
  final _agendaController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();

  final _placeFocus = FocusNode();
  final _capacityFocus = FocusNode();
  final _agendaFocus = FocusNode();

  late final StudySession _initial;
  late final bool _isNew;
  Subject? _initialSubject;
  DateTime? _initialDate;
  TimeOfDay? _initialTime;

  Subject? _subject;
  bool _isOnline = false;
  DateTime? _date;
  TimeOfDay? _time;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final session = widget.session;
    _isNew = session == null;
    _initial = session ?? StudySession.empty();

    if (session != null) {
      _initialSubject = session.subject;
      _initialDate = session.startsAt;
      _initialTime = TimeOfDay.fromDateTime(session.startsAt);
      _dateController.text = formatDate(session.startsAt);
      _timeController.text = formatTime(session.startsAt);
    }

    _titleController.text = _initial.title;
    _placeController.text = _initial.place;
    _capacityController.text = '${_initial.capacity}';
    _agendaController.text = _initial.agenda ?? '';

    _subject = _initialSubject;
    _isOnline = _initial.isOnline;
    _date = _initialDate;
    _time = _initialTime;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _placeController.dispose();
    _capacityController.dispose();
    _agendaController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _placeFocus.dispose();
    _capacityFocus.dispose();
    _agendaFocus.dispose();
    super.dispose();
  }

  DateTime? _combine(DateTime? date, TimeOfDay? time) {
    if (date == null || time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  bool get _dirty {
    return _titleController.text != _initial.title ||
        _placeController.text != _initial.place ||
        _capacityController.text != '${_initial.capacity}' ||
        _agendaController.text != (_initial.agenda ?? '') ||
        _subject != _initialSubject ||
        _isOnline != _initial.isOnline ||
        _combine(_date, _time) != _combine(_initialDate, _initialTime);
  }

  void _hideKeyboard(PointerDownEvent event) {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  String? _validateTitle(String? v) {
    final length = (v ?? '').trim().length;
    if (length < 3) return 'At least 3 characters';
    if (length > 60) return 'At most 60 characters';
    return null;
  }

  String? _validatePlace(String? v) {
    final text = (v ?? '').trim();
    if (text.isEmpty) return _isOnline ? 'Enter a link' : 'Enter a room';
    if (_isOnline && !text.contains('://')) return 'A link contains ://';
    return null;
  }

  String? _validateCapacity(String? v) {
    final number = int.tryParse((v ?? '').trim());
    if (number == null) return 'Enter a whole number';
    if (number < 1 || number > 500) return 'From 1 to 500';
    if (number < _initial.count) return '${_initial.count} already joined';
    return null;
  }

  String? _validateSubject(Subject? v) {
    return v == null ? 'Choose a subject' : null;
  }

  String? _validateDate(String? v) {
    return _date == null ? 'Pick a date' : null;
  }

  String? _validateTime(String? v) {
    if (_time == null) return 'Pick a time';
    final startsAt = _combine(_date, _time);
    if (_isNew && startsAt != null && startsAt.isBefore(DateTime.now())) {
      return 'Must be in the future';
    }
    return null;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1, 12, 31),
    );
    if (picked == null || !mounted) return;
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
    if (picked == null || !mounted) return;
    setState(() {
      _time = picked;
      _timeController.text = formatTime(
        DateTime(2000, 1, 1, picked.hour, picked.minute),
      );
    });
  }

  Future<void> _save() async {
    // ! is safe: the Form is already built when the button is pressed.
    if (!_formKey.currentState!.validate()) return;
    final subject = _subject;
    final startsAt = _combine(_date, _time);
    if (subject == null || startsAt == null) return;

    setState(() => _saving = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    final agenda = _agendaController.text.trim();
    final session = StudySession(
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
    );
    Navigator.of(context).pop(session);
  }

  Future<void> _askDiscard() async {
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
    if (discard == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _askDiscard();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(_isNew ? 'New session' : 'Edit session')),
        body: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: () => setState(() {}),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  maxLength: 60,
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
                        onTap: _pickDate,
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        validator: _validateDate,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _timeController,
                        readOnly: true,
                        onTap: _pickTime,
                        decoration: const InputDecoration(
                          labelText: 'Time',
                          prefixIcon: Icon(Icons.schedule),
                        ),
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
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _save(),
                  onTapOutside: _hideKeyboard,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
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
