import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lsp_mkc_app/pages/forms/apl/form_apl01_controller.dart';
import 'form_apl01pt2.dart';

class FormApl01 extends StatelessWidget {
  final FormApl01Controller c = Get.find<FormApl01Controller>();

  // ─── Full-width input ─────────────────────────────────────────────────────
  Widget _buildField({
    required String label,
    required TextEditingController controller,
    TextInputType type = TextInputType.text,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: type,
            style: const TextStyle(fontSize: 14, color: Color(0xFF111827)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 13,
                color: Color(0xFFD1D5DB),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFF4CAF50),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Compact inline input (untuk 2-kolom) ────────────────────────────────
  Widget _inlineField(
    String label,
    TextEditingController controller, {
    TextInputType type = TextInputType.text,
    String? hint,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFF9CA3AF),
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: type,
          readOnly: readOnly,
          onTap: onTap,
          style: const TextStyle(fontSize: 13, color: Color(0xFF111827)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 12, color: Color(0xFFD1D5DB)),
            suffixIcon: suffix,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFF4CAF50),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Section header ───────────────────────────────────────────────────────
  Widget _sectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: const Color(0xFF4CAF50)),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Card ─────────────────────────────────────────────────────────────────
  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
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
      child: child,
    );
  }

  // ─── Step dot & line ─────────────────────────────────────────────────────
  Widget _stepDot(int num, {bool active = false}) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF4CAF50) : const Color(0xFFE5E7EB),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$num',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: active ? Colors.white : const Color(0xFF9CA3AF),
          ),
        ),
      ),
    );
  }

  Widget _stepLine({bool active = false}) {
    return Expanded(
      child: Container(
        height: 3,
        decoration: BoxDecoration(
          color: active ? const Color(0xFF4CAF50) : const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  // ─── Gender chip ──────────────────────────────────────────────────────────
  Widget _genderChip(String value, String label, IconData icon, bool selected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => c.jenisKelamin.value = value,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFE8F5E9) : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFFE5E7EB),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFF9CA3AF),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Asesi Type chip ──────────────────────────────────────────────────────
  Widget _asesiChip(String value, String label) {
    return Obx(() {
      final selected = c.asesiType.value == value;
      return GestureDetector(
        onTap: () => c.asesiType.value = value,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFE8F5E9) : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFFE5E7EB),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFF6B7280),
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF111827),
            size: 18,
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'FR.APL.01',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE5E7EB)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── Progress ────────────────────────────────────────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _stepDot(1, active: true),
                      _stepLine(active: true),
                      _stepDot(2),
                      _stepLine(),
                      _stepDot(3),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Bagian 1 dari 3',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Rincian Data Pemohon Sertifikasi',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Cantumkan data pribadi, pendidikan formal, dan data pekerjaan Anda saat ini.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // ── Data Pribadi ─────────────────────────────────────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader('Data Pribadi', Icons.person_outline_rounded),

                  _buildField(
                    label: 'Nama Lengkap',
                    controller: c.namaController,
                    hint: 'Sesuai KTP',
                  ),

                  // Tempat & Tanggal Lahir — 2 kolom
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _inlineField(
                            'Tempat Lahir',
                            c.tempatLahirController,
                            hint: 'Jakarta',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _inlineField(
                            'Tanggal Lahir',
                            c.tanggalLahirController,
                            hint: 'YYYY-MM-DD',
                            readOnly: true,
                            suffix: const Icon(
                              Icons.calendar_today_rounded,
                              size: 14,
                              color: Color(0xFF9CA3AF),
                            ),
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime(1990),
                                firstDate: DateTime(1940),
                                lastDate: DateTime.now(),
                                builder: (ctx, child) => Theme(
                                  data: Theme.of(ctx).copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: Color(0xFF4CAF50),
                                      onPrimary: Colors.white,
                                    ),
                                  ),
                                  child: child!,
                                ),
                              );
                              if (picked != null) {
                                c.tanggalLahirController.text =
                                    '${picked.year}-'
                                    '${picked.month.toString().padLeft(2, '0')}-'
                                    '${picked.day.toString().padLeft(2, '0')}';
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Jenis Kelamin
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Jenis Kelamin',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Obx(
                          () => Row(
                            children: [
                              _genderChip(
                                'male',
                                'Laki-laki',
                                Icons.male_rounded,
                                c.jenisKelamin.value == 'male',
                              ),
                              const SizedBox(width: 10),
                              _genderChip(
                                'female',
                                'Wanita',
                                Icons.female_rounded,
                                c.jenisKelamin.value == 'female',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tipe Asesi
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tipe Asesi',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _asesiChip('pribadi', 'Pribadi'),
                            const SizedBox(width: 8),
                            _asesiChip('instansi', 'Instansi'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  _buildField(
                    label: 'Alamat Rumah',
                    controller: c.alamatController,
                    hint: 'Jalan, RT/RW, Kelurahan, Kecamatan',
                  ),

                  _buildField(
                    label: 'Kode Pos',
                    controller: c.kodePosController,
                    type: TextInputType.number,
                    hint: '12345',
                  ),

                  _buildField(
                    label: 'Nomor HP',
                    controller: c.noHpController,
                    type: TextInputType.phone,
                    hint: '08xxxxxxxxxx',
                  ),

                  _buildField(
                    label: 'Kualifikasi Pendidikan',
                    controller: c.pendidikanController,
                    hint: 'SMA / D3 / S1 / dll',
                  ),
                ],
              ),
            ),

            // ── Data Pekerjaan ───────────────────────────────────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(
                    'Data Pekerjaan Sekarang',
                    Icons.business_center_outlined,
                  ),

                  _buildField(
                    label: 'Nama Institusi / Perusahaan',
                    controller: c.institusiController,
                    hint: 'PT. / CV. / Instansi',
                  ),

                  _buildField(
                    label: 'Jabatan',
                    controller: c.jabatanController,
                    hint: 'Staff / Manager / dll',
                  ),

                  _buildField(
                    label: 'Alamat Kantor',
                    controller: c.alamatKantorController,
                    hint: 'Jalan, Gedung, Kota',
                  ),

                  // Kode pos & kontak — 2 kolom
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _inlineField(
                          'Kode Pos',
                          c.kodePosKantorController,
                          type: TextInputType.number,
                          hint: '12345',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _inlineField(
                          'No. Telp / Kontak',
                          c.noTelpController,
                          type: TextInputType.phone,
                          hint: '021-xxxxxxx',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Tombol Selanjutnya ───────────────────────────────────────
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: c.isLoadingBagian1.value
                      ? null
                      : () async {
                          final ok = await c.submitBagian1();
                          if (ok) Get.to(() => FormApl01Bagian2());
                        },
                  child: c.isLoadingBagian1.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Selanjutnya',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ],
                        ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
