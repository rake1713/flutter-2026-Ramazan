import 'study_session.dart';

sealed class Countdown {
  const Countdown();
}

final class Upcoming extends Countdown {
  final Duration left;
  const Upcoming(this.left);
}

final class Started extends Countdown {
  final Duration elapsed;
  const Started(this.elapsed);
}

final class Ended extends Countdown {
  const Ended();
}

Countdown countdownOf(StudySession session, DateTime now) {
  if (now.isBefore(session.startsAt)) {
    return Upcoming(session.startsAt.difference(now));
  }
  if (now.isBefore(session.endsAt)) {
    return Started(now.difference(session.startsAt));
  }
  return const Ended();
}
