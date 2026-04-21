class DocumentList {
  final int id;
  final String title;
  final String description;
  final String? created_at;
  final String? updated_at;

  DocumentList({
    required this.id,
    required this.title,
    required this.description,
    this.created_at,
    this.updated_at
  });

  factory DocumentList.fromJson(Map<String, dynamic> json) {
    return DocumentList(
      id: json['id'], 
      title: json['title'], 
      description: json['description']
    );
  }
}