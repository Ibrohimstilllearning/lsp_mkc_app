/// Data statis portfolio yang dibutuhkan per skema LSP MKC.
/// Sumber: "PORTOFOLIO SKEMA MKC.docx" (dokumen resmi).
///
/// Digunakan sebagai fallback client-side ketika endpoint
/// GET /schemes/{id}/portfolios & GET /document-lists?scheme_id={id}
/// belum mengembalikan data terfilter dengan benar.
///
/// Key: substring nama skema (case-insensitive match)
/// Value: daftar nama dokumen portfolio yang dibutuhkan
class SchemeDocumentsFallback {
  SchemeDocumentsFallback._();

  /// Cocokkan [schemeName] ke daftar dokumen yang dibutuhkan.
  /// Mengembalikan list kosong jika tidak ada yang cocok.
  static List<String> getRequiredDocs(String schemeName) {
    final name = schemeName.toLowerCase();
    for (final entry in _data.entries) {
      if (name.contains(entry.key)) return entry.value;
    }
    return [];
  }

  /// Cek apakah [docTitle] termasuk dalam dokumen wajib skema [schemeName].
  static bool isRequired(String schemeName, String docTitle) {
    final required = getRequiredDocs(schemeName);
    if (required.isEmpty) return true; // jika tidak ada data, anggap semua wajib
    final t = docTitle.toLowerCase();
    return required.any((r) =>
        t.contains(r.toLowerCase()) || r.toLowerCase().contains(t));
  }

