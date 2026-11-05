# Practice 10 notes

## Level 1 - order of events

Code in main() before runApp:
print A, Future.delayed 2s -> print B, print C, then api.fetchStudents().then(print length).

Predicted: A, C, B, 6 students
Actual: A, C, fetchStudents #1, then the app showed up, and after 2 seconds B and 6 students.

Nothing waited for the timer. main() finished, the screen was drawn, B and the students came later as events.

Calling fetchStudents() 3 times in a row, the third one printed:
`Unhandled Exception: Instance of 'NoConnectionException'`
and the app kept running like nothing happened.

With sleep() instead of await Future.delayed the first frame did not show for 2 seconds, the loop was blocked.

## Level 2 - without mounted

Removed both `if (!mounted) return;`, opened the screen and pressed Back before 2 seconds:
`setState() called after dispose(): _StudentsScreenState#4d7fb(lifecycle state: defunct, not mounted)`

## Level 4 - countdown

Version B (listen) with cancel(): Back at 7, the console printed one more tick and stopped.
Version B without cancel(): Back at 7, the ticks kept going down to 0 and every second it printed
`setState() called after dispose(): _CountdownBState#e6fe8(lifecycle state: defunct, not mounted)`
That is the leak.
Version A (StreamBuilder): no cancel in my code, Back at 7, the console stopped by itself. StreamBuilder cancelled it.

## Level 5 - save

Wrong version: `onPressed: () { _api.save(n); Navigator.pop(context); }`
Second save popped the screen like it worked, and the console said
`Unhandled Exception: Bad state: server rejected 6`
The user saw a success.

flutter analyze did not flag this one, because the closure is not async. unawaited_futures only checks inside async functions. With `() async { _api.save(n); }` it shows "Missing an 'await' for the 'Future'".

Fixed version: await + try / on StateError, context.mounted after the await, pop only on success, SnackBar on error, button disabled with a spinner while saving.
