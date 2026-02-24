class ApiEndpoints {
      static  String baseUrl = 'https://ujikomp.lspmkc.or.id/api';
      static _AuthEndPoints authEndPoints = _AuthEndPoints();
}

class _AuthEndPoints {
  final String registerPoint = '/register';
  final String loginPoint = '/login';
}