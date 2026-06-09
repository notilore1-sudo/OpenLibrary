class Book {
  final String key;
  final String title;
  final List<String> authors;
  final int? firstPublishYear;
  final int? coverId;
  final double? rating;
  final List<String> isbn;
  final int? pageCount;
  final List<String> subjects;
  final String? description;

  Book({
    required this.key,
    required this.title,
    required this.authors,
    this.firstPublishYear,
    this.coverId,
    this.rating,
    required this.isbn,
    this.pageCount,
    required this.subjects,
    this.description,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    List<String> parsedAuthors = [];
    if (json['author_name'] != null) {
      parsedAuthors = List<String>.from(json['author_name']);
    }

    double? parsedRating;
    if (json['ratings_average'] != null) {
      parsedRating = (json['ratings_average'] as num).toDouble();
    }

    List<String> parsedIsbn = [];
    if (json['isbn'] != null) {
      parsedIsbn = List<String>.from(json['isbn']);
    }

    List<String> parsedSubjects = [];
    if (json['subject'] != null) {
      parsedSubjects = List<String>.from(json['subject']);
    }

    return Book(
      key: json['key'] ?? '',
      title: json['title'] ?? 'Unknown Title',
      authors: parsedAuthors,
      firstPublishYear: json['first_publish_year'],
      coverId: json['cover_i'],
      rating: parsedRating,
      isbn: parsedIsbn,
      pageCount: json['number_of_pages_median'],
      subjects: parsedSubjects,
      description: json['description'] is String
          ? json['description']
          : (json['description'] is Map ? json['description']['value'] : null),
    );
  }

  Book copyWith({
    String? description,
    double? rating,
    int? pageCount,
  }) {
    return Book(
      key: key,
      title: title,
      authors: authors,
      firstPublishYear: firstPublishYear,
      coverId: coverId,
      rating: rating ?? this.rating,
      isbn: isbn,
      pageCount: pageCount ?? this.pageCount,
      subjects: subjects,
      description: description ?? this.description,
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'title': title,
      'author_name': authors,
      'first_publish_year': firstPublishYear,
      'cover_i': coverId,
      'ratings_average': rating,
      'isbn': isbn,
      'number_of_pages_median': pageCount,
      'subject': subjects,
      'description': description,
    };
  }

  factory Book.fromMap(Map<dynamic, dynamic> map) {
    return Book(
      key: map['key'] ?? '',
      title: map['title'] ?? '',
      authors: List<String>.from(map['author_name'] ?? []),
      firstPublishYear: map['first_publish_year'],
      coverId: map['cover_i'],
      rating: map['ratings_average'] != null ? (map['ratings_average'] as num).toDouble() : null,
      isbn: List<String>.from(map['isbn'] ?? []),
      pageCount: map['number_of_pages_median'],
      subjects: List<String>.from(map['subject'] ?? []),
      description: map['description'],
    );
  }

  String get coverUrlMedium => coverId != null
      ? 'https://covers.openlibrary.org/b/id/$coverId-M.jpg'
      : '';

  String get coverUrlLarge => coverId != null
      ? 'https://covers.openlibrary.org/b/id/$coverId-L.jpg'
      : '';
}
