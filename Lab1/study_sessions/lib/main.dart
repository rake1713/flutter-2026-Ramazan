import 'package:flutter/material.dart';

import 'models/study_session.dart';
import 'routes.dart';
import 'screens/detail_screen.dart';
import 'screens/not_found_screen.dart';
import 'screens/session_form_screen.dart';
import 'shell.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _setThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.detail:
        final args = settings.arguments as DetailArgs;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => DetailScreen(
            session: args.session,
            profile: args.profile,
            onChanged: args.onChanged,
            onDelete: args.onDelete,
            onOpenProfile: args.onOpenProfile,
          ),
        );
      case Routes.form:
        final args = settings.arguments as FormArgs;
        return MaterialPageRoute<StudySession>(
          settings: settings,
          builder: (_) => SessionFormScreen(session: args.session),
        );
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Study Sessions',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: _themeMode,
      initialRoute: Routes.home,
      routes: {
        Routes.home: (_) =>
            Shell(themeMode: _themeMode, onThemeModeChanged: _setThemeMode),
      },
      onGenerateRoute: _onGenerateRoute,
      onUnknownRoute: (settings) =>
          MaterialPageRoute(builder: (_) => const NotFoundScreen()),
    );
  }
}
