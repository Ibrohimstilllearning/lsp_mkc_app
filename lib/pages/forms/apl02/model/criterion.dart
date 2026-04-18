class Criterion {
  final int id;
  final String name;
  final String description;

  Criterion({
    required this.id,
    required this.name,
    required this.description
  });

  factory Criterion.fromJson(Map<String, dynamic> json) {
    return Criterion(
      id: json['id'], 
      name: json['name'], 
      description: json['description']
    );
  }
}