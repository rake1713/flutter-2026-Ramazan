import 'dart:collection';

import 'subject.dart';

/// One study session: a time, a place and a limited number of seats.
class StudySession {
  const StudySession({
    required this.id,
    required this.title,
    required this.subject,
    required this.startsAt,
    required this.place,
    required this.capacity,
    // A private named parameter: callers write `members:`,
    // the field itself stays private.
    this._members = const [],
    this.isOnline = false,
    this.agenda,
    this.isFavourite = false,
  });

  /// Defaults for a new session in the form.
  StudySession.empty()
    : id = '',
      title = '',
      subject = Subject.programming,
      startsAt = DateTime.now(),
      place = '',
      capacity = 10,
      _members = const [],
      isOnline = false,
      agenda = null,
      isFavourite = false;

  /// How long every session lasts.
  static const length = Duration(minutes: 90);

  final String id;
  final String title;
  final Subject subject;
  final DateTime startsAt;

  /// A room, or a link when [isOnline] is true.
  final String place;
  final int capacity;
  final List<String> _members;

  /// Changes what [place] means: a link instead of a room.
  final bool isOnline;
  final String? agenda;
  final bool isFavourite;

  /// Read-only view: nobody outside can add or remove names.
  List<String> get members => UnmodifiableListView(_members);

  int get count => _members.length;
  int get freePlaces => capacity - count;
  bool get isFull => freePlaces <= 0;
  DateTime get endsAt => startsAt.add(length);
  bool get isPast => DateTime.now().isAfter(endsAt);
  bool contains(String name) => _members.any((m) => m == name);

  ({int taken, int free}) get places => (taken: count, free: freePlaces);

  StudySession copyWith({
    String? title,
    Subject? subject,
    DateTime? startsAt,
    String? place,
    int? capacity,
    List<String>? members,
    bool? isOnline,
    bool? isFavourite,
  }) => StudySession(
    id: id,
    title: title ?? this.title,
    subject: subject ?? this.subject,
    startsAt: startsAt ?? this.startsAt,
    place: place ?? this.place,
    capacity: capacity ?? this.capacity,
    members: members ?? _members,
    isOnline: isOnline ?? this.isOnline,
    agenda: agenda,
    isFavourite: isFavourite ?? this.isFavourite,
  );

  /// Upcoming first by date, past ones last.
  static int byDate(StudySession a, StudySession b) {
    if (a.isPast != b.isPast) return a.isPast ? 1 : -1;
    return a.startsAt.compareTo(b.startsAt);
  }
}
