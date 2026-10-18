import 'package:flutter/material.dart';

import 'add_book_screen.dart';
import 'detail_screen.dart';
import 'models/book.dart';
import 'widgets/book_tile.dart';

enum Filter { all, unread, read }

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final List<Book> _books = [...seed]; // a copy, the seed is never touched
  Filter _filter = Filter.all;

  List<Book> get _visible => switch (_filter) {
    Filter.all => _books,
    Filter.unread => unread(_books),
    Filter.read => _books.where((b) => b.read).toList(),
  };

  String _label(Filter f) => switch (f) {
    Filter.all => 'All',
    Filter.unread => 'Unread',
    Filter.read => 'Read',
  };

  Future<void> _open(Book book) async {
    final action = await Navigator.of(context).push<BookAction>(
      MaterialPageRoute(builder: (_) => DetailScreen(book: book)),
    );
    if (!mounted) return;
    switch (action) {
      case null:
        return; // back arrow: nothing changes
      case BookAction.toggleRead:
        setState(() => book.read = !book.read);
      case BookAction.delete:
        setState(() => _books.remove(book));
    }
  }

  Future<void> _addBook() async {
    final book = await Navigator.of(context)
        .push<Book>(MaterialPageRoute(builder: (_) => const AddBookScreen()));
    if (book == null || !mounted) return;
    setState(() => _books.add(book));
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;

    return Scaffold(
      appBar: AppBar(title: Text('Reading list (${visible.length})')),
      body: Column(
        children: [
          _Header(books: _books),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                for (final f in Filter.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_label(f)),
                      selected: _filter == f,
                      onSelected: (_) => setState(() => _filter = f),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 88),
              itemCount: visible.length,
              itemBuilder: (context, index) {
                final book = visible[index];
                return BookTile(
                  book: book,
                  onToggle: () => setState(() => book.read = !book.read),
                  onTap: () => _open(book),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addBook,
        tooltip: 'Add a book',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.books});

  final List<Book> books;

  Widget _stat(BuildContext context, String value, String label) {
    final textTheme = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        children: [
          Text(value, style: textTheme.headlineSmall),
          Text(label, style: textTheme.bodySmall),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            _stat(context, '${books.length}', 'Books'),
            _stat(context, '${totalPages(books)}', 'Pages'),
            _stat(context, '${unread(books).length}', 'Unread'),
          ],
        ),
      ),
    );
  }
}
