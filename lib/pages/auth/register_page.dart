import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'registration_controller.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isChecked = false;
  String _selectedIdentityType = 'id';
  final RegistrationController _controller = Get.put(RegistrationController());

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
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Lengkapi data diri Anda untuk memulai proses sertifikasi BNSP',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13),
            ),
            const SizedBox(height: 40),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Jenis Identitas',
                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  // Radio KTP
                  Radio<String>(
                    value: 'id',
                    groupValue: _selectedIdentityType,
                    onChanged: (val) {
                      setState(() {
                        _selectedIdentityType = val!;
                        _controller.identityType = val;
                      });
                    },
                    fillColor: WidgetStateProperty.all(Colors.white),
                  ),
                  Text(
                    'KTP',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontWeight: _selectedIdentityType == 'id'
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),

                  const SizedBox(width: 20),

                  // Radio Passport
                  Radio<String>(
                    value: 'passport',
                    groupValue: _selectedIdentityType,
                    onChanged: (val) {
                      setState(() {
                        _selectedIdentityType = val!;
                        _controller.identityType = val;
                      });
                    },
                    fillColor: WidgetStateProperty.all(Colors.white),
                  ),
                  Text(
                    'Passport',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontWeight: _selectedIdentityType == 'passport'
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            _buildField('No Identitas', controller: _controller.identityNumberController),
            _buildField('Nama Lengkap', controller: _controller.nameController),
            _buildField('Email', controller: _controller.emailController),
            _buildField('Kata Sandi', isPassword: true, controller: _controller.passwordController),
            _buildField('Konfirmasi Kata Sandi', isPassword: true, controller: _controller.passwordConfController),
            Row(
              children: [
                Checkbox(
                  value: _isChecked,
                  onChanged: (val) {
                    setState(() => _isChecked = val ?? false);
                  },
                  side: WidgetStateBorderSide.resolveWith((states) {
                    return const BorderSide(color: Colors.white, width: 2);
                  }),
                  fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.white;
                    }
                    return Colors.transparent;
                  }),
                  checkColor: const Color(0xFF009447),
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
            // Ganti bagian ElevatedButton "Daftar" dengan ini:
Obx(() => SizedBox(
  width: double.infinity,
  height: 50,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    onPressed: _controller.isLoading.value
        ? null
        : () {
            if (!_isChecked) {
              Get.snackbar(
                'Perhatian',
                'Anda harus menyetujui Syarat & Ketentuan terlebih dahulu',
                backgroundColor: Colors.red,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(20),
                borderRadius: 10,
              );
              return;
            }
            _controller.registerMethod();
          },
    child: _controller.isLoading.value
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: Color(0xFF009447),
              strokeWidth: 2,
            ),
          )
        : Text(
            'Daftar',
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFF009447),
              fontWeight: FontWeight.bold,
            ),
          ),
  ),
)),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'Sudah Punya Akun? Masuk',
                style: GoogleFonts.plusJakartaSans(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, {bool isPassword = false, TextEditingController? controller}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14)),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            obscureText: isPassword,
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
}