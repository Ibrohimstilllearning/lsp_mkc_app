import 'package:lsp_mkc_app/pages/forms/apl02/model/element.dart';

class Unit {
  final int id;
  final String unitCode;
  final String unitTitle;
  final List<Element> elements;

  Unit({
    required this.id, 
    required this.unitCode, 
    required this.unitTitle, 
    required this.elements
  });

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['id'], 
      unitCode: json['unit_code'], 
      unitTitle: json['unit_title'], 
      elements: (json['elements'] as List).map((item) => Element.fromJson(item)).toList() 
      );
  }

  

}
