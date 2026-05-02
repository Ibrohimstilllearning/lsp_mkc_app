import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lsp_mkc_app/pages/pengajuan_controller.dart';
import 'package:lsp_mkc_app/routes/app_pages.dart';

class PengajuanPage extends GetView<PengajuanController> {
  const PengajuanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pengajuan Saya',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Monitor status form yang kamu ajukan',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => controller.fetchPengajuan(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: const Icon(
                        Icons.refresh_rounded,
                        size: 18,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Body ────────────────────────────────────────────────
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return _SkeletonList();
                }
                if (controller.hasError.value) {
                  return _ErrorState(onRetry: controller.fetchPengajuan);
                }
                if (controller.pengajuanList.isEmpty) {
                  return const _EmptyState();
                }
                return const _PengajuanList();
              }),
            ),
          ],
        ),
      ),
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
            width: 200,
            height: 200,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada pengajuan',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Mulai proses sertifikasi dari halaman utama',
            style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
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
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 30,
                color: Color(0xFFEF4444),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Gagal memuat data',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Periksa koneksi dan coba lagi',
              style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              icon: const Icon(
                Icons.refresh_rounded,
                color: Colors.white,
                size: 16,
              ),
              label: const Text(
                'Coba Lagi',
                style: TextStyle(color: Colors.white),
              ),
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
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 11,
              width: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(
              3,
              (_) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Pengajuan List ───────────────────────────────────────────────────────────
class _PengajuanList extends StatelessWidget {
  const _PengajuanList();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PengajuanController>();
    return ListView.builder(
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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  child: const Icon(
                    Icons.workspace_premium_outlined,
                    size: 20,
                    color: Color(0xFF4CAF50),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.schemeName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.schemeCode,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Diajukan',
                      style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)),
                    ),
                    Text(
                      item.createdAt,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: item.forms
                  .map(
                    (form) => _FormRow(
                      form: form,
                      registrationId: item.registrationId,
                    ),
                  )
                  .toList(),
            ),
          ),
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
    switch (status.toLowerCase().trim()) {
      case 'approved':
        return _StatusConfig(
          label: 'Disetujui',
          color: const Color(0xFF4CAF50),
          bg: const Color(0xFFE8F5E9),
          icon: Icons.check_circle_rounded,
        );
      case 'pending':
      case 'menunggu':
        return _StatusConfig(
          label: 'Menunggu',
          color: const Color(0xFFF59E0B),
          bg: const Color(0xFFFFFBEB),
          icon: Icons.access_time_rounded,
        );
      case 'rejected':
      case 'ditolak':
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
      case 'draft':
        return _StatusConfig(
          label: 'Belum Diisi',
          color: const Color(0xFF9CA3AF),
          bg: const Color(0xFFF3F4F6),
          icon: Icons.edit_outlined,
        );
      default:
        return _StatusConfig(
          label: status.isNotEmpty ? status : 'Dalam Proses',
          color: const Color(0xFF6B7280),
          bg: const Color(0xFFF3F4F6),
          icon: Icons.info_outline_rounded,
        );
    }
  }

  String? _getRoute(String code) {
    switch (code) {
      case 'APL.01':
        return AppPages.apl01;
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

  bool _canNavigate(String status) {
    return status == 'draft';
  }

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(form.status);
    final route = _getRoute(form.code);
    final canNav = form.status == 'draft' && route != null;

    return GestureDetector(
      onTap: canNav
          ? () => Get.toNamed(
              route!,
              arguments: {'registrationId': registrationId},
            )
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                form.code,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4CAF50),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                form.label,
                style: const TextStyle(fontSize: 12, color: Color(0xFF374151)),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: config.bg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(config.icon, size: 11, color: config.color),
                  const SizedBox(width: 4),
                  Text(
                    config.label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: config.color,
                    ),
                  ),
                ],
              ),
            ),
            if (canNav) ...[
              const SizedBox(width: 6),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 10,
                color: Color(0xFF9CA3AF),
              ),
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
