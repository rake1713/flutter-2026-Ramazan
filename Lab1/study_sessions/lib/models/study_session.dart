import 'subject.dart';

/// One study session: a time, a place and a limited number of places.
class StudySession {
  final String id;
  final String title;
  final Subject subject;
  final DateTime startsAt;

  /// A room, or a link when [isOnline] is true.
  final String place;
  final int capacity;

  /// Names of people who joined. Seed lists are const and copyWith wraps
  /// new lists in List.unmodifiable, so nobody can add a name from outside.
  final List<String> members;

  /// Changes what [place] means: a link instead of a room.
  final bool isOnline;
  final String? agenda;
  final bool isFavourite;

  const StudySession({
    required this.id,
    required this.title,
    required this.subject,
    required this.startsAt,
    required this.place,
    required this.capacity,
    this.members = const [],
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
      members = const [],
      isOnline = false,
      agenda = null,
      isFavourite = false;

  /// How long every session lasts.
  static const length = Duration(minutes: 90);

  int get count => members.length;
  int get freePlaces => capacity - count;
  bool get isFull => freePlaces <= 0;
  DateTime get endsAt => startsAt.add(length);
  bool get isPast => DateTime.now().isAfter(endsAt);
  bool contains(String name) => members.any((m) => m == name);

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
  }) {
    return StudySession(
      id: id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      startsAt: startsAt ?? this.startsAt,
      place: place ?? this.place,
      capacity: capacity ?? this.capacity,
      members: List.unmodifiable(members ?? this.members),
      isOnline: isOnline ?? this.isOnline,
      agenda: agenda,
      isFavourite: isFavourite ?? this.isFavourite,
    );
  }

  /// For sort: upcoming first by date, past ones last.
  static int byDate(StudySession a, StudySession b) {
    if (a.isPast != b.isPast) {
      return a.isPast ? 1 : -1;
    }
    return a.startsAt.compareTo(b.startsAt);
  }
}
