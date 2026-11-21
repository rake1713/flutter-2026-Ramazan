# users_api

Users app from Practices 11-12 (jsonplaceholder), refactored in Practice 13:
feature-first folders, a repository interface with a real and a fake implementation, tests.

```
lib/core/       api client, exceptions, secure storage, shared widgets
lib/features/   users, auth, settings, profile
test/           mirrors lib/ + test/fakes
```

Run: `flutter run`. Tests: `flutter test`.

## Quality checklist

```
$ flutter analyze
No issues found!

$ dart format .
Formatted 37 files (0 changed)

$ flutter test
00:03 +10: All tests passed!

$ sh tool/check_layers.sh
(nothing)
```
