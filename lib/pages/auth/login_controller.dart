import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:lsp_mkc_app/utils/api_endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<void> loginMethod() async {
    var header = {'Content-Type' : 'application/json'};
    try {
    var url = Uri.parse(ApiEndpoints.baseUrl = ApiEndpoints.authEndPoints.loginPoint);
      Map body = {
        'email' : emailController.text,
        'password' : passwordController.text
      };

      http.Response response = await http.post(url, body: jsonEncode(body), headers: header);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['code'] == 0) {
          var token = json['data']['token'];
          final SharedPreferences? prefs = await _prefs; 
          await prefs?.setString('token', token);

          emailController.clear();
          passwordController.clear();
        } else if (json['code'] == 1) {
          throw jsonDecode(response.body)['message'];
        } 
      } else {
        throw jsonDecode(response.body)['message'] ?? 'Unknown Error';
      }
    } catch (e) {
      Get.back();
      showDialog(context: Get.context!, builder: (context) {
        return SimpleDialog(
          title: Text('Error'),
          contentPadding: EdgeInsets.all(20),
          children: [Text(e.toString())],
        );
      });
    }


  }
}