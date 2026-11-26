# Interview prep

Every answer: what it is, where it is in my code, one level deeper.
Starred (*) = took more than 40 seconds or started with "it depends", rehearse again.

## Twenty questions

**1. StatelessWidget vs StatefulWidget?**
A StatelessWidget only draws what it gets in its constructor, a StatefulWidget has a State object that keeps data between builds.
In Practice 10 `StudentsScreen` is Stateful because it keeps `_students` and `_error`, `UserTile` in Practice 13 is Stateless because it only shows one user.
The widget itself is rebuilt all the time, only the State survives, that is why the data lives in the State and not in the widget.

**2. What is BuildContext?**
It is the position of a widget in the tree.
I use it in `context.watch<UsersModel>()` and `Navigator.of(context)`, both look up the tree from that position.
After an await the widget can be gone, so a context from before the await may be dead, that is why I check `context.mounted`.

**3. What does setState do?**
It runs the function that changes the fields and then marks the widget as dirty, so build runs again on the next frame.
In Practice 10 `_load()` calls `setState(() => _students = list)` after the request.
It rebuilds the whole widget under it, in Practice 9 Level 1 one tap on Add rebuilt 7 widgets, provider later brought that down.

**4. Constraints go down, sizes go up?**
A parent tells the child the min and max size, the child picks its size inside that, and the parent decides the position.
That is why a ListView inside a Column needs `Expanded`, in `users_screen.dart` the list is wrapped in Expanded.
Without it the Column gives the list infinite height and Flutter throws "unbounded height".

**5. How does navigation work?**
The Navigator is a stack: `push` puts a screen on top, `pop` removes it and can return a value.
In Practice 8 the add form returns the new book with `Navigator.pop(context, book)`, in Practice 11 the user list pushes `UserDetailScreen`.
The caller awaits the push, gets null if the user pressed Back, and must check mounted before using context.

**6. How do you validate a form?**
`Form` with a `GlobalKey<FormState>`, every `TextFormField` has a validator that returns an error text or null.
In `new_user_screen.dart` `_save` calls `form.validate()` and stops if it is false.
Controllers are created once in State and disposed in `dispose()`, otherwise they leak.

**7. Where should state live?**
Ephemeral state lives in one widget's State, state that several screens need is lifted up or provided.
The search text in Practice 9 is ephemeral (`_query` in `_BooksScreenState`), the cart is provided with `ChangeNotifierProvider`.
The rule: put it as high as the highest widget that needs it, and not higher.

**8. What is a ChangeNotifier?**
A class that keeps data and calls `notifyListeners()` when it changes.
`UsersModel` in Practice 11 extends it: `load()` sets loading, error and items and notifies.
It knows nothing about widgets, no BuildContext and no mounted, so it can be tested with a plain `test()`.

**9. What does provider do?**
It puts one object into the widget tree so any widget below can find it, and rebuilds the ones that listen.
In `main.dart` `ChangeNotifierProvider(create: (_) => UsersModel(repo)..load())` sits above MaterialApp.
`create` is called once and provider disposes the object, `.value` with a new object inside build would make a new one every rebuild.

**10. watch, read, select?**
`watch` subscribes the widget, `read` takes the object once without subscribing, `select` subscribes to one value only.
`watch` is in build (`context.watch<UsersModel>()`), `read` is in callbacks (`context.read<AuthModel>().login(...)`), `select` is on the cart badge in Practice 9.
`read` in build compiles but never updates, `watch` in onPressed throws "Tried to listen to a value exposed with provider, from outside of the widget tree".

**11. Future vs Stream?**
A Future gives one value later, a Stream gives many values over time.
`fetchStudents()` in Practice 10 is a Future, `countdown(10)` is a Stream made with `async*` and `yield`.
A `listen` subscription must be cancelled in `dispose`, otherwise it keeps running after the screen is gone, StreamBuilder cancels for you.

**12. What happens after await?**
The function pauses, the app keeps drawing, and the rest of the function runs later when the Future completes.
In `_load()` the line after `await _api.fetchStudents()` runs two seconds later.
By then the user may have left, so before setState I check `if (!mounted) return`.

