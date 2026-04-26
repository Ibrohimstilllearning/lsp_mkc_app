import 'package:lsp_mkc_app/pages/forms/apl02/model/portfolio.dart';
import 'package:lsp_mkc_app/pages/forms/apl02/model/scheme.dart';

enum AsesiType {
  pribadi,
  institusi,
  unknown;

  static AsesiType fromJsonString(String? value) {
    switch (value) {
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
    required this.scheme,
  });

  factory ResponseRegistration.fromJson(Map<String, dynamic> json) {
    return ResponseRegistration(
      registrationId: json['registration_id'] as int,
      asesiType: AsesiType.fromJsonString(json['asesi_type'] as String?),
      portfolios: (json['portfolios'] as List<dynamic>)
          .map((item) => Portfolio.fromJson(item as Map<String, dynamic>))
          .toList(),
      scheme: Scheme.fromJson(json['scheme'] as Map<String, dynamic>),
    );
  }
}