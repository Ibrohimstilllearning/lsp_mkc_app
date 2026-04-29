import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lsp_mkc_app/pages/forms/apl02/services/apl02_navigation_helper.dart';
import 'package:lsp_mkc_app/pages/home_controller.dart';
import 'package:lsp_mkc_app/pages/pengajuan_controller.dart';
import 'package:lsp_mkc_app/pages/riwayat_page.dart';
import 'package:lsp_mkc_app/pages/profil_page.dart';
import 'package:lsp_mkc_app/pages/registration_scheme_list_page.dart';
import 'package:lsp_mkc_app/routes/app_pages.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final RxInt currentIndex = 0.obs;

    final List<Widget> pages = [
      _HomeTab(currentIndex: currentIndex, controller: controller),
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
                    icon: Icons.history,
                    isActive: currentIndex.value == 1,
                    onTap: () => currentIndex.value = 1,
                  ),
                  _NavItem(
                    icon: Icons.person,
                    isActive: currentIndex.value == 2,
                    onTap: () => currentIndex.value = 2,
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

// ─── Home Tab ──────────────────────────────────────────────────────────────────
class _HomeTab extends StatelessWidget {
  final RxInt currentIndex;
  final HomeController controller;

  const _HomeTab({
    required this.currentIndex,
    required this.controller,
  });


  Widget _formButton({required String label, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pengajuanController = Get.find<PengajuanController>();

    // Stack supaya tombol fixed bisa ditaruh di atas konten
    return Stack(
      children: [
        RefreshIndicator(
          color: const Color(0xFF4CAF50),
          onRefresh: () async {
            await pengajuanController.fetchPengajuan();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() => Text(
                              "Hello, ${controller.displayName.value.isEmpty ? 'User' : controller.displayName.value}",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            )),
                        const SizedBox(height: 2),
                        const Text(
                          'Monitor status form yang kamu ajukan',
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => pengajuanController.fetchPengajuan(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: const Icon(Icons.refresh_rounded,
                          size: 18, color: Color(0xFF4CAF50)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Banner LSP MKC ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDF7ED),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF3E8E41).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/serviceunavailable.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "LSP MKC ONLINE APP",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Platform sertifikasi kompetensi resmi yang terakreditasi BNSP.",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Konten Pengajuan ──
            Obx(() {
              if (pengajuanController.isLoading.value) {
                return _SkeletonList();
              }
                if (pengajuanController.hasError.value) {
                  return _ErrorState(
                      onRetry: pengajuanController.fetchPengajuan);
                }
                if (pengajuanController.pengajuanList.isEmpty) {
                  return const _EmptyState();
                }
                return _PengajuanList(
                    controller: pengajuanController);
              }),

            // padding bawah supaya konten ga ketutup tombol fixed
            Obx(() => SizedBox(height: pengajuanController.hasActiveRegistration ? 20 : 80)),
          ],
        ),
      ),
    ),

    // ── Tombol Fixed di Bawah ──
        Obx(() {
          if (pengajuanController.isLoading.value) return const SizedBox.shrink();
          if (pengajuanController.hasActiveRegistration) return const SizedBox.shrink();

          return Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Get.to(() => const RegistrationSchemeListPage()),
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
          );
        }),
      ],
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/serviceunavailable.png',
            width: 180,
            height: 150,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 16),
          const Text(
            "Belum ada pengajuan\npending, buat satu?",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ─── Error State ──────────────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFFFEDED),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wifi_off_rounded,
                  size: 30, color: Color(0xFFEF4444)),
            ),
            const SizedBox(height: 16),
            const Text('Gagal memuat data',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827))),
            const SizedBox(height: 4),
            const Text('Periksa koneksi dan coba lagi',
                style:
                    TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              icon: const Icon(Icons.refresh_rounded,
                  color: Colors.white, size: 16),
              label: const Text('Coba Lagi',
                  style: TextStyle(color: Colors.white)),
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Skeleton ─────────────────────────────────────────────────────────────────
class _SkeletonList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: 3,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                height: 14,
                width: 180,
                decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(6))),
            const SizedBox(height: 8),
            Container(
                height: 11,
                width: 100,
                decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(6))),
            const SizedBox(height: 16),
            ...List.generate(
                3,
                (_) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius:
                                  BorderRadius.circular(8))),
                    )),
          ],
        ),
      ),
    );
  }
}

// ─── Pengajuan List ───────────────────────────────────────────────────────────
class _PengajuanList extends StatelessWidget {
  final PengajuanController controller;
  const _PengajuanList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: controller.pengajuanList.length,
      itemBuilder: (context, index) {
        final item = controller.pengajuanList[index];
        return _RegistrationCard(item: item);
      },
    );
  }
}

// ─── Registration Card ────────────────────────────────────────────────────────
class _RegistrationCard extends StatelessWidget {
  final RegistrationItem item;
  const _RegistrationCard({required this.item});

  bool get _canCancel {
    return !item.forms.any((f) =>
        f.status == 'submitted' ||
        f.status == 'approved' ||
        f.status == 'paid' ||
        f.status == 'pending');
  }

