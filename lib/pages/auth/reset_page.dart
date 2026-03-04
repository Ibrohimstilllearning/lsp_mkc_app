import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lsp_mkc_app/pages/auth/reset_controller.dart';
import 'package:lsp_mkc_app/routes/app_pages.dart';

class ResetPage extends GetView<ResetController> {
   ResetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF009447),
      body: SafeArea(
        child: Column(
          children: [
             Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row( 
                children: [ 
                  IconButton(
                    onPressed: () => Get.back(), 
                    icon: Icon(Icons.arrow_back, color: Colors.white,)
                    )
                ],
              ),
            ),

              Padding(padding: EdgeInsets.symmetric(),
              child: Column(
                children: [
                  Image.asset(
                    'assets/reset.png',
                    height: 240,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 20),
              Text(
                'Lupa Kata Sandi',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Ganti kata sandi anda dan gunakan akun yang sama.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 40),
                ],
              ),
            ),
            
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Column(
              children: [
                _buildPasswordField("Kata Sandi Saat Ini"),
                _buildPasswordField("Kata Sandi Baru"),
                _buildPasswordField("Konfirmasi Kata Sandi Baru")
              ],
            ), 
          ),

          const SizedBox(height: 20,),

          Padding(padding: EdgeInsets.symmetric(horizontal: 30),
          child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF009447),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {}, // ← sambungkan
                  child: Text(
                    'Ganti Kata Sandi',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          )

          ],
        )
      ),
    );
  }
}

Widget _buildPasswordField(String label, {TextEditingController? controller}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14)),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          obscureText: true,
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    ),
  );
}