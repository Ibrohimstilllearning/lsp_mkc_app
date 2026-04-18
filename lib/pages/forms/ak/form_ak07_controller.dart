import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ── Model untuk item Bagian A ─────────────────────────────────────────────────
class BagianAItem {
  final String no;
  final String mengidentifikasi;
  final List<String> keteranganOptions;
  final RxnBool diperlukan = RxnBool(null); // null=belum, true=Ya, false=Tidak
  final RxList<bool> keteranganChecked;

  BagianAItem({
    required this.no,
    required this.mengidentifikasi,
    required this.keteranganOptions,
  }) : keteranganChecked =
            RxList<bool>(List.filled(keteranganOptions.length, false));
}

// ── Model untuk item Bagian B ─────────────────────────────────────────────────
class BagianBItem {
  final String pertanyaan;
  final RxnBool jawaban = RxnBool(null);
  final TextEditingController keputusan = TextEditingController();

  BagianBItem({required this.pertanyaan});
}

class FormAk07Controller extends GetxController {
  // ── Info Umum ─────────────────────────────────────────────────────────────
  final tukSelected = ''.obs;
  final namaAsesor = TextEditingController();
  final namaAsesi = TextEditingController();
  final tanggal = TextEditingController();

  // ── Potensi Asesi (multi-select) ──────────────────────────────────────────
  final potensiList = <String>[
    'Hasil pelatihan dan/atau pendidikan, dimana Kurikulum dan fasilitaspraktek mampu telusur terhadap standar kompetensi',
    'Hasil pelatihan dan/atau pendidikan, dimana kurikulum belum berbasiskompetensi.',
    'Pekerja berpengalaman, dimana berasal dari industri/tempat kerja yang dalam operasionalnya mampu telusur dengan standar kompetensi',
    'Pekerja berpengalaman, dimana berasal dari industri/tempat kerja yangdalam operasionalnya belum berbasis kompetensi.',
    'Pelatihan / belajar mandiri atau otodidak.',
  ];
  final potensiChecked = RxList<bool>([false, false, false, false, false]);

  // ── Bagian A ──────────────────────────────────────────────────────────────
  final bagianAItems = <BagianAItem>[
    BagianAItem(
      no: '1',
      mengidentifikasi:
          'Keterbatasan asesi terhadap persyaratan bahasa, literasi, numerasi.',
      keteranganOptions: [
        'Memerlukan dukungan pembaca, penerjemah, pelayan, penulis untuk merekam jawaban asesi.',
        'Melakukan asesmen verbal (gunakan pertanyaan lisan/pertanyaan wawancara) dilengkapi gambar diagram dan bentuk-bentuk visual.',
        'Menggunakan Hasil produksi',
        'Menggunakan Ceklis observasi/demonstrasi.',
        'Menggunakan daftar instruksi terstruktur.',
      ],
    ),
    BagianAItem(
      no: '2',
      mengidentifikasi:
          'Penyediaan dukungan pembaca, penerjemah, pelayan, penulis.',
      keteranganOptions: [
        'Menggunakan pertanyaan lisan dengan dilengkapi gambar diagram dan bentuk-bentuk visual.',
        'Menggunakan pertanyaan wawancara dengan dilengkapi gambar diagram dan bentuk-bentuk visual.',
      ],
    ),
    BagianAItem(
      no: '3',
      mengidentifikasi:
          'Penggunaan teknologi adaptif atau peralatan khusus. (Tidak dapat menggunakan teknologi adaptif (misal: mengoperasikan komputer dan printer, peralatan digital dsb).',
      keteranganOptions: [
        'Ceklis observasi/demonstrasi Demonstrasi.',
        'Pertanyaan lisan',
        'Pertanyaan tertulis.',
        'Pertanyaan wawancara.',
        'Daftar instruksi terstruktur.',
        'Ceklis verifikasi portofolio.',
        'Menggunakan dukungan operator komputer.',
      ],
    ),
    BagianAItem(
      no: '4',
      mengidentifikasi:
          'Pelaksanaan asesmen secara fleksibel karena alasan keletihan atau keperluan pengobatan.',
      keteranganOptions: [
        'Menggunakan juru tulis.',
        'Menggunakan kamaramen perekam vidio/ataudio.',
        'Memperbolehkan periode waktu yang lebih panjang untuk menyelesaikan tugas pekerjaan dalam asesmen.',
        'Melakukan tugas pekerjaan dalam asesmen dengan waktu lebih pendek.',
        'Menggunakan instruksi-instruksi spesifik pada proyek yang dapat dilakukan pada berbagai tingkatan.',
      ],
    ),
    BagianAItem(
      no: '5',
      mengidentifikasi:
          'Penyediaan peralatan asesmen berupa braille, audio/video-tape.',
      keteranganOptions: [
        'Menggunakan pertanyaan lisan.',
        'Menggunakan pertanyaan wawancara.',
      ],
    ),
    BagianAItem(
      no: '6',
      mengidentifikasi: 'Penyesuaian tempat fisik/lingkungan asesmen',
      keteranganOptions: [
        'Pertanyaan lisan.',
        'Pertanyaan tulis.',
        'Pertanyaan wawancara.',
        'Ceklis Verifikasi portofolio.',
        'Ceklis reviu produk.',
        'Daftar instruksi terstruktur.',
      ],
    ),
    BagianAItem(
      no: '7',
      mengidentifikasi:
          'Pertimbangan umur/usia lanjut/gender asesi. (Adanya perbedaan usia dengan asesor yang lebih muda).',
      keteranganOptions: [
        'Menggunakan studi kasus/daftar instruksi terstruktur',
        'Menggunakan instrumen asesmen dengan huruf normal jangan terlalu kecil.',
        'Menggunakan asesor dengan jenis kelamin yang sama dengan asesi.',
        'Menggunakan instrumen asesmen yang sama walaupun berbeda jenis kelamin (tidak boleh memberi tanda tambahan pada instrumen asesmen yang digunakan dengan tujuan untuk membedakan jenis kelamin).',
      ],
    ),
    BagianAItem(
      no: '8',
      mengidentifikasi: 'Pertimbangan budaya/tradisi/agama.',
      keteranganOptions: [
        'Menggunakan studi kasus daftar instruksi terstruktur',
        'Menggunakan asesor tanpa pertimbangan budaya/tradisi/agama.',
        'Menggunakan instrumen asesmen yang sama walaupun berbeda budaya/tradisi/agama).',
      ],
    ),
  ];

