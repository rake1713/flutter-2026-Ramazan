import 'package:flutter/material.dart';

enum Subject {
  math('Math', Icons.functions),
  programming('Programming', Icons.code),
  physics('Physics', Icons.science),
  languages('Languages', Icons.translate),
  economics('Economics', Icons.trending_up),
  design('Design', Icons.brush);

  const Subject(this.label, this.icon);

  final String label;
  final IconData icon;

  Color color(ColorScheme scheme) => switch (this) {
    Subject.math => scheme.primaryContainer,
    Subject.programming => scheme.secondaryContainer,
    Subject.physics => scheme.tertiaryContainer,
    Subject.languages => scheme.errorContainer,
    Subject.economics => scheme.surfaceContainerHighest,
    Subject.design => scheme.inversePrimary,
  };
}
