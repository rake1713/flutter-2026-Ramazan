import 'models.dart';

class Library{
    final List<LibraryItem> items=[];
    late final DateTime openedAt;
    String? _cachedReport;

    void add(LibraryItem item){
        items.add(item);
    }

    void open(){
        openedAt=DateTime.now();
    }
    
    Book? findByTitle(String title){
        for (var item in items){
            if (item is Book && item.title.toLowerCase()==title.toLowerCase()){
                return item;
            }
        }
        return null;
    }

    String countryOf(String title)=> findByTitle(title)?.author.country ?? 'unknown';

    List<String> get titles => items.map((item) =>item.title).toList();

    List<Book> get booksAfter2010=>items.whereType<Book>().where((book)=>book.year>2010).toList();

    Map<String, int> get booksPerAuthor => items.whereType<Book>().fold(<String, int>{},(map, book){
            map[book.author.name] = (map[book.author.name] ?? 0) + 1;
            return map;
        },
    );

    Set<String> get uniqueAuthors=>items.whereType<Book>().map((book)=>book.author.name).toSet();
    
    Set<Genre> get presentGenres =>items.whereType<Book>().map((book) => book.genre).toSet();

    double get avgPages{
        final books=items.whereType<Book>();
        if (books.isEmpty) return 0;

        final totalPages=books.fold(0,(sum,book)=>sum+book.pages);//Мы не можем юзать редюс так как он тут должен будет вернуть не int а элемент типа Book поэтому выдает тут компайл ошибку
        return totalPages/books.length;
    }


    List<String> get displayList => [
        'CATALOGUE',
        for (var book in items.whereType<Book>()) '${book.title} - ${book.year}',
        ...uniqueAuthors,
        if (items.whereType<Book>().any((book)=>book.pages==0))
        '(Incomplete data)',
        ];

    String get report => _cachedReport ??= 'Total items: ${items.length}';

}