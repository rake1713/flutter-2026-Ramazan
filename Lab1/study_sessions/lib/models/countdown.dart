import 'study_session.dart';

/// Where a session is in time. Sealed: a switch over it must cover all three.
sealed class Countdown {
  const Countdown();

  factory Countdown.of(StudySession session, DateTime now) {
    if (now.isBefore(session.startsAt)) {
      return Upcoming(session.startsAt.difference(now));
    }
    if (now.isBefore(session.endsAt)) {
      return Started(now.difference(session.startsAt));
    }
    return const Ended();
  }
}

final class Upcoming extends Countdown {
  const Upcoming(this.left);
  final Duration left;
}

final class Started extends Countdown {
  const Started(this.elapsed);
  final Duration elapsed;
}

final class Ended extends Countdown {
  const Ended();
}
