import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:lsp_mkc_app/utils/api_endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegistrationController extends GetxController {
TextEditingController roleController = TextEditingController();
TextEditingController identityTypeController = TextEditingController();
TextEditingController identityNumberController = TextEditingController();
TextEditingController nameController = TextEditingController();
TextEditingController emailController = TextEditingController();
TextEditingController passwordController = TextEditingController();
TextEditingController passwordConfController = TextEditingController();

final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

Future<void> registerMethod() async {
  try {
    var headers = {'Content-Type' : 'application/json'};
    var url = Uri.parse(ApiEndpoints.baseUrl = ApiEndpoints.authEndPoints.registerPoint);
    Map body = {
      'role' : roleController.text,
      'identity_type' : identityTypeController.text,
      'identity_number' : identityNumberController.text,
      'name' : nameController.text,
      'email' : emailController.text.trim(),
      'password' : passwordController.text,
      'password_confirmation' : passwordConfController.text
    };

    http.Response response = await http.post(url, body: jsonEncode(body), headers: headers);

    if (response.statusCode == 201 || response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['code'] == 0) {
        var token = json['data']['token'];
        print(token);
        final SharedPreferences prefs = await _prefs;

        await prefs?.setString('token', token);
        roleController.clear();
        identityTypeController.clear();
        identityNumberController.clear();
        nameController.clear();
        emailController.clear();
      } else {
        throw jsonDecode(response.body)['message'] ?? "Unknown Error Occured";
      }
    }
  } catch(e) {
    Get.back();
    showDialog(context: Get.context!, builder: (context) {
      return SimpleDialog(
        title: Text('error'),
        contentPadding: EdgeInsets.all(20),
        children: [
          Text(e.toString())
        ],
      );
    });
  }
} 


}