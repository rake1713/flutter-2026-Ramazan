# Practice 9 notes

## Level 1 - lifted state

To show the total in the badge I had to add a `total` parameter and pass it down from Shell.
Constructors changed: 2 (BooksScreen, CartBadge).
Files changed: 3 (main.dart, books_screen.dart, cart_badge.dart).
BooksScreen does not use total itself, it only passes it to CartBadge.

After one tap on Add the console printed 7 lines:
1 "BooksScreen build" and 6 "row ..." lines, so the whole screen was rebuilt.

## Level 2 - Cart model

Output from main() before runApp: `1 items, 3100 ₸`

`cart.items.add(books[0])` throws:
`Unsupported operation: Cannot add to an unmodifiable list`

## Level 3 - provider errors

1. watch inside onPressed (loud error):
`Tried to listen to a value exposed with provider, from outside of the widget tree.`

2. read inside build of the badge (silent):
No error, but the badge stays 0 and never updates.

## Level 4 - badge rebuilds

Pressed + three times on a cart row:
- with watch: "badge build" printed 3 times
- with select: printed 0 times
- removed a book (with select): printed 1 time

## Where does it live?

- Cart - provided, because Books, the badge and Cart screen all use it.
- Search text - ephemeral, only the Books screen needs it.
- Total expanded/collapsed - ephemeral, only the Cart screen needs it.
- Theme mode - lifted/provided, MaterialApp uses it so it must be above MaterialApp.
