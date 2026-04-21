import 'package:lsp_mkc_app/pages/forms/apl02/model/portfolio.dart';
import 'package:lsp_mkc_app/pages/forms/apl02/model/scheme.dart';
enum AsesiType {
  pribadi,
  institusi,
  unknown;

  static AsesiType fromJsonString(String? value) {
    switch(value){
      case 'pribadi':
        return AsesiType.pribadi;
      case 'institusi':
        return AsesiType.institusi;
      default: 
        return AsesiType.unknown;

    }
    
  }
}


class ResponseRegistration {
  final int registrationId;
  final AsesiType asesiType;
  final List<Portfolio> portfolios;
  final Scheme scheme;

  ResponseRegistration({
    required this.registrationId, 
    required this.asesiType, 
    required this.portfolios, 
    required this.scheme
  });

  factory ResponseRegistration.fromJson(Map<String, dynamic> json) {
    return ResponseRegistration(
      registrationId: json['registration_id'], 
      asesiType: AsesiType.fromJsonString(json['asesi_type']), 
      portfolios: (json['portfolios'] as List).map((item) => Portfolio.fromJson(item)).toList(),
      scheme: Scheme.fromJson(json['scheme'])
    );
  }
  

}