**13. Why is the Future of a FutureBuilder a field?**
build runs many times, a Future created in build starts a new request every time.
In `students_future_screen.dart` `_future` is set once in initState and only `_retry` replaces it.
With the call inline in build, every flip of the Switch would start a new `fetchStudents #N`, show the spinner again, and every third one would fail.

**14. JSON int vs double?**
`jsonDecode` gives an int for `5` and a double for `5.0`, so `as double` on a whole number throws.
For numbers the safe way is `(json['x'] as num).toDouble()`, in `user.dart` lat comes as a string, so I use `double.parse(json['lat'] as String)`.
In Practice 13 I planted lat as a number and got "type 'double' is not a subtype of type 'String'" at user.dart:8:35.

**15. How do you parse JSON into a model?**
A `fromJson` factory that casts every field, nested objects get their own fromJson, and `toJson` goes back.
`User.fromJson` calls `Address.fromJson`, which calls `Geo.fromJson`.
Every `as` is a claim: when the server breaks it, the error names the field, and the repository turns it into BadResponseException.

**16. Why a repository, and why does ApiClient take an http.Client?**
The repository is the only place that knows URLs and JSON, screens get models or my exceptions.
`ApiClient(this._store, {http.Client? client})` uses the client it gets, or creates a real one.
Because of that a test passes `MockClient` and checks 404, 500 and SocketException without the internet.

**17. How do you handle network errors?**
`ApiClient` turns them into my own `sealed class ApiException`: no connection, 401, 404, 5xx, bad response.
`_send` has a 10 second timeout, `_check` looks at the status before the body, and `UsersErrorView` switches on the error.
Because the class is sealed, the switch has no default: if I add a new error, the screen does not compile until I handle it.

**18. shared_preferences, secure storage, files?**
Preferences for settings, secure storage for anything that lets someone be the user, files in Documents for data.
Dark mode and the city are in `settings_model.dart`, the token in `secure_store.dart`, the user list in `users_cache.dart`.
Preferences is a plain file anyone with a backup can read, and Temporary can be cleared by the system, so neither is for tokens or user data.

**19. Unit test vs widget test, and what is a fake?**
A unit test checks logic without Flutter, a widget test pumps a screen without an emulator, a fake is a class that implements the same interface without the network.
`users_model_test.dart` uses `FakeUserRepository(fail: true)`, `users_screen_test.dart` taps Retry and expects a spinner.
A unit test never touches the network, the disk or the clock, otherwise it is green on Sunday and red on Monday.

**20. What do you check before a release?**
The applicationId, a version code that went up, my own signing key that is backed up and never committed, and INTERNET in the main manifest.
In Practice 14 `build.gradle.kts` reads the key from `key.properties`, and the version comes from `pubspec.yaml`.
The release is built with `--obfuscate --split-debug-info`, and the symbols are archived per version, without them a crash log has no file names.

## Three stories

### A bug

- **Symptom:** in Practice 13 `flutter test` hung forever on the screen test, no error, no output.
- **Wrong first guess:** I thought the test runner was slow on the first compile and waited.
- **What found it:** running only that file showed it never finished: inside `testWidgets` time is fake, and `Future.delayed` in the fake repository never fires until you call `pump`.
- **Fix:** the fake waits only when the delay is above zero, and the screen test runs the first load with `tester.runAsync`.
- **Habit:** a test does not wait for a real clock, delays are injected through the constructor.

### A design decision

ApiClient takes an `http.Client` through its constructor instead of creating one inside.
The alternative was `http.get(...)` directly in the client: simpler, but then every test needs the real network and a server that returns 500 on demand, which does not exist.
With the client injected, `MockClient` gives me 404, 500 and SocketException in a second, offline.

### One thing I would do differently

I would write the fake repository first and build every screen against it.
In the practices the fake came in Practice 13, after the screens were already built around the real API, so I had to cut the screen into widgets and change constructors later.
With the fake on day one, the demo works without Wi-Fi from the start and every screen has a test from the start.
