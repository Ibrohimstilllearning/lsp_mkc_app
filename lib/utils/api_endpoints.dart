class ApiEndpoints {
  static String baseUrl = 'https://ujikomp.lspmkc.or.id/api';
  static _AuthEndPoints authEndPoints = _AuthEndPoints();
  
  // ← tambah di sini
  static Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-API-KEY': 'opalOAaIUNGiyzmN0DgY8g4u7ac72q3H',
  };
}

class _AuthEndPoints {
  final String registerPoint = '/register';
  final String loginPoint = '/login';
  final String logoutPoint = '/logout';
}