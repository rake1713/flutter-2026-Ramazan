import 'package:flutter/material.dart';

import 'message_view.dart';

class GenericError extends StatelessWidget {
  const GenericError({super.key});

  @override
  Widget build(BuildContext context) {
    return const MessageView(
      icon: Icons.bug_report,
      text: 'Something went wrong.\nPlease report this bug.',
    );
  }
}
