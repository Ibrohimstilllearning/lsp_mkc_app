import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FormAk04Controller extends GetxController {
  // ── Info ────────────────────────────────────────────────────────────────
  final namaAsesi = TextEditingController();
  final namaAsesor = TextEditingController();
  final tanggalAsesmen = TextEditingController();

  // ── Ya/Tidak ─────────────────────────────────────────────────────────────
  // null = belum pilih, true = YA, false = TIDAK
  final jawabanProsesBanding = Rx<bool?>(null);
  final jawabanDiskusiBanding = Rx<bool?>(null);
  final jawabanMelibatkanOrang = Rx<bool?>(null);

  // ── Skema ────────────────────────────────────────────────────────────────
  final skemaSertifikasi = TextEditingController();
  final noSkemaSertifikasi = TextEditingController();

  // ── Alasan ───────────────────────────────────────────────────────────────
  final alasanBanding = TextEditingController();

  // ── Tanda Tangan ─────────────────────────────────────────────────────────
  final tanggalTtd = TextEditingController();
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
    namaAsesi.dispose();
    namaAsesor.dispose();
    tanggalAsesmen.dispose();
    skemaSertifikasi.dispose();
    noSkemaSertifikasi.dispose();
    alasanBanding.dispose();
    tanggalTtd.dispose();
    super.onClose();
  }
}