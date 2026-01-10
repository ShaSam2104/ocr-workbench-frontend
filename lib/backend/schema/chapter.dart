class Chapter {
  final int id;
  final String name;
  final int bookId;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? imageCount;
  final int? audioCount;

  Chapter({
    required this.id,
    required this.name,
    required this.bookId,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.imageCount,
    this.audioCount,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] as int,
      name: json['name'] as String,
      bookId: json['book_id'] as int,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      imageCount: json['image_count'] as int?,
      audioCount: json['audio_count'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'book_id': bookId,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'image_count': imageCount,
      'audio_count': audioCount,
    };
  }
}

class PaginatedChaptersResponse {
  final List<Chapter> items;
  final int total;
  final int page;
  final int pageSize;

  PaginatedChaptersResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory PaginatedChaptersResponse.fromJson(Map<String, dynamic> json) {
    return PaginatedChaptersResponse(
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => Chapter.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      pageSize: json['page_size'] as int? ?? 50,
    );
  }
}
