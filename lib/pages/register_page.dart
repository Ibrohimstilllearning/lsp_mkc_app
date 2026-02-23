import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF009447),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            const SizedBox(height: 60),
            Text(
              'Buat Akun\nKompetensi',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 28, 
                fontWeight: FontWeight.bold, 
                color: Colors.white
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Lengkapi data diri Anda untuk memulai proses sertifikasi BNSP',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13),
            ),
            const SizedBox(height: 40),
            _buildField('Nama Lengkap'),
            _buildField('Email'),
            _buildField('Kata Sandi', isPassword: true),
            _buildField('Konfirmasi Kata Sandi', isPassword: true),
            Row(
              children: [
                Checkbox(
                  value: false, 
                  onChanged: (val) {}, 
                  side: const BorderSide(color: Colors.white)
                ),
                Expanded(
                  child: Text(
                    'Saya menyetujui Syarat & Ketentuan serta Kebijakan Privasi',
                    style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder( // SUDAH DIPERBAIKI
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {},
                child: Text(
                  'Daftar', 
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF009447), 
                    fontWeight: FontWeight.bold
                  )
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'Sudah Punya Akun? Masuk', 
                style: GoogleFonts.plusJakartaSans(color: Colors.white)
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14)),
          const SizedBox(height: 5),
          TextField(
            obscureText: isPassword,
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10), 
                borderSide: BorderSide.none
              ),
            ),
          ),
        ],
      ),
    );
  }
}