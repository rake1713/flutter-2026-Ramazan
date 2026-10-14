import 'package:flutter/material.dart';

import 'models/study_session.dart';
import 'routes.dart';
import 'screens/detail_screen.dart';
import 'screens/not_found_screen.dart';
import 'screens/session_form_screen.dart';
import 'shell.dart';

void main() => runApp(const MyApp());

/// Holds the theme mode above MaterialApp, so changing it rebuilds the theme.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // The only colour literal in lib/: the seed every colour role comes from.
  static const _seed = Colors.teal;

  ThemeMode _themeMode = ThemeMode.system;

  void _setThemeMode(ThemeMode mode) => setState(() => _themeMode = mode);

  Route<dynamic>? _generateRoute(RouteSettings settings) => switch (settings) {
    RouteSettings(name: Routes.detail, arguments: final DetailArgs args) =>
      MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => DetailScreen(
          session: args.session,
          profile: args.profile,
          onChanged: args.onChanged,
          onDelete: args.onDelete,
          onOpenProfile: args.onOpenProfile,
        ),
      ),
    RouteSettings(name: Routes.form, arguments: final FormArgs args) =>
      MaterialPageRoute<StudySession>(
        settings: settings,
        builder: (_) => SessionFormScreen(session: args.session),
      ),
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Study Sessions',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: _seed)),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seed,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: _themeMode,
      initialRoute: Routes.home,
      routes: {
        Routes.home: (_) =>
            Shell(themeMode: _themeMode, onThemeModeChanged: _setThemeMode),
      },
      onGenerateRoute: _generateRoute,
      onUnknownRoute: (settings) => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const NotFoundScreen(),
      ),
    );
  }
}
