import 'subject.dart';

class StudySession {
  final String id;
  final String title;
  final Subject subject;
  final DateTime startsAt;

  final String place;
  final int capacity;

  final List<String> members;

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

  static int byDate(StudySession a, StudySession b) {
    if (a.isPast != b.isPast) {
      return a.isPast ? 1 : -1;
    }
    return a.startsAt.compareTo(b.startsAt);
  }
}