  static const Map<String, List<String>> _data = {
    // ── 1. Tenaga Administrasi Kewirausahaan ─────────────────────────────
    'administrasi kewirausahaan': [
      'Laporan analisis HPP',
      'RAB usaha',
      'Dokumen Perizinan usaha',
      'Buku kas masuk & keluar',
      'SOP penyimpanan bahan & produk',
      'Jadwal kerja mingguan/bulanan',
      'Buku agenda surat masuk dan keluar',
      'Rekap keluhan pelanggan',
      'Rekap transaksi bank',
      'Sertifikat pelatihan berbasis Kompetensi Tenaga Administrasi Kewirausahaan',
      'Surat Pengalaman Kerja Minimal 2 Tahun di bidang Tenaga Administrasi',
    ],

    // ── 2. Tenaga Pelayanan Prima ────────────────────────────────────────
    'pelayanan prima': [
      'Materi promosi (brosur, flyer, katalog, konten promosi media sosial)',
      'Program customer relationship',
      'SOP komunikasi pelanggan',
      'SOP pelayanan via telepon',
      'SOP pelayanan pelanggan',
      'Rekap keluhan pelanggan',
      'Product knowledge sheet',
      'Sertifikat pelatihan berbasis Kompetensi Tenaga Pelayanan Prima',
      'Surat Pengalaman Kerja Minimal 2 Tahun di bidang Tenaga Pelayanan Prima',
    ],

    // ── 3. Tenaga Penjualan Online ───────────────────────────────────────
    'penjualan online': [
      'Konten promosi media sosial',
      'Laporan Analisis STP (Segmentasi, Targeting, Positioning)',
      'SOP komunikasi online',
      'Akun bisnis media sosial',
      'Insight media sosial',
      'Kalender konten',
      'Jadwal posting',
      'Alur pelayanan pelanggan online',
      'Template jawaban pelanggan',
      'Dokumentasi pencarian informasi produk',
      'Kuesioner survey online',
      'Sertifikat pelatihan berbasis Kompetensi Tenaga Penjualan Online',
      'Surat Pengalaman Kerja Minimal 1 Tahun di bidang Tenaga Penjualan Online',
    ],

    // ── 4. Pendamping Kelembagaan Usaha ──────────────────────────────────
    'kelembagaan': [
      'Contoh komunikasi profesional (email/surat)',
      'Minutes of Meeting (MoM) atau notulen rapat',
      'Laporan monitoring produksi',
      'Analisis kebutuhan tenaga kerja',
      'SOP operasional usaha/Instruksi kerja (Work Instruction)',
      'Format kontrak kerja',
      'Rencana anggaran investasi',
      'Dokumen Perizinan usaha',
      'Laporan kegiatan pendampingan',
      'Sertifikat pelatihan berbasis Kompetensi Pendamping Kelembagaan Usaha',
      'Surat Pengalaman Kerja Minimal 2 Tahun di bidang Pendamping Kelembagaan Usaha',
    ],

    // ── 5. Motivator Kinerja Tim Penjualan ──────────────────────────────
    'motivator': [
      'Dokumentasi rapat/briefing',
      'Program pengembangan tim sales',
      'Laporan Program coaching & mentoring',
      'Program manajemen stres kerja',
      'Program transformasi layanan pelanggan',
      'Sertifikat pelatihan berbasis Kompetensi Motivator Kinerja Tim Penjualan',
      'Surat Pengalaman Kerja Minimal 3 Tahun sebagai Manajer Pengembangan Bisnis',
    ],

    // ── 6. Pendamping Kewirausahaan ──────────────────────────────────────
    'pendamping kewirausahaan': [
      'Dokumen Perizinan usaha',
      'Company profile tenant',
      'Dokumen rencana usaha tenant',
      'RAB usaha',
      'Analisis peluang usaha',
      'Analisis kebutuhan SDM',
      'Portofolio produk',
      'Dokumen Hak Kekayaan Intelektual (HKI)',
      'Dokumentasi sesi mentoring',
      'Program pengembangan tim tenant',
      'Sertifikat pelatihan berbasis Kompetensi Pendamping Kewirausahaan',
      'Surat Pengalaman Kerja Minimal 2 Tahun sebagai Pendamping Kewirausahaan',
    ],

    // ── 7. Petugas Promosi Penjualan ─────────────────────────────────────
    'promosi penjualan': [
      'Laporan kinerja penjualan',
      'Product knowledge sheet',
      'Form evaluasi penjualan',
      'Laporan inovasi promosi',
      'Materi promosi (poster, brosur, digital)',
      'Rekap keluhan pelanggan',
      'Sales activity plan (harian/mingguan)',
      'Sertifikat pelatihan berbasis Kompetensi Petugas Promosi Penjualan',
      'Surat Pengalaman Kerja Minimal 2 Tahun di bidang Petugas Promosi Penjualan',
    ],

    // ── 8. Staf Hubungan Masyarakat ──────────────────────────────────────
    'hubungan masyarakat': [
      'Notulen rapat internal/eksternal',
      'Laporan Analisis STP (Segmentasi, Targeting, Positioning)',
      'Akun media sosial perusahaan',
      'Dokumen business writing (Press release/Surat resmi organisasi/Artikel perusahaan/Proposal kegiatan)',
      'Laporan kegiatan PR',
      'Dokumentasi pelaksanaan event',
      'Desain konten digital',
      'Sertifikat pelatihan berbasis Kompetensi Staf Hubungan Masyarakat',
      'Surat Pengalaman Kerja Minimal 2 Tahun di bidang Staf Hubungan Masyarakat',
    ],

    // ── 9. Manajer Pengembangan Bisnis ───────────────────────────────────
    'pengembangan bisnis': [
      'Laporan analisis lingkungan bisnis',
      'Laporan implementasi strategi',
      'SOP layanan',
      'Analisis STP (Segmentasi, Targeting, Positioning)',
      'Dokumen rencana pemasaran organisasi',
      'Laporan program loyalitas',
      'Sertifikat pelatihan berbasis Kompetensi Manajer Pengembangan Bisnis',
      'Sertifikat kompetensi Staf Hubungan Masyarakat',
      'Surat Pengalaman Kerja Minimal 2 Tahun sebagai Manajer Pengembangan Bisnis',
    ],

    // ── 10. Jenjang IV Bidang Kewirausahaan Industri ─────────────────────
    'kewirausahaan industri': [
      'Instrumen kuesioner survey pasar',
      'Flowchart proses produksi',
      'Data bahan baku dan bahan pembantu',
      'Analisis perhitungan HPP',
      'Laporan keputusan produk',
      'Data Mesin dan Peralatan Produksi',
      'Dokumen Rencana pembelian bahan baku dan bahan pembantu',
      'SOP penyimpanan bahan & produk',
      'Form pemeriksaan barang masuk (QC checklist)',
      'Materi promosi (poster/katalog)',
      'Data survey pedagang eceran',
      'Laporan hasil pemasaran',
      'Sertifikat pelatihan berbasis Kompetensi Jenjang IV Bidang Kewirausahaan Industri',
      'Surat Pengalaman Kerja Minimal 3 Tahun di bidang Kewirausahaan Industri',
    ],
  };
}
