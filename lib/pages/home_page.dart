import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lsp_mkc_app/pages/forms/apl02/apl_02.dart';
import 'package:lsp_mkc_app/pages/home_controller.dart';
import 'package:lsp_mkc_app/pages/pengajuan_page.dart';
import 'package:lsp_mkc_app/pages/profil_page.dart';
import 'package:lsp_mkc_app/pages/riwayat_page.dart';
import 'package:lsp_mkc_app/routes/app_pages.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final RxInt currentIndex = 0.obs;

    final List<Widget> pages = [
      _HomeTab(currentIndex: currentIndex),
      const PengajuanPage(),
      const RiwayatPage(),
      const ProfilPage(),
    ];

    return Obx(() => Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          body: SafeArea(
            child: pages[currentIndex.value],
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Container(
              height: 65,
              decoration: BoxDecoration(
                color: const Color(0xFF3E8E41),
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    icon: Icons.home,
                    isActive: currentIndex.value == 0,
                    onTap: () => currentIndex.value = 0,
                  ),
                  _NavItem(
                    icon: Icons.description,
                    isActive: currentIndex.value == 1,
                    onTap: () => currentIndex.value = 1,
                  ),
                  _NavItem(
                    icon: Icons.history,
                    isActive: currentIndex.value == 2,
                    onTap: () => currentIndex.value = 2,
                  ),
                  _NavItem(
                    icon: Icons.person,
                    isActive: currentIndex.value == 3,
                    onTap: () => currentIndex.value = 3,
                  ),
                  GestureDetector(
                    onTap: () => Get.dialog(
                      AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Yakin ingin keluar?'),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () {
                              Get.back();
                              controller.logoutMethod();
                            },
                            child: const Text('Keluar',
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    ),
                    child: const Icon(Icons.logout, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

// ─── Home Tab ─────────────────────────────────────────────────────────────────
class _HomeTab extends StatelessWidget {
  final RxInt currentIndex;
  const _HomeTab({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/serviceunavailable.png',
                width: 250,
                height: 200,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 24),
              const Text(
                "Belum ada pengajuan\npending, buat satu?",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => Get.dialog(
                AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Text(
                    'Pilih Form',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Pilih form yang ingin diisi:',
                        style:
                            TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            Get.back();
                            Get.toNamed(AppPages.apl01);
                          },
                          child: const Text(
                            'FR.APL.01 — Permohonan Sertifikasi',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            Get.back();
                            Get.toNamed(AppPages.apl02, arguments: 11); // TODO: ganti 11 dengan ID registrasi yang dinamis nantinya
                          },
                          child: const Text(
                            'FR.APL.02 — Assesmen Mandiri',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            Get.back();
                            Get.toNamed(AppPages.ak01, arguments: {'registrationId': 11});
                          },
                          child: const Text(
                            'FR.AK.01 — Persetujuan Asesmen',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF4CAF50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 0,
    ),
    onPressed: () {
      Get.back();
      Get.toNamed(AppPages.ak04);
    },
    child: const Text(
      'FR.AK.04 — Banding Asesmen',
      style: TextStyle(
        color: Colors.white,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
),
const SizedBox(height: 16),
SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF4CAF50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 0,
    ),
    onPressed: () {
      Get.back();
      Get.toNamed(AppPages.ak07);
    },
    child: const Text('FR.AK.07 — Ceklis Penyesuaian',
        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
  ),
),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text(
                        'Batal',
                        style: TextStyle(color: Color(0xFF9CA3AF)),
                      ),
                    ),
                  ],
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3E8E41),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Mulai Proses Sertifikasi",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 26),
      ],
    );
  }
}

// ─── Nav Item ─────────────────────────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white.withOpacity(0.25)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: isActive ? Colors.white : Colors.white70),
      ),
    );
  }
}
