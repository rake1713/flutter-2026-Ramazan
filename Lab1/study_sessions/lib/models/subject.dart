import 'package:flutter/material.dart';

/// The category of a study session.
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

  /// A colour role from the current scheme, so light and dark both work.
  /// The switch is exhaustive: a new value will not compile until it is here.
  Color color(ColorScheme scheme) => switch (this) {
    Subject.math => scheme.primaryContainer,
    Subject.programming => scheme.secondaryContainer,
    Subject.physics => scheme.tertiaryContainer,
    Subject.languages => scheme.errorContainer,
    Subject.economics => scheme.surfaceContainerHighest,
    Subject.design => scheme.inversePrimary,
  };
}
