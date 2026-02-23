import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

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
    String identityType,
    String identityNumber,
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
          'identity_type': identityType,
          'identity_number': identityNumber,
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

   /// Get user info
  
   static Future<Map<String, dynamic>> getUserInfo(String token) async {
    final url = Uri.parse('$baseUrl/users');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type' : 'application/json',
          'Authorization' : 'Bearer $token',
        }
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get User information');
      }

    } catch (e) {
      throw Exception('Data Corrupted: $e');
    }
   }


  ///logout user
  static Future<void> logout(String token) async {
    final url = Uri.parse('$baseUrl/logout');
    try {
      final response =  await http.post(
        url,
        headers: {
          'Content-Type' : 'application/json',
          'Authorization' : 'Bearer $token'
        }
      );
      if (response.statusCode != 200) {
        throw Exception('failed to logout');
      } 
    } catch (e) {
      throw Exception('Session Corrupted: $e');
    }
  }
  
}
