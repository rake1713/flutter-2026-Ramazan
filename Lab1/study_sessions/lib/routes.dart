import 'models/profile.dart';
import 'models/study_session.dart';

abstract final class Routes {
  static const home = '/';
  static const detail = '/session';
  static const form = '/session/form';
}

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

class FormArgs {
  final StudySession? session;

  const FormArgs({this.session});
}
