# Practice 13 notes

## Level 1 - layers

tool/check_layers.sh prints nothing.
Added `import 'package:http/http.dart' as http;` to users_screen.dart: the app still compiles and runs, but the script printed
`lib/features/users/users_screen.dart`. The compiler does not care about layers, the script does. Removed the import.

main.dart does not import http anymore: ApiClient creates http.Client() itself if no client is passed, and tests pass a MockClient.

## Level 2 - interfaces and fakes

UserRepository is an abstract interface class, HttpUserRepository is the real one, FakeUserRepository returns two users or throws NoConnectionException.
grep -rn "HttpUserRepository(" lib/ shows main.dart (the only place that creates it) and the constructor declaration in user_repository.dart itself, a class can not be written without that line.
Demo mode: in main.dart swap the two repo lines (and the commented import) -> two users with no network.

With the old model that did `UserRepository(ApiClient(...))` inside itself, I could not write the arrange step of "NoConnection sets error": there was no way to give the model a repository that fails.

## Level 3 - tests

flutter test: +10, green, about 3 seconds, no network.
In the widget test the first load runs with tester.runAsync(model.load): the fake needs a 1 second delay so the spinner can be seen after Retry, and a timer does not run inside testWidgets without it.
Empty `catch (e) {}` in UsersModel.load -> one test red:

```
UsersModel.load NoConnection sets error [E]
  Expected: <Instance of 'NoConnectionException'>
    Actual: <null>
  test/features/users/users_model_test.dart 24:7
```

## Level 4 - widgets

Extracted from users_screen.dart into widgets/: UsersHeader, CityFilterRow, EmptyUsers, UsersErrorView (+ OfflineBanner, UserTile, UserList). The longest build() is 54 lines.

Why a widget and not a _buildHeader() method:
a widget can be const and has its own rebuild scope, so it is not rebuilt for nothing.
It also shows up by name in DevTools and can be tested on its own, a method can do none of that.

Retry renamed to "Try again" -> the widget test failed:

```
Expected: exactly one matching candidate
  Actual: _TextWidgetFinder:<Found 0 widgets with text "Retry": []>
   Which: means none were found but one was expected
```
The screen changed and the test noticed. Changed it back.

## Level 5 - the trace

Planted: "lat": -37.3159 (a number) in the JSON of user 1 (Leanne Graham), with the try/catch in _fetch removed.

```
type 'double' is not a subtype of type 'String' in type cast      <- 1. the message
#0      new Geo.fromJson (package:users_api/features/users/user.dart:8:35)   <- 2. my first frame: line 8, column 35
#1      new Address.fromJson (package:users_api/features/users/user.dart:35:14)
#2      new User.fromJson (package:users_api/features/users/user.dart:80:24)
#3      HttpUserRepository._fetch (package:users_api/features/users/user_repository.dart:23:14)
<asynchronous suspension>
#4      HttpUserRepository.getAll (package:users_api/features/users/user_repository.dart:30:21)
<asynchronous suspension>
#5      UsersModel.load (package:users_api/features/users/users_model.dart:30:22)   <- 3. the path ends in UsersModel.load
<asynchronous suspension>
```

The data: field address.geo.lat of user 1 came as a number, not a string.
Line 8 column 35 is `json['lat'] as String` in Geo.fromJson.

#0 is the right place to throw, because that is where the wrong type is found and the message names it.
It is the wrong place to fix, because the server broke the contract, so the repository turns it into BadResponseException and the screen shows the generic error instead of crashing.

Tests: user_test.dart checks that Geo.fromJson throws TypeError for a number,
user_repository_test.dart checks that getAll() with that JSON throws BadResponseException.
