class Book {
  final int id;
  final String name;
  final String? description;
  final List<String> languages;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? imageCount;
  final int? audioCount;
  final int? chapterCount;

  Book({
    required this.id,
    required this.name,
    this.description,
    required this.languages,
    required this.createdAt,
    required this.updatedAt,
    this.imageCount,
    this.audioCount,
    this.chapterCount,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      languages: (json['languages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      imageCount: json['image_count'] as int?,
      audioCount: json['audio_count'] as int?,
      chapterCount: json['chapter_count'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'languages': languages,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'image_count': imageCount,
      'audio_count': audioCount,
      'chapter_count': chapterCount,
    };
  }
}

class PaginatedBooksResponse {
  final List<Book> items;
  final int total;
  final int page;
  final int pageSize;

  PaginatedBooksResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory PaginatedBooksResponse.fromJson(Map<String, dynamic> json) {
    return PaginatedBooksResponse(
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => Book.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      pageSize: json['page_size'] as int? ?? 50,
    );
  }
}
