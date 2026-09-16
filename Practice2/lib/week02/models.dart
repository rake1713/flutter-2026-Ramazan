class Author {
    final String name;
    final String? country;

    const Author({
        required this.name, 
        this.country});

    @override
    String toString(){
        return 'Имя: $name Страна: ${country ?? 'N/A'}';
    } 
}
enum Genre{
    craft('Craftmanship'),
    theory('Theory'),
    unknown('Unknown');

    final String label;

    const Genre(this.label);

    static Genre fromString(String? raw){
        switch (raw?.toLowerCase()) {
            case 'craft':
                return Genre.craft;
            case 'theory':
                return Genre.theory;
            default:
                return Genre.unknown;
        }
    }
}

class Book extends LibraryItem with Borrowable { //2
    final int pages;
    final Author author;
    final Genre genre;
    final String? description;

    const Book({
        required super.title,
        required super.year,
        required this.pages,
        required this.author,
        required this.genre,
        this.description
    });
    Book.missing()
        :   pages = 0,
            author = const Author(name: 'Unknown'),
            genre = Genre.unknown,
            description = null,
            super(title: 'Unknown Title', year: 0);

    factory Book.fromJson(Map<String, dynamic> json) {
        return Book(
            title:json['title'] as String? ?? 'Untitled',
            year:json['year'] as int? ?? 0,
            pages:json['pages'] as int? ?? 0,
            author:Author(
                name:json['author'] as String? ?? 'Unknown',
                country:json['country'] as String?,
            ),
            genre:Genre.fromString(json['genre'] as String?),
            description:json['description'] as String?,
            );
    }

    @override
    String describe()=> 'Book "$title" ($year) by ${author.name}'; //2

    bool get isLong => pages > 400;

    Book copyWith({
        String? title,
        int? year,
        int? pages,
        Author? author,
        Genre? genre,
        String? description,
    }){
        return Book(
            title: title ?? this.title,
            year: year ?? this.year,
            pages: pages ?? this.pages,
            author: author ?? this.author,
            genre: genre ?? this.genre,
            description: description ?? this.description,
            );
    }
    @override
    String toString() {
        final dc = description != null ? ' - "$description"' : '';
        return 'Book: "$title" ($year) by $author, ${pages}p, [${genre.label}]$dc';
        }
}


abstract class LibraryItem { //2
    final String title;
    final int year;

    const LibraryItem({
        required this.title,
        required this.year,
    });

    String describe();

    bool get isOld => (DateTime.now().year-year)>5;
  }
  
mixin Borrowable on LibraryItem {//2
  String borrowLabel() => 'BORROWED: "$title"';
}


class Magazine extends LibraryItem{//2
    final int issue;

    const Magazine({
        required super.title,
        required super.year,
        required this.issue});
    
    @override
    String describe(){
        return 'Magazine "$title" Issue $issue ($year)';
    }
    
}

class Ghost implements LibraryItem{//2

    @override
    final String title;

    @override
    final int year;

    const Ghost({
        required this.title,
        required this.year
    });

    @override
    String describe(){
        return 'Ghost item "$title"';
    }

    @override
    bool get isOld => (DateTime.now().year-year)>5;

}
