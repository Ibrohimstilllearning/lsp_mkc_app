import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' as kIsWeb;

class ApiService {
  static String get baseUrl {
    return 'https://ujikomp.lspmkc.or.id/api';
  }

  /// register user
  static Future<Map<String, dynamic>> register(
    String name,
    String username,
    String email,
    String password,
    String identity_type,
    String identity_number,
  ) async {
    final url = Uri.parse('$baseUrl/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'username': username,
          'email': email,
          'identity_type': identity_type,
          'identity_number': identity_number,
          'password': password,
        }),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        // 201 untuk status succes update, 200 buat status get
        return jsonDecode(response.body);
      } else {
        final msg = jsonDecode(response.body);
        throw Exception(
          msg['message'] ?? 'Registrasi gagal',
        ); // throw memberhentikan kode diatas/dibawah kemudian dilompat ke catch agar mendapatkan sebuah error yang lebih jelas
      }
    } catch (e) {
      throw Exception('Registration corrupted: $e');
    }
  }

  /// login user
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final msg = jsonDecode(response.body);
        throw Exception(msg['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Login corrupted: $e');
    }
  }

  ///logout user 
}
