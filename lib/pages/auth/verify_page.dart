import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lsp_mkc_app/pages/auth/verify_controller.dart';
import 'package:lsp_mkc_app/routes/app_pages.dart';

class VerifyPage extends StatelessWidget {
  const VerifyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VerifyController>();
    return Scaffold(
      backgroundColor: const Color(0xFF009447),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Obx(() => AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: controller.isVerified.value
                    ? const Icon(
                        Icons.check_circle_outline,
                        key: ValueKey('verified'),
                        size: 100,
                        color: Colors.white,
                      )
                    : const Icon(
                        Icons.mark_email_unread_outlined,
                        key: ValueKey('unverified'),
                        size: 100,
                        color: Colors.white,
                      ),
              )),
              const SizedBox(height: 30),
              Obx(() => Text(
                controller.isVerified.value
                    ? 'Email Terverifikasi!'
                    : 'Verifikasi Email Anda',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )),
              const SizedBox(height: 16),
              Obx(() => Text(
                controller.isVerified.value
                    ? 'Akun Anda berhasil diverifikasi. Mengalihkan ke beranda...'
                    : 'Kami telah mengirim link verifikasi ke email Anda. Silakan cek inbox atau folder spam.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14),
              )),
              const SizedBox(height: 12),
              Obx(() => !controller.isVerified.value
                  ? Text(
                      'Halaman ini otomatis berpindah setelah email terverifikasi.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white70,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  : const SizedBox.shrink(),
              ),
              const SizedBox(height: 40),
              Obx(() => controller.isVerified.value
                  ? const Icon(Icons.verified, size: 50, color: Colors.white)
                  : Column(
                      children: [
                        const CircularProgressIndicator(color: Colors.white),
                        const SizedBox(height: 8),
                        Text(
                          'Menunggu verifikasi...',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
              ),
              const SizedBox(height: 40),
              Obx(() => !controller.isVerified.value
                  ? Column(
                      children: [
                        Obx(() {
                          final canResend = controller.canResend.value;
                          final countdown = controller.countdown.value;
                          return SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: canResend ? Colors.white : Colors.white38,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: canResend ? controller.resendVerification : null,
                              child: Text(
                                canResend
                                    ? 'Kirim Ulang Email Verifikasi'
                                    : 'Kirim Ulang (${countdown}s)',
                                style: GoogleFonts.plusJakartaSans(
                                  color: canResend ? const Color(0xFF009447) : Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => Get.offAllNamed(AppPages.login),
                          child: Text(
                            'Kembali ke Login',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Get.offAllNamed(AppPages.login),
                          child: Text(
                            'Sudah verifikasi? Login sekarang',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}