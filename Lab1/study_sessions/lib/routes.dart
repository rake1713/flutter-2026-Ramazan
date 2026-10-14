import 'package:flutter/foundation.dart';

import 'models/profile.dart';
import 'models/study_session.dart';

abstract final class Routes {
  static const home = '/';
  static const detail = '/session';
  static const form = '/session/form';
}

/// What the detail screen needs: the session and how to report changes up.
class DetailArgs {
  const DetailArgs({
    required this.session,
    required this.profile,
    required this.onChanged,
    required this.onDelete,
    required this.onOpenProfile,
  });

  final StudySession session;
  final Profile profile;
  final ValueChanged<StudySession> onChanged;
  final ValueChanged<StudySession> onDelete;
  final VoidCallback onOpenProfile;
}

/// The form edits [session], or creates a new one when it is null.
class FormArgs {
  const FormArgs({this.session});

  final StudySession? session;
}
