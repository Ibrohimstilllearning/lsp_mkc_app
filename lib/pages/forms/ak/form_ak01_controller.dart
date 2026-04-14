import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lsp_mkc_app/utils/api_endpoints.dart';

class FormAk01Controller extends GetxController {
  // ── Info ──────────────────────────────────────────────────────────────────
  final tukSelected = ''.obs;
  final namaAsesi = TextEditingController();

  // ── Bukti yang dikumpulkan ────────────────────────────────────────────────
  final buktiVerifikasiPortofolio = false.obs;
  final buktiReviewProduk = false.obs;
  final buktiObservasiLangsung = false.obs;
  final buktiKegiatanTerstruktur = false.obs;
  final buktiTanyaJawab = false.obs;
  final buktiLainnya = false.obs;

  // Lainnya — list dinamis
  final lainnyaList = <TextEditingController>[].obs;

  // ── Pelaksanaan ───────────────────────────────────────────────────────────
  final tukPelaksanaan = TextEditingController();

  // ── Tanda Tangan ──────────────────────────────────────────────────────────
  final ttdAsesorBytes = Rx<Uint8List?>(null);
  final ttdAsesiBytes = Rx<Uint8List?>(null);

  // ── Loading & error ───────────────────────────────────────────────────────
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // ── Tambah / hapus item lainnya ───────────────────────────────────────────
  void addLainnya() {
    lainnyaList.add(TextEditingController());
  }

  void removeLainnya(int index) {
    lainnyaList[index].dispose();
    lainnyaList.removeAt(index);
  }

  // ── Submit ke API ─────────────────────────────────────────────────────────
  Future<bool> submit({required int registrationId}) async {
    // ── Validasi ─────────────────────────────────────────────────
    if (tukSelected.value.isEmpty) {
      Get.snackbar('Perhatian', 'TUK belum dipilih',
          backgroundColor: const Color(0xFFFFF3CD),
          colorText: const Color(0xFF856404),
          snackPosition: SnackPosition.TOP);
      return false;
    }
    if (namaAsesi.text.trim().isEmpty) {
      Get.snackbar('Perhatian', 'Nama Asesi belum diisi',
          backgroundColor: const Color(0xFFFFF3CD),
          colorText: const Color(0xFF856404),
          snackPosition: SnackPosition.TOP);
      return false;
    }
    if (ttdAsesiBytes.value == null) {
      Get.snackbar('Perhatian', 'Tanda tangan Asesi belum diisi',
          backgroundColor: const Color(0xFFFFF3CD),
          colorText: const Color(0xFF856404),
          snackPosition: SnackPosition.TOP);
      return false;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      // ── Ambil token ──────────────────────────────────────────────
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      if (token.isEmpty) {
        Get.snackbar('Sesi Habis', 'Silakan login ulang',
            backgroundColor: const Color(0xFFFFEDED),
            colorText: const Color(0xFF991B1B),
            snackPosition: SnackPosition.BOTTOM);
        return false;
      }

      // ── Auto fill tanggal & waktu ────────────────────────────────
      final now = DateTime.now();
      final dateStr = DateFormat('yyyy-MM-dd').format(now);
      final timeStr = DateFormat('HH:mm').format(now);

      // ── Encode TTD ───────────────────────────────────────────────
      String asesorSignatureB64 = '';
      if (ttdAsesorBytes.value != null) {
        asesorSignatureB64 =
            'data:image/png;base64,${base64Encode(ttdAsesorBytes.value!)}';
      }
      final asesiSignatureB64 =
          'data:image/png;base64,${base64Encode(ttdAsesiBytes.value!)}';

      // ── Evidence methods ─────────────────────────────────────────
      final List<Map<String, dynamic>> evidenceMethods = [
        {
          'label': 'Hasil Verifikasi Portofolio',
          'answer': buktiVerifikasiPortofolio.value,
        },
        {
          'label': 'Hasil Reviu Produk',
          'answer': buktiReviewProduk.value,
        },
        {
          'label': 'Hasil Observasi Langsung',
          'answer': buktiObservasiLangsung.value,
        },
        {
          'label': 'Hasil Kegiatan Terstruktur',
          'answer': buktiKegiatanTerstruktur.value,
        },
        {
          'label': 'Hasil Tanya Jawab',
          'answer': buktiTanyaJawab.value,
        },
        {
          'label': 'Lainnya',
          'answer': buktiLainnya.value,
          if (buktiLainnya.value && lainnyaList.isNotEmpty)
            'items': lainnyaList
                .map((c) => c.text.trim())
                .where((t) => t.isNotEmpty)
                .toList(),
        },
      ];

      // ── Payload ──────────────────────────────────────────────────
      final payload = {
        'ak01_data': {
          'certification_scheme': {
            'name': 'AHLI DESAIN GRAFIS',
            'code': 'SUK-SKS-REV1-L007',
          },
          'tuk': tukSelected.value,
          'asesor_name': '',
          'asesi_name': namaAsesi.text.trim(),
          'evidence_methods': evidenceMethods,
          'agreement_time': {
            'date': dateStr,
            'time': timeStr,
            'tuk': tukPelaksanaan.text.trim(),
          },
          'signatures': {
            'asesor': {
              'name': '',
              'date': dateStr,
              'signature': asesorSignatureB64,
            },
            'asesi': {
              'name': namaAsesi.text.trim(),
              'date': dateStr,
              'signature': asesiSignatureB64,
            },
          },
        }
      };

      // ── HTTP ─────────────────────────────────────────────────────
      final url = Uri.parse(
          '${ApiEndpoints.baseUrl}/api/registrations/$registrationId/ak01');

      debugPrint('[AK01] URL    : $url');
      debugPrint('[AK01] Body   : ${jsonEncode(payload)}');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      debugPrint('[AK01] Status : ${response.statusCode}');
      debugPrint('[AK01] Body   : ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        final body = jsonDecode(response.body);
        errorMessage.value =
            body['message'] ?? 'Terjadi kesalahan, coba lagi.';
        Get.snackbar('Gagal', errorMessage.value,
            backgroundColor: const Color(0xFFFFEDED),
            colorText: const Color(0xFF991B1B),
            snackPosition: SnackPosition.BOTTOM);
        return false;
      }
    } catch (e) {
      debugPrint('[AK01] Error: $e');
      errorMessage.value = 'Koneksi bermasalah, coba lagi.';
      Get.snackbar('Error', errorMessage.value,
          backgroundColor: const Color(0xFFFFEDED),
          colorText: const Color(0xFF991B1B),
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    namaAsesi.dispose();
    tukPelaksanaan.dispose();
    for (final c in lainnyaList) {
      c.dispose();
    }
    super.onClose();
  }
}