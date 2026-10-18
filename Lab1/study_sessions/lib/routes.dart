import 'models/profile.dart';
import 'models/study_session.dart';

abstract final class Routes {
  static const home = '/';
  static const detail = '/session';
  static const form = '/session/form';
}

/// What the detail screen gets: the session and callbacks to the shell.
class DetailArgs {
  final StudySession session;
  final Profile profile;
  final void Function(StudySession) onChanged;
  final void Function(StudySession) onDelete;
  final void Function() onOpenProfile;

  const DetailArgs({
    required this.session,
    required this.profile,
    required this.onChanged,
    required this.onDelete,
    required this.onOpenProfile,
  });
}

/// What the form gets: a session to edit, or null for a new one.
class FormArgs {
  final StudySession? session;

  const FormArgs({this.session});
}