  void _showCancelDialog(BuildContext context) {
    final controller = Get.find<PengajuanController>();

    Get.dialog(
      Obx(() => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Batalkan Pengajuan?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Yakin ingin membatalkan "${item.schemeName}"?\n\nTindakan ini tidak dapat dibatalkan.',
          style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
        ),
        actions: [
          TextButton(
            onPressed: controller.isCancelling.value ? null : () => Get.back(),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: controller.isCancelling.value
                ? null
                : () {
                    Get.back();
                    controller.cancelRegistration(item.registrationId);
                  },
            child: controller.isCancelling.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Ya, Batalkan', style: TextStyle(color: Colors.white)),
          ),
        ],
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card (sama seperti sebelumnya)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.workspace_premium_outlined, size: 20, color: Color(0xFF4CAF50)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.schemeName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                      const SizedBox(height: 2),
                      Text(item.schemeCode, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Diajukan', style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
                    Text(item.createdAt, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF3F4F6)),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: () {
                // Logika: Tampilkan form satu per satu (sekuensial).
                // Form berikutnya HANYA muncul jika form saat ini sudah 'approved' atau 'paid'.
                final visibleForms = <RegistrationForm>[];
                for (int i = 0; i < item.forms.length; i++) {
                  final form = item.forms[i];
                  visibleForms.add(form);
                  
                  // Jika form ini belum selesai/disetujui, JANGAN tampilkan form d bawahnya
                  if (form.status != 'approved' && form.status != 'paid') {
                    break;
                  }
                }

                return visibleForms.map((form) => _FormRow(
                      form: form,
                      registrationId: item.registrationId,
                    )).toList();
              }(),
            ),
          ),

          if (_canCancel) ...[
            const Divider(height: 1, color: Color(0xFFF3F4F6)),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFEF4444)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  icon: const Icon(Icons.cancel_outlined, color: Color(0xFFEF4444), size: 16),
                  label: const Text(
                    'Batalkan Pengajuan',
                    style: TextStyle(color: Color(0xFFEF4444), fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  onPressed: () => _showCancelDialog(context),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Form Row ─────────────────────────────────────────────────────────────────
class _FormRow extends StatelessWidget {
  final RegistrationForm form;
  final int registrationId;
  const _FormRow({required this.form, required this.registrationId});

  _StatusConfig _getConfig(String status) {
    switch (status) {
      case 'approved':
        return _StatusConfig(
          label: 'Disetujui',
          color: const Color(0xFF4CAF50),
          bg: const Color(0xFFE8F5E9),
          icon: Icons.check_circle_rounded,
        );
      case 'pending':
        return _StatusConfig(
          label: 'Menunggu',
          color: const Color(0xFFF59E0B),
          bg: const Color(0xFFFFFBEB),
          icon: Icons.access_time_rounded,
        );
      case 'rejected':
        return _StatusConfig(
          label: 'Ditolak',
          color: const Color(0xFFEF4444),
          bg: const Color(0xFFFFEDED),
          icon: Icons.cancel_rounded,
        );
      case 'submitted':
        return _StatusConfig(
          label: 'Menunggu Persetujuan',
          color: const Color(0xFF3B82F6),
          bg: const Color(0xFFEFF6FF),
          icon: Icons.hourglass_top_rounded,
        );
      case 'paid':
        return _StatusConfig(
          label: 'Terbayar',
          color: const Color(0xFF4CAF50),
          bg: const Color(0xFFE8F5E9),
          icon: Icons.payments_rounded,
        );
      default:
        return _StatusConfig(
          label: 'Belum Diisi',
          color: const Color(0xFF9CA3AF),
          bg: const Color(0xFFF3F4F6),
          icon: Icons.edit_outlined,
        );
    }
  }

  String? _getRoute(String code) {
    switch (code) {
      case 'APL.01':
        return AppPages.apl01;
      case 'APL.02':
        return AppPages.apl02;
      case 'AK.01':
        return AppPages.ak01;
      case 'AK.04':
        return AppPages.ak04;
      case 'AK.07':
        return AppPages.ak07;
      default:
        return null;
    }
  }

  // Izinkan navigasi selama belum disetujui final (bisa diisi/dilihat)
  bool _canNavigate(String status) =>
      status == 'draft' ||
      status == 'not_started' ||
      status == 'pending' ||
      status == 'rejected';

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(form.status);
    final route = _getRoute(form.code);
    final canNav = _canNavigate(form.status) && route != null;

    return GestureDetector(
      onTap: route != null && _canNavigate(form.status)
          ? () => Get.toNamed(
                route,
                arguments: {'registrationId': registrationId},
              )
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(form.code,
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4CAF50))),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(form.label,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF374151))),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: config.bg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(config.icon, size: 11, color: config.color),
                  const SizedBox(width: 4),
                  Text(config.label,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: config.color)),
                ],
              ),
            ),
            if (canNav) ...[
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 10, color: Color(0xFF9CA3AF)),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusConfig {
  final String label;
  final Color color;
  final Color bg;
  final IconData icon;

  _StatusConfig({
    required this.label,
    required this.color,
    required this.bg,
    required this.icon,
  });
}

// ─── Nav Item ──────────────────────────────────────────────────────────────────
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
        child: Icon(
          icon,
          color: isActive ? Colors.white : Colors.white70,
        ),
      ),
    );
  }
}