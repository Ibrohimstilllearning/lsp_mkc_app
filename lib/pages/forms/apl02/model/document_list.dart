class DocumentList {
  final int id;
  final String title;
  final String description;
  final int? schemeId; // null = berlaku untuk semua skema
  final String? createdAt;
  final String? updatedAt;

  DocumentList({
    required this.id,
    required this.title,
    required this.description,
    this.schemeId,
    this.createdAt,
    this.updatedAt,
  });

  factory DocumentList.fromJson(Map<String, dynamic> json) {
    return DocumentList(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      // Backend bisa pakai 'scheme_id' atau nested 'scheme.id'
      schemeId: json['scheme_id'] as int? ??
          (json['scheme'] as Map<String, dynamic>?)?['id'] as int?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }
}