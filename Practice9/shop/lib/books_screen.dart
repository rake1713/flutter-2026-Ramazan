import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'cart_badge.dart';
import 'models/book.dart';
import 'models/cart.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    debugPrint('BooksScreen build');
    final shown = books
        .where((b) => b.title.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: const InputDecoration(
            hintText: 'Search books',
            border: InputBorder.none,
          ),
          onChanged: (text) => setState(() => _query = text),
        ),
        actions: const [CartBadge()],
      ),
      body: ListView(children: [for (final b in shown) BookRow(book: b)]),
    );
  }
}

class BookRow extends StatelessWidget {
  const BookRow({super.key, required this.book});

  final Book book;

  void _add(BuildContext context) {
    final ok = context.read<Cart>().add(book);
    if (ok) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Added')));
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('row ${book.title}');
    final inCart = context.watch<Cart>().items.contains(book);
    return ListTile(
      title: Text(book.title),
      subtitle: Text(book.author),
      trailing: inCart
          ? const Text('Added')
          : OutlinedButton(
              onPressed: () => _add(context),
              child: const Text('Add'),
            ),
    );
  }
}
