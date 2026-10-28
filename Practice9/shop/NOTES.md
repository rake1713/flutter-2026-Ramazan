# Practice 9 notes

## Level 1 - lifted state

To show the total in the badge I had to add a `total` parameter and pass it down from Shell.
Constructors changed: 2 (BooksScreen, CartBadge).
Files changed: 3 (main.dart, books_screen.dart, cart_badge.dart).
BooksScreen does not use total itself, it only passes it to CartBadge.

After one tap on Add the console printed 7 lines:
1 "BooksScreen build" and 6 "row ..." lines, so the whole screen was rebuilt.
