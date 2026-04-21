import 'package:lsp_mkc_app/pages/forms/apl02/model/criterion.dart';

class Element {
  final int id;
  final String title;
  final List<Criterion> criteria;


  Element({
    required this.id,
    required this.title,
    required this.criteria
  });

  factory Element.fromJson(Map<String, dynamic> json) {
    return Element(
      id: json['id'], 
      title: json['title'], 
      criteria: (json['criteria'] as List).map((i) => Criterion.fromJson(i)).toList(),
    );
  }
}