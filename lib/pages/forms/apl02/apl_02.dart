import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lsp_mkc_app/pages/forms/apl02/apl02_controller.dart';
import 'package:lsp_mkc_app/pages/forms/apl02/model/element.dart' as model;
import 'package:lsp_mkc_app/pages/forms/apl02/model/unit.dart';

class Apl02Page extends GetView<Apl02Controller> {
  final int registrationId;

  const Apl02Page({super.key, required this.registrationId});

  @override
  Widget build(BuildContext context) {
    // Fetch data saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchRegistrationInfo(registrationId);
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A3557),
        foregroundColor: Colors.white,
        title: const Text(
          'APL 02 - Asesmen Mandiri',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF1A3557)),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return _buildError(controller.errorMessage.value);
        }

        final data = controller.registrationData.value;
        if (data == null) {
          return const Center(child: Text('Tidak ada data'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header skema ---
              _buildSchemeHeader(
                code: data.scheme.code,
                name: data.scheme.name,
                asesiType: data.asesiType.name,
              ),
              const SizedBox(height: 16),

              // --- Instruksi ---
              _buildInstructionCard(),
              const SizedBox(height: 16),

              // --- Daftar unit kompetensi ---
              ...data.scheme.units.asMap().entries.map(
                (entry) => _buildUnitCard(
                  unitIndex: entry.key + 1,
                  unit: entry.value,
                ),
              ),

              const SizedBox(height: 24),

              // --- Tombol submit ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: implement submit
                    Get.snackbar(
                      'Info',
                      'Fitur submit akan segera tersedia',
                      backgroundColor: const Color(0xFF1A3557),
                      colorText: Colors.white,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A3557),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Kirim Asesmen Mandiri',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  // ─── Widget helper ───────────────────────────────────────────────

  Widget _buildSchemeHeader({
    required String code,
    required String name,
    required String asesiType,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A3557), Color(0xFF2E6DA4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  asesiType.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            code,
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        border: Border.all(color: const Color(0xFFFFCC02), width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Color(0xFFF59E0B), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Panduan Asesmen Mandiri',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Color(0xFF92400E),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Baca setiap elemen dan KUK dengan cermat. '
                  'Centang K (Kompeten) jika Anda yakin mampu, '
                  'atau BK (Belum Kompeten) jika belum.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF78350F)),
                  // height: 1.5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitCard({required int unitIndex, required Unit unit}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Unit header
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: Color(0xFFEEF4FF),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1A3557),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$unitIndex',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        unit.unitTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: Color(0xFF1A3557),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        unit.unitCode,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Elemen & KUK
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: unit.elements.asMap().entries.map((entry) {
                return _buildElementSection(
                  elementIndex: entry.key + 1,
                  element: entry.value,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElementSection({
    required int elementIndex,
    required model.Element element,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Judul elemen
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: Text(
            element.title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Color(0xFF334155),
            ),
          ),
        ),

        // Header tabel K/BK
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: const [
              Expanded(
                child: Text(
                  'Kriteria Unjuk Kerja',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
              SizedBox(width: 8),
              SizedBox(
                width: 32,
                child: Text(
                  'K',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    color: Color(0xFF16A34A),
                  ),
                ),
              ),
              SizedBox(width: 4),
              SizedBox(
                width: 32,
                child: Text(
                  'BK',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    color: Color(0xFFDC2626),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),

        // Daftar KUK
        ...element.criteria.map(
          (criterion) => _buildCriterionRow(criterion: criterion),
        ),

        const SizedBox(height: 12),
        const Divider(height: 1, color: Color(0xFFE2E8F0)),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildCriterionRow({required criterion}) {
    // Local state untuk K/BK per criterion — pakai RxnBool
    final selected = Rxn<bool>(); // true = K, false = BK, null = belum pilih

    return Obx(() {
      return Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected.value == true
              ? const Color(0xFFF0FDF4)
              : selected.value == false
                  ? const Color(0xFFFEF2F2)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected.value == true
                ? const Color(0xFF86EFAC)
                : selected.value == false
                    ? const Color(0xFFFCA5A5)
                    : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                criterion.name,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF334155),
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Tombol K
            GestureDetector(
              onTap: () => selected.value = true,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: selected.value == true
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Text(
                  'K',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: selected.value == true
                        ? Colors.white
                        : const Color(0xFF94A3B8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            // Tombol BK
            GestureDetector(
              onTap: () => selected.value = false,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: selected.value == false
                      ? const Color(0xFFDC2626)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Text(
                  'BK',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: selected.value == false
                        ? Colors.white
                        : const Color(0xFF94A3B8),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Color(0xFFDC2626)),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  controller.fetchRegistrationInfo(registrationId),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A3557),
              ),
              child: const Text(
                'Coba Lagi',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}