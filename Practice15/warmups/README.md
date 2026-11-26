# Warm-ups

Twenty minutes each, timer on, out loud, from an empty `flutter create`.
First two minutes: read and say the plan. Then narrate, run after every change, finish something.
Commit when the timer stops, in whatever state it is.

## 1. counter_provider

The counter app -> a ChangeNotifier, a second screen that shows the same count, a button on each screen that changes it.
Provider above MaterialApp, watch in build, read in onPressed.

Plan:
1. `flutter create counter_provider`, `flutter pub add provider`
2. `class Counter extends ChangeNotifier { int value = 0; void inc() {...} }`
3. `ChangeNotifierProvider(create: (_) => Counter(), child: MyApp())`
4. Home: `context.watch<Counter>().value`, button `context.read<Counter>().inc()`, button to push the second screen
5. Second screen: the same watch and the same button

## 2. list_states

A list from a fake repository that fails on demand -> loading, error with Retry, empty, data.
Four branches in one switch, the model takes the repository through its constructor, no mounted in the model.

Plan:
1. `abstract interface class ItemRepository { Future<List<String>> getAll(); }`
2. `FakeItemRepository({this.fail = false, this.empty = false})` with a 1 second delay
3. `ItemsModel(this._repo)`: loading, error, items, `load()` with try / catch / finally
4. Screen: `if (m.loading)` spinner, then switch: error -> Retry, empty -> text, else ListView
5. Run three times with fail, empty and normal

## 3. form_validation

A form with two fields -> validators, controllers created once in State and disposed, Form + GlobalKey<FormState>, one unit test for the rule.

Plan:
1. `String? validateEmail(String? v)` as a top-level function in its own file
2. StatefulWidget with two controllers, dispose both
3. `Form(key: _formKey)`, two TextFormFields, Save calls `_formKey.currentState!.validate()`
4. `test('empty email is an error', () => expect(validateEmail(''), isNotNull));`
5. `flutter test`
