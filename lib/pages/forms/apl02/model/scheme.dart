import 'package:lsp_mkc_app/pages/forms/apl02/model/unit.dart';

class Scheme {
  final int id;
  final String code;
  final String name;
  final List<Unit> units;

  Scheme({required this.id, required this.code, required this.name, required this.units});

  factory Scheme.fromJson(Map<String, dynamic> json) {
    return Scheme(
      id: json['id'], 
      code: json['code'], 
      name: json['name'], 
      units: (json['units'] as List).map((i) => Unit.fromJson(i)).toList()
    );
  }
}