  // ── Bagian B ──────────────────────────────────────────────────────────────
  final bagianBItems = <BagianBItem>[
    BagianBItem(
      pertanyaan:
          'Apakah rekaman rencana asesmen tervalidasi dibuat menggunakan acuan pembanding, minimal standar kompetensi kerja?',
    ),
    BagianBItem(
      pertanyaan:
          'Apakah rekaman rencana asesmen tervalidasi sudah sesuai dengan potensi asesi yang akan diujikan?',
    ),
    BagianBItem(
      pertanyaan:
          'Apakah rekaman rencana asesmen tervalidasi sudah sesuai dengan konteks asesi (berdasarkan rekaman APL.01 tervalidasi LSP dan rekaman APL.02 tervalidasi asesi)?',
    ),
  ];

  // ── Hasil Penyesuaian ─────────────────────────────────────────────────────
  // Bagian A
  final acuanPembandingA = TextEditingController();
  final metodeAsesmen_A = TextEditingController();
  final instrumenAsesmen_A = TextEditingController();
  // Bagian B
  final acuanPembandingB = TextEditingController();
  final metodeAsesmen_B = TextEditingController();
  final instrumenAsesmen_B = TextEditingController();

  // ── Tanda Tangan ──────────────────────────────────────────────────────────
  final tanggalAsesor = TextEditingController();
  final tanggalAsesi = TextEditingController();
  final ttdAsesorBytes = Rx<Uint8List?>(null);
  final ttdAsesiBytes = Rx<Uint8List?>(null);

  // ── Loading ───────────────────────────────────────────────────────────────
  final isLoading = false.obs;

  Future<bool> submit() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 600));
    isLoading.value = false;
    return true;
  }

  @override
  void onClose() {
    namaAsesor.dispose();
    namaAsesi.dispose();
    tanggal.dispose();
    for (final item in bagianBItems) {
      item.keputusan.dispose();
    }
    acuanPembandingA.dispose();
    metodeAsesmen_A.dispose();
    instrumenAsesmen_A.dispose();
    acuanPembandingB.dispose();
    metodeAsesmen_B.dispose();
    instrumenAsesmen_B.dispose();
    tanggalAsesor.dispose();
    tanggalAsesi.dispose();
    super.onClose();
  }
}