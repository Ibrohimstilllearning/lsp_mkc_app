class ApiEndpoints {
  static const bool _useLocal = false;
  static String baseUrl = _useLocal
      ? 'https://maverick-unaccessional-salutatorily.ngrok-free.dev/api'
      : 'https://ujikomp.lspmkc.or.id/api';
  static _AuthEndPoints authEndPoints = _AuthEndPoints();

  static Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-API-KEY': 'opalOAaIUNGiyzmN0DgY8g4u7ac72q3H',
    'ngrok-skip-browser-warning': 'true',
  };

  static Map<String, String> authHeaders(String token) => {
    ...headers,
    'Authorization': 'Bearer $token',
  };
}

class _AuthEndPoints {
  final String registerPoint = '/register';
  final String loginPoint = '/login';
  final String logoutPoint = '/logout';
  final String resendVerifyPoint = '/verify-email/resend';
  final String userPoint = '/user';
}
