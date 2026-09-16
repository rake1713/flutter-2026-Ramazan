import 'data.dart';
import 'models.dart';
import 'catalogue.dart';
import 'shelf_state.dart';

void main() {
    final library = Library();
    library.open();
    
    for (var json in rawBooks) {
        library.add(Book.fromJson(json));
    }

    print('TITLES');
    print(library.titles.join(', '));
    print('\nBOOKS AFTER 2010');
    print(library.booksAfter2010.map((book) => book.title).toList().join(', '));
    print('\nAVERAGE PAGES');
    print(library.avgPages);
    print('\nBOOKS PER AUTHOR');
    print(library.booksPerAuthor.entries.map((author)=>'${author.key} ${author.value}').join(', '));
    print('\nUNIQUE AUTHORS');
    print(library.uniqueAuthors.join(', '));
    print('\nPRESENT GENRES');
    print(library.presentGenres.join(', '));
    print('\nDISPLAY LIST');
    for (var line in library.displayList) {
        print(line);
  }

    final books = library.items.whereType<Book>().toList();
    final stats = statsOf(books);

    print('\nSTATS RECORD');
    print('Count: ${stats.count}, Avg Pages: ${stats.avgPages}');
    print('\nSHELF STATES');
    print(describe(Empty()));
    print(describe(Ready(books)));
    print(describe(Broken('shelf overloaded!')));
}