import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String university;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.university,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundImage: AssetImage('assets/avatar.png'),
        ),
        const SizedBox(height: 12),
        Text(
          name,
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontFamily: 'CustomFont'),
        ),
        const SizedBox(height: 4),
        Text(university, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
