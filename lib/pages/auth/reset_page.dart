import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lsp_mkc_app/pages/auth/reset_controller.dart';
import 'package:lsp_mkc_app/routes/app_pages.dart';

class ResetPage extends GetView<ResetController> {
  const ResetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        switch (controller.step.value) {
          case 1:
            return _StepEmail(controller: controller);
          case 2:
            return _StepOtp(controller: controller);
          case 3:
            return _StepNewPassword(controller: controller);
          default:
            return _StepEmail(controller: controller);
        }
      }),
    );
  }
}

// ─────────────────────────────────────
// Step 1 - Input Email
// ─────────────────────────────────────
class _StepEmail extends StatelessWidget {
  final ResetController controller;
  const _StepEmail({required this.controller});

  @override
  Widget build(BuildContext context) {
    final emailCtrl = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text("Lupa Password",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("Masukkan email kamu, kami akan kirimkan kode OTP.",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
          const SizedBox(height: 32),

          // Input Email
          TextField(
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'Email',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.email_outlined),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),

          const SizedBox(height: 24),

          // Tombol Kirim
          Obx(() => SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () => controller.sendForgotPassword(emailCtrl.text.trim()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3E8E41),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Kirim Kode OTP',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
                ),
              )),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────
// Step 2 - Input OTP
// ─────────────────────────────────────
class _StepOtp extends StatelessWidget {
  final ResetController controller;
  const _StepOtp({required this.controller});

  @override
  Widget build(BuildContext context) {
    final otpCtrl = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text("Verifikasi OTP",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Obx(() => Text(
                "Kode OTP telah dikirim ke ${controller.email.value}",
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              )),
          const SizedBox(height: 32),

          // Input OTP
          TextField(
            controller: otpCtrl,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, letterSpacing: 8),
            decoration: InputDecoration(
              hintText: '------',
              counterText: '',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),

          const SizedBox(height: 24),

          // Tombol Verifikasi
          Obx(() => SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () => controller.verifyOtp(otpCtrl.text.trim()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3E8E41),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Verifikasi OTP',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
                ),
              )),

          const SizedBox(height: 16),

          // Kirim Ulang OTP
          Center(
            child: TextButton(
              onPressed: () =>
                  controller.sendForgotPassword(controller.email.value),
              child: Text('Kirim Ulang OTP',
                  style: TextStyle(color: Colors.grey.shade600)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────
// Step 3 - Input Password Baru
// ─────────────────────────────────────
class _StepNewPassword extends StatelessWidget {
  final ResetController controller;
  const _StepNewPassword({required this.controller});

  @override
  Widget build(BuildContext context) {
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    final hideNew = true.obs;
    final hideConfirm = true.obs;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text("Password Baru",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("Masukkan password baru kamu.",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
          const SizedBox(height: 32),

          // Input Password Baru
          Obx(() => TextField(
                controller: newPassCtrl,
                obscureText: hideNew.value,
                decoration: InputDecoration(
                  hintText: 'Password Baru (min. 8 karakter)',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(hideNew.value
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () => hideNew.value = !hideNew.value,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              )),

          const SizedBox(height: 16),

          // Input Konfirmasi Password
          Obx(() => TextField(
                controller: confirmPassCtrl,
                obscureText: hideConfirm.value,
                decoration: InputDecoration(
                  hintText: 'Konfirmasi Password Baru',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(hideConfirm.value
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () => hideConfirm.value = !hideConfirm.value,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              )),

          const SizedBox(height: 24),

          // Tombol Reset
          Obx(() => SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () => controller.resetPassword(
                            newPassword: newPassCtrl.text.trim(),
                            confirmPassword: confirmPassCtrl.text.trim(),
                          ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3E8E41),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Ubah Password',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
                ),
              )),
        ],
      ),
    );
  }
}