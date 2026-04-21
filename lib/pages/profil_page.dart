import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lsp_mkc_app/pages/profil_controller.dart';
import 'package:lsp_mkc_app/pages/profile_document_section.dart';

class ProfilPage extends GetView<ProfilController> {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF3E8E41)),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [

              const SizedBox(height: 24),

              // ─────────────────────────────────────
              // Header: foto + nama + email
              // Rata tengah, tanpa card/container
              // ─────────────────────────────────────
              Column(
                children: [
                  // Avatar lingkaran abu-abu
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: controller.photoUrl.value.isNotEmpty
                        ? NetworkImage(controller.photoUrl.value)
                        : null,
                    child: controller.photoUrl.value.isEmpty
                        ? Icon(Icons.person,
                            size: 48, color: Colors.grey.shade500)
                        : null,
                  ),

                  const SizedBox(height: 12),

                  // Nama
                  Obx(() => Text(
                        controller.displayName.value.isEmpty
                            ? 'display.name_'
                            : controller.displayName.value,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      )),

                  const SizedBox(height: 2),

                  // Email — abu-abu kecil
                  Obx(() => Text(
                        controller.email.value.isEmpty
                            ? 'useremail@gmail23.com'
                            : controller.email.value,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      )),
                ],
              ),

              const SizedBox(height: 28),

              // ─────────────────────────────────────
              // Label "Menu"
              // ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(left: 20, bottom: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                ),
              ),

              // ─────────────────────────────────────
              // Daftar Menu — semua dalam 1 card putih
              // ─────────────────────────────────────
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [

                    // ── Bar 1: Ubah Nama ──
                    _MenuItem(
                      icon: Icons.grid_view_rounded,
                      label: 'Ubah Nama',
                      subtitleObs: controller.displayName,
                      onTap: () => _showEditSheet(
                        title: 'Ubah Nama',
                        hint: 'Masukkan nama baru',
                        initialValue: controller.displayName.value,
                        onSave: (v) => controller.updateName(v),
                      ),
                    ),

                    _Divider(),

                    // ── Bar 3: Ubah Email ──
                    _MenuItem(
                      icon: Icons.chrome_reader_mode_outlined,
                      label: 'Ubah Email',
                      subtitleObs: controller.email,
                      onTap: () => _showEditSheet(
                        title: 'Ubah Email',
                        hint: 'Masukkan email baru',
                        initialValue: controller.email.value,
                        keyboardType: TextInputType.emailAddress,
                        onSave: (v) => controller.updateEmail(v),
                      ),
                    ),

                    _Divider(),

                    // ── Bar 4: Ubah Password ──
                    _MenuItem(
                      icon: Icons.crop_square_outlined,
                      label: 'Ubah Password',
                      subtitle: '••••••••',
                      onTap: () => _showPasswordSheet(),
                    ),

                    _Divider(),

                    // ── Bar 5: Info Akun (read-only, tidak ada onTap) ──
                    _MenuItem(
                      icon: Icons.notifications_outlined,
                      label: 'Info Akun',
                      subtitleObs: controller.role,
                    ),
                    ProfileDocumentSection()
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Bottom sheet edit 1 field
  // ─────────────────────────────────────────────────────────────
  void _showEditSheet({
    required String title,
    required String hint,
    required String initialValue,
    required Function(String) onSave,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
  }) {
    final textCtrl = TextEditingController(text: initialValue);

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: Get.mediaQuery.viewInsets.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SheetHandle(),
            Text(title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
              controller: textCtrl,
              keyboardType: keyboardType,
              maxLength: maxLength,
              autofocus: true,
              decoration: InputDecoration(
                hintText: hint,
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 16),
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: controller.isSaving.value
                        ? null
                        : () => onSave(textCtrl.text.trim()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3E8E41),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: controller.isSaving.value
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('Simpan',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700)),
                  ),
                )),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Bottom sheet password (3 field)
  // ─────────────────────────────────────────────────────────────
  void _showPasswordSheet() {
    final currentCtrl = TextEditingController();
    final newCtrl     = TextEditingController();
    final confirmCtrl = TextEditingController();
    final hideCurrent = true.obs;
    final hideNew     = true.obs;
    final hideConfirm = true.obs;

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: Get.mediaQuery.viewInsets.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SheetHandle(),
              const Text('Ubah Password',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              _PasswordField(label: 'Password Lama',
                  hint: 'Masukkan password lama',
                  controller: currentCtrl, hideObs: hideCurrent),
              const SizedBox(height: 12),
              _PasswordField(label: 'Password Baru',
                  hint: 'Minimal 8 karakter',
                  controller: newCtrl, hideObs: hideNew),
              const SizedBox(height: 12),
              _PasswordField(label: 'Konfirmasi Password Baru',
                  hint: 'Ulangi password baru',
                  controller: confirmCtrl, hideObs: hideConfirm),
              const SizedBox(height: 20),
              Obx(() => SizedBox(
                    width: double.infinity, height: 48,
                    child: ElevatedButton(
                      onPressed: controller.isSaving.value
                          ? null
                          : () => controller.updatePassword(
                                currentPassword: currentCtrl.text.trim(),
                                newPassword:     newCtrl.text.trim(),
                                confirmPassword: confirmCtrl.text.trim(),
                              ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3E8E41),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: controller.isSaving.value
                          ? const SizedBox(width: 20, height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text('Simpan Password',
                              style: TextStyle(color: Colors.white,
                                  fontWeight: FontWeight.w700)),
                    ),
                  )),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

// ════════════════════════════════════════════════════════════
// WIDGET HELPER
// ════════════════════════════════════════════════════════════

// ── _MenuItem ──
// Satu baris menu — icon kotak abu-abu + label + subtitle
// Mengikuti gaya desain di gambar: icon dalam box, teks di kanan
class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final RxString? subtitleObs; // nilai reaktif (update otomatis)
  final String subtitle;       // nilai statis (untuk password)
  final VoidCallback? onTap;   // null = read-only

  const _MenuItem({
    required this.icon,
    required this.label,
    this.subtitleObs,
    this.subtitle = '',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // InkWell → area yang bisa diklik dengan efek ripple
      onTap: onTap,
      // borderRadius agar ripple mengikuti sudut container
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // ── Icon Box ──
            // Kotak abu-abu dengan icon di dalamnya (sesuai desain)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                // Read-only = abu, editable = hitam
                color: onTap == null
                    ? Colors.grey.shade400
                    : Colors.black54,
              ),
            ),

            const SizedBox(width: 14),

            // ── Teks (Label + Subtitle) ──
            Expanded(
              // Expanded → ambil sisa ruang horizontal yang tersedia
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  // Tampilkan subtitle jika ada
                  if (subtitleObs != null)
                    Obx(() => Text(
                          subtitleObs!.value.isEmpty
                              ? '-'
                              : subtitleObs!.value,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ))
                  else if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                ],
              ),
            ),

            // Chevron hanya untuk item editable
            if (onTap != null)
              Icon(Icons.chevron_right,
                  color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── _Divider ──
class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Divider(
      height: 1, thickness: 1,
      color: Colors.grey.shade100,
      indent: 70,   // mulai setelah icon box (40px + 16px padding + 14px gap)
      endIndent: 16);
}

// ── _SheetHandle ──
class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          width: 40, height: 4,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );
}

// ── _PasswordField ──
class _PasswordField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final RxBool hideObs;

  const _PasswordField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.hideObs,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 6),
        Obx(() => TextField(
              controller: controller,
              obscureText: hideObs.value,
              decoration: InputDecoration(
                hintText: hint,
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                suffixIcon: IconButton(
                  icon: Icon(hideObs.value
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: () => hideObs.value = !hideObs.value,
                ),
              ),
            )),
      ],
    );
  }
}