import 'package:flutter/material.dart';
import 'package:users_api/core/widgets/message_view.dart';

class EmptyUsers extends StatelessWidget {
  const EmptyUsers({super.key});

  @override
  Widget build(BuildContext context) {
    return const MessageView(icon: Icons.people_outline, text: 'No users here');
  }
}
