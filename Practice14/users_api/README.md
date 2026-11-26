# Users

Users app from Practices 11-14: a list of users from jsonplaceholder, offline cache, login, settings, profile photo.
Release build: 1.0.1 (2), applicationId kz.ramazan.users.

## Run and build

```
flutter run
flutter run --dart-define=USE_FAKES=true
flutter run --dart-define-from-file=env/local.json
flutter build apk --release --dart-define-from-file=env/prod.json
```

Full release:

```
flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/symbols --dart-define-from-file=env/prod.json -P force-version-code-ignoring-abi=true
```

## Pre-release checklist

- [x] applicationId is mine: kz.ramazan.users (build.gradle.kts)
- [x] version bumped, versionCode from pubspec: 1.0.1+2 (pubspec.yaml)
- [x] release signed with my own upload key (keytool -printcert in NOTES.md)
- [x] key and key.properties are gitignored and never committed (.gitignore, git log check)
- [ ] key backed up outside this laptop (NOTES.md)
- [x] INTERNET in the main manifest (AndroidManifest.xml)
- [x] only the permissions I use + iOS usage strings (CAMERA, Info.plist)
- [x] app name "Users" (AndroidManifest.xml, Info.plist)
- [x] my own icon, adaptive on Android (flutter_launcher_icons)
- [x] my own splash, Android 12 included (flutter_native_splash)
- [x] built with env/prod.json, About shows prod (screenshot_about_release.png)
- [x] obfuscated, symbols archived per version (releases/1.0.1+2/)
- [ ] installed from the file on a real phone over mobile data (screenshot_about_release.png)
- [x] flutter analyze 0, dart format clean, flutter test green, layer grep empty

## Quality

```
$ flutter analyze
No issues found!

$ dart format .
Formatted 40 files (0 changed)

$ flutter test
00:04 +10: All tests passed!

$ sh tool/check_layers.sh
(nothing)
```
