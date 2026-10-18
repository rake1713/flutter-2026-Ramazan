import 'package:flutter/material.dart';

import 'models/book.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();

  final _title = TextEditingController();
  final _author = TextEditingController();
  final _pages = TextEditingController();
  final _year = TextEditingController();

  @override
  void dispose() {
    for (final c in [_title, _author, _pages, _year]) {
      c.dispose();
    }
    super.dispose();
  }

  void _hideKeyboard(PointerDownEvent event) {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  String? _validateTitle(String? v) {
    return (v ?? '').trim().length < 2 ? 'At least 2 characters' : null;
  }

  String? _validateAuthor(String? v) {
    return (v ?? '').trim().isEmpty ? 'Enter the author' : null;
  }

  String? _validatePages(String? v) {
    final n = int.tryParse(v ?? '');
    if (n == null || n <= 0) return 'A whole number above 0';
    return null;
  }

  String? _validateYear(String? v) {
    final text = (v ?? '').trim();
    if (text.isEmpty) return null; // the year is optional
    final n = int.tryParse(text);
    final thisYear = DateTime.now().year;
    if (n == null || n < 1450 || n > thisYear) {
      return 'A year from 1450 to $thisYear';
    }
    return null;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final book = Book(
      title: _title.text.trim(),
      author: _author.text.trim(),
      pages: int.parse(_pages.text), // safe: the validator checked it
      year: int.tryParse(_year.text.trim()), // '' -> null = year unknown
    );
    Navigator.of(context).pop(book);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add a book')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Title'),
                textInputAction: TextInputAction.next,
                onTapOutside: _hideKeyboard,
                validator: _validateTitle,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _author,
                decoration: const InputDecoration(labelText: 'Author'),
                textInputAction: TextInputAction.next,
                onTapOutside: _hideKeyboard,
                validator: _validateAuthor,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _pages,
                decoration: const InputDecoration(labelText: 'Pages'),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                onTapOutside: _hideKeyboard,
                validator: _validatePages,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _year,
                decoration: const InputDecoration(labelText: 'Year (optional)'),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _save(),
                onTapOutside: _hideKeyboard,
                validator: _validateYear,
              ),
              const SizedBox(height: 24),
              FilledButton(onPressed: _save, child: const Text('Save')),
            ],
          ),
        ),
      ),
    );
  }
}
