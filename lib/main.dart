import 'dart:convert';
import 'package:app_links/app_links.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:lsp_mkc_app/pages/auth/verify_controller.dart';
import 'package:lsp_mkc_app/routes/app_pages.dart';
import 'package:lsp_mkc_app/routes/app_routes.dart';
import 'package:lsp_mkc_app/utils/api_endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(
    MyApp(),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  void _initDeepLinks() async {
    final appLinks = AppLinks();

    appLinks.uriLinkStream.listen((uri) async {
      print('Deep link received: $uri');
      await _handleVerifyEmail(uri);
    });

    final uri = await appLinks.getInitialLink();
    if (uri != null) {
      print('Initial link: $uri');
      await _handleVerifyEmail(uri);
    }
  }

  Future<void> _handleVerifyEmail(Uri uri) async {
    if (!uri.path.contains('verify-email')) return;

    final fixedUrl = uri.toString().replaceAll('%26', '&');
    final fixedUri = Uri.parse(fixedUrl);

    print('Fixed URL: $fixedUrl');

    final response = await http.get(fixedUri, headers: ApiEndpoints.headers);
    print('Verify status: ${response.statusCode}');
    print('Verify body: ${response.body}');

    if (response.statusCode == 200) {
      // cek apakah user masih di verify page
      if (Get.isRegistered<VerifyController>()) {
        // panggil controller untuk handle login & redirect
        await Get.find<VerifyController>().onDeepLinkVerified();
      } else {
        // user tidak di verify page, login sendiri
        await _loginAndRedirect();
      }
    } else {
      Get.snackbar(
        'Gagal',
        'Verifikasi email gagal, coba lagi',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 10,
      );
    }
  }

  Future<void> _loginAndRedirect() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('temp_email');
      final password = prefs.getString('temp_password');

      if (email == null || password == null) {
        Get.snackbar(
          'Berhasil',
          'Email berhasil diverifikasi, silakan login',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 10,
        );
        Get.offAllNamed(AppPages.login);
        return;
      }

      final url = Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.authEndPoints.loginPoint);
      final loginResponse = await http.post(
        url,
        headers: ApiEndpoints.headers,
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('Login after verify status: ${loginResponse.statusCode}');

      if (loginResponse.statusCode == 200) {
        var bodyStr = loginResponse.body.trim();
        if (bodyStr.startsWith('"') && bodyStr.endsWith('"')) {
          bodyStr = jsonDecode(bodyStr);
        }
        final json = jsonDecode(bodyStr);
        final token = json['token'];

        if (token != null) {
          await prefs.setString('token', token);
          await prefs.remove('temp_email');
          await prefs.remove('temp_password');
          Get.offAllNamed(AppPages.home);
        }
      } else {
        Get.snackbar(
          'Berhasil',
          'Email berhasil diverifikasi, silakan login',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 10,
        );
        Get.offAllNamed(AppPages.login);
      }
    } catch (e) {
      print('Login after verify error: $e');
      Get.offAllNamed(AppPages.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.loading,
      getPages: AppRoutes.getRoutes(),
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
    );
  }
}