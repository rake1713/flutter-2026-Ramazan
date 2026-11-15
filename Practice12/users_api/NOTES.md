# Practice 12 notes

## Level 1 - package verdicts

Order: publisher, last release, platforms, pub points, issues vs commits, dependencies, licence.

- shared_preferences: verified publisher flutter.dev, released October 2026 (2.5.6), all six platforms, 160/160 points, 16 open issues and commits this week, only its own platform packages, BSD-3.
- flutter_secure_storage: verified publisher steenbakker.dev (one maintainer, not Google), released September 2026 (11.2.0), all six platforms, 160/160 points, 24 open issues and commits this week, its own platform packages + meta, BSD-3.
- path_provider: verified publisher flutter.dev, released June 2026 (2.1.6), five platforms (no web), 160/160 points, 22 open issues and commits this week, only its own platform packages, BSD-3.
- image_picker: verified publisher flutter.dev, released October 2026 (1.2.4), all six platforms, 160/160 points, 87 open issues but commits this week, its own platform packages, Apache-2.0 / BSD-3.
- permission_handler: verified publisher baseflow.com (a company, not Google), released September 2026 (13.0.2), android, ios, windows, web only, 160/160 points, 155 open issues and PRs, last push November 2026, its own platform packages + meta, MIT.
- url_launcher: verified publisher flutter.dev, released October 2026 (6.3.3), all six platforms, 160/160 points, 34 open issues and commits this week, only its own platform packages, BSD-3.

## Carets and pubspec.lock

flutter pub add wrote carets: ^2.5.6, ^11.2.0, ^2.1.6, ^1.2.4, ^13.0.2, ^6.3.3.
pubspec.lock has http version 1.6.0.

^1.2.0 means >=1.2.0 <2.0.0.
It accepts 1.2.0, 1.2.5, 1.6.0, 1.99.0.
It refuses 1.1.9 (too old) and 2.0.0 (a new major can break the API).

pubspec.lock is committed because this is an app: everyone who clones it and the build server get exactly the same versions that I tested.

flutter pub outdated: cupertino_icons is 1.0.9, latest is 2.0.0. It was not upgraded because ^1.0.8 does not allow 2.x, a major version needs a manual change.

http: 1.2.0 without the caret: flutter pub get failed.
permission_handler needs package web >=0.5.1, but http 1.2.0 needs web <0.5.0, so "version solving failed". The caret back -> it works again.

## Level 3 - where a token in shared_preferences would end up

prefs.setString('token', ...) would put it in a plain file in the app folder:
- Android: an XML file in /data/data/<package>/shared_prefs (SharedPreferencesAsync uses a DataStore file in files/datastore, also not encrypted)
- iOS: a plist in Library/Preferences

Who can read it: a backup of the phone, anyone with root / jailbreak, and a cable with a debug build (adb run-as).
That is why the token goes to flutter_secure_storage (Keychain / Keystore).

Two surprises:
- iOS: Keychain items can stay after the app is deleted. After a reinstall the app can find the old token and look signed in.
- Android: if the user removes the lock screen, the Keystore keys can be lost, and the saved values can not be read anymore. The user has to sign in again.

## Level 5 - permissions

Android: Don't allow twice -> permanentlyDenied. The third tap shows no system dialog, only my dialog with Open settings.
iOS: the system asks only once. One Don't Allow -> permanentlyDenied, after that only Settings can change it.
The fourth Photos state on iOS is limited ("Selected Photos").

launchUrl(Uri.parse('kbtu.edu.kz')) without a scheme returns false, nothing opens. With https:// the browser opens.
