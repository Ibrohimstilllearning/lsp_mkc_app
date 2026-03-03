import 'package:app_links/app_links.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:lsp_mkc_app/routes/app_pages.dart';
import 'package:lsp_mkc_app/routes/app_routes.dart';
import 'package:lsp_mkc_app/utils/api_endpoints.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      defaultDevice: Devices.ios.iPhone11ProMax,
      devices: [Devices.ios.iPhone11ProMax],
      builder: (context) => const MyApp(),
    ),
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

    // handle saat app sudah running
    appLinks.uriLinkStream.listen((uri) async {
      print('Deep link received: $uri');
      await _handleVerifyEmail(uri);
    });

    // handle saat app baru dibuka via link
    final uri = await appLinks.getInitialLink();
    if (uri != null) {
      print('Initial link: $uri');
      await _handleVerifyEmail(uri);
    }
  }

  Future<void> _handleVerifyEmail(Uri uri) async {
  if (uri.path.contains('verify-email')) {
    // decode %26 jadi & yang sebenarnya
    final fixedUrl = uri.toString().replaceAll('%26', '&');
    final fixedUri = Uri.parse(fixedUrl);
    
    print('Fixed URL: $fixedUrl'); // ← cek hasilnya
    
    final response = await http.get(fixedUri, headers: ApiEndpoints.headers);
    print('Verify status: ${response.statusCode}');
    print('Verify body: ${response.body}');

    if (response.statusCode == 200) {
      Get.snackbar(
        'Berhasil',
        'Email berhasil diverifikasi, silakan login',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        'Gagal',
        'Verifikasi email gagal, coba lagi',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
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
      initialRoute: AppPages.onboarding,
      getPages: AppRoutes.getRoutes(),
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
    );
  }
}