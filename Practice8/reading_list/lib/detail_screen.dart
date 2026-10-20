import 'package:flutter/material.dart';

import 'models/book.dart';

enum BookAction { toggleRead, delete }

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.book});

  final Book book;

  Future<void> _delete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete '${book.title}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    Navigator.of(context).pop(BookAction.delete);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(book.title, maxLines: 1)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(book.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          ListTile(title: Text(book.author), subtitle: const Text('Author')),
          ListTile(
            title: Text('${book.pages} pp.'),
            subtitle: const Text('Pages'),
          ),
          ListTile(
            title: Text(book.year == null ? 'Year unknown' : '${book.year}'),
            subtitle: const Text('Year'),
          ),
          ListTile(
            title: Text(book.read ? 'Read' : 'Not read yet'),
            subtitle: const Text('Status'),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(BookAction.toggleRead),
            child: Text(book.read ? 'Mark as unread' : 'Mark as read'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => _delete(context),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
