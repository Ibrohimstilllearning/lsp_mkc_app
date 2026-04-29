import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lsp_mkc_app/pages/forms/apl02/data/scheme_documents_fallback.dart';
import 'package:lsp_mkc_app/pages/forms/apl02/model/document_list.dart';
import 'package:lsp_mkc_app/pages/forms/apl02/model/required_document.dart';
import 'package:lsp_mkc_app/pages/forms/apl02/model/response.dart';
import 'package:lsp_mkc_app/pages/forms/apl02/model/submit.dart';
import 'package:lsp_mkc_app/pages/forms/apl02/providers/response_provider.dart';
import 'package:lsp_mkc_app/pages/pengajuan_controller.dart';
import 'package:lsp_mkc_app/routes/app_pages.dart';

class Apl02Controller extends GetxController {
  final ResponseProvider _provider = ResponseProvider();

  // state
  var isLoading = false.obs;
  var isSubmitting = false.obs;
  var apl02Data = Rxn<ResponseRegistration>();
  var userAnswer = <int, bool>{}.obs;

  // Simpan error terakhir untuk ditampilkan di UI
  var lastError = ''.obs;

  // Missing files from E2013 error
  var missingFiles = <String>[].obs;

  // ── Semua dokumen yang dibutuhkan skema (merged dengan yang sudah upload)
  var requiredDocuments = <RequiredDocument>[].obs;
  var isLoadingDocs = false.obs;

  // Sumber data dokumen portfolio:
  // 1 = /schemes/{id}/portfolios (API utama)
  // 2 = /document-lists?scheme_id (API fallback, terfilter)
  // 3 = static fallback (offline)
  // 4 = APL02 portfolios only
  var portfolioDataSource = 0.obs;

  // Track which portfolio docs are being uploaded (by listId)
  var uploadingListIds = <int>{}.obs;

  // Track if competency dialog has been shown
  var competencyDialogShown = false.obs;

  void fetchData(int registrationId) async {
    isLoading.value = true;
    lastError.value = '';
    print('[APL02 Controller] Fetching registrationId=$registrationId');

    final result = await _provider.getDatabyId(registrationId);
    if (result.data != null) {
      apl02Data.value = result.data;
      userAnswer.clear();
      missingFiles.clear();
      competencyDialogShown.value = false;

      // Setelah data APL02 berhasil, fetch semua dokumen yang dibutuhkan skema
      await _fetchAndMergeDocuments(result.data!);
    } else {
      final msg = result.errorMessage ?? 'Unknown error';
      lastError.value = msg;
      Get.snackbar(
        'Error',
        msg,
        duration: const Duration(seconds: 5),
      );
    }
    isLoading.value = false;
  }

  /// Refresh hanya daftar dokumen portfolio (lebih ringan dari fetchData penuh).
  /// Dipanggil setelah upload berhasil agar status upload terupdate.
  Future<void> refreshDocuments() async {
    if (apl02Data.value == null) return;
    
    // Re-fetch APL02 data to get the latest portfolios from this registration
    final regId = apl02Data.value!.registrationId;
    final freshData = await _provider.getDatabyId(regId);
    if (freshData.data != null) {
      apl02Data.value = freshData.data;
    }
    
    await _fetchAndMergeDocuments(apl02Data.value!);
  }

  /// Fetch & merge dokumen yang dibutuhkan skema + status upload user.
  Future<void> _fetchAndMergeDocuments(ResponseRegistration data) async {
    isLoadingDocs.value = true;
    final schemeId = data.scheme.id;

    // ── Layer 1: GET /schemes/{id}/portfolios (sumber utama) ───────────────
    final schemePortfolios = await _provider.fetchSchemePortfolios(schemeId);

    if (schemePortfolios.isNotEmpty) {
      final profiles = await _provider.fetchUserDocumentProfiles();
      final Map<int, DocumentProfile> profileMap = {};
      for (var p in profiles) {
        profileMap[p.documentListId] = p;
      }

      requiredDocuments.value = schemePortfolios.map((sp) {
        // Cari portfolio APL02 yang matching sebagai referensi dari registrasi
        final portfolioMatch = data.portfolios
            .firstWhereOrNull((p) => p.listId == sp.documentList.id);
            
        // Cari profil secara global
        final profileMatch = profileMap[sp.documentList.id];

        // Jika profileMatch ketemu dan sudah terupload secara global ATAU ada di APL02.
        final hasGlobalProfile = profileMatch != null && profileMatch.isUploaded;

        return RequiredDocument(
          documentList: sp.documentList,
          portfolio: portfolioMatch,
          documentProfileId: sp.portfolioEntryId ?? portfolioMatch?.id ?? profileMatch?.id,
          isUploadedFromProfile: sp.isUploaded || hasGlobalProfile,
        );
      }).toList();

      portfolioDataSource.value = 1;
      print('[APL02] Layer-1 OK: ${requiredDocuments.length} docs '
          '(${requiredDocuments.where((d) => d.isUploaded).length} uploaded)');
      isLoadingDocs.value = false;
      return;
    }

    // ── Layer 2: GET /document-lists + /document-profiles (fallback API) ──
    final results = await Future.wait([
      _provider.fetchAllDocumentLists(schemeId: schemeId),
      _provider.fetchUserDocumentProfiles(),
    ]);
    final docLists = results[0] as List<DocumentList>;
    final profiles = results[1] as List<DocumentProfile>;

    // ── Diagnosa: cek apakah backend menyertakan scheme_id ──────────────
    if (docLists.isNotEmpty) {
      final withSchemeId = docLists.where((d) => d.schemeId != null).length;
      final withoutSchemeId = docLists.where((d) => d.schemeId == null).length;
      print('[APL02] Layer-2 diagnostics: ${docLists.length} docs total | '
          '$withSchemeId dengan scheme_id | $withoutSchemeId tanpa scheme_id');

      // ── GUARD: jika semua dokumen tidak punya scheme_id, backend tidak ──
      // menyertakan field ini di response — tidak bisa filter per skema.
      // Lanjut ke Layer-3 (data statis) agar tidak menampilkan semua 97 docs.
      if (withSchemeId == 0) {
        print('[APL02] ⚠ Layer-2 SKIP: semua ${docLists.length} dokumen tidak '
            'punya scheme_id — backend tidak memfilter. Lanjut ke Layer-3.');
      } else {
        // Ada dokumen dengan scheme_id — aman untuk dipakai
        final profileMap = <int, DocumentProfile>{
          for (final p in profiles) p.documentListId: p
        };
        requiredDocuments.value = _mergeWithProfiles(
          docLists: docLists,
          profileMap: profileMap,
          portfolios: data.portfolios,
        );
        portfolioDataSource.value = 2;
        print('[APL02] Layer-2 OK: ${requiredDocuments.length} docs '
            'untuk scheme_id=$schemeId '
            '(${requiredDocuments.where((d) => d.isUploaded).length} uploaded)');
        isLoadingDocs.value = false;
        return;
      }
    }

    // ── Layer 3: Data statis lokal (fallback offline) ──────────────────────
    final fallbackNames =
        SchemeDocumentsFallback.getRequiredDocs(data.scheme.name);

    if (fallbackNames.isNotEmpty) {
      print('[APL02] Layer-3: static fallback '
          '${fallbackNames.length} docs for "${data.scheme.name}"');
      requiredDocuments.value = fallbackNames.asMap().entries.map((entry) {
        final portfolioMatch = data.portfolios.firstWhereOrNull(
          (p) => p.documentList.title
              .toLowerCase()
              .contains(entry.value.toLowerCase().substring(
                    0,
                    entry.value.length > 10 ? 10 : entry.value.length,
                  )),
        );
        return RequiredDocument(
          documentList: DocumentList(
            id: -(entry.key + 1),
            title: entry.value,
            description: '',
            schemeId: schemeId,
          ),
          portfolio: portfolioMatch,
        );
      }).toList();

      // Tambahkan dokumen ekstra yang sudah diupload tapi tidak ada di daftar
      for (final p in data.portfolios) {
        if (!requiredDocuments.any((d) => d.portfolio?.id == p.id)) {
          requiredDocuments.add(RequiredDocument(
            documentList: p.documentList,
            portfolio: p,
          ));
        }
      }
      portfolioDataSource.value = 3;
      isLoadingDocs.value = false;
      return;
    }

    // ── Layer 4: Hanya dari portfolios APL02 response ──────────────────────
    print('[APL02] Layer-4: using APL02 portfolios only');
    requiredDocuments.value = data.portfolios.map((p) {
      return RequiredDocument(documentList: p.documentList, portfolio: p);
    }).toList();

    portfolioDataSource.value = 4;
    isLoadingDocs.value = false;
  }

  /// Merge DocumentList dari API dengan profile & portfolio user
  List<RequiredDocument> _mergeWithProfiles({
    required List<DocumentList> docLists,
    required Map<int, DocumentProfile> profileMap,
    required List<dynamic> portfolios,
  }) {
    return docLists.map((docList) {
      final matchedProfile = profileMap[docList.id];
      final portfolioMatch = (portfolios as List)
          .firstWhereOrNull((p) => p.listId == docList.id);
      return RequiredDocument(
        documentList: docList,
        portfolio: portfolioMatch,
        documentProfileId: matchedProfile?.id,
        isUploadedFromProfile: matchedProfile?.isUploaded ?? false,
      );
    }).toList();
  }

  /// Cek apakah DocumentProfile cocok dengan nama dokumen [title]
  bool _titleMatch(
      DocumentProfile p, String title, List<DocumentProfile> all) {
    // Untuk saat ini tidak bisa match karena profile tidak punya title langsung
    // Akan cocok ketika backend mengembalikan document_list di dalam profile
    return false;
  }

  void setAnswer(int criterionId, bool isCompetent) {
    userAnswer[criterionId] = isCompetent;
  }

  bool checkAnswer(int criterionId, bool checkType) {
    if (!userAnswer.containsKey(criterionId)) return false;
    return userAnswer[criterionId] == checkType;
  }

  /// Pilih semua kriteria sebagai Kompeten (K)
  void selectAll() {
    if (apl02Data.value == null) return;
    for (var unit in apl02Data.value!.scheme.units) {
      for (var element in unit.elements) {
        for (var criterion in element.criteria) {
          userAnswer[criterion.id] = true;
        }
      }
    }
  }

  /// Pilih semua kriteria sebagai Belum Kompeten (BK)
  void selectAllNotCompetent() {
    if (apl02Data.value == null) return;
    for (var unit in apl02Data.value!.scheme.units) {
      for (var element in unit.elements) {
        for (var criterion in element.criteria) {
          userAnswer[criterion.id] = false;
        }
      }
    }
  }

  /// Get total criteria count
  int get totalCriteria {
    if (apl02Data.value == null) return 0;
    int count = 0;
    for (var unit in apl02Data.value!.scheme.units) {
      for (var element in unit.elements) {
        count += element.criteria.length;
      }
    }
    return count;
  }

  /// Get answered criteria count
  int get answeredCriteria => userAnswer.length;

  /// Upload evidence — handle dua kasus:
  /// 1. RequiredDocument sudah punya portfolioId → pakai uploadPortfolioDocument
  /// 2. Belum ada portfolioId → pakai uploadNewDocument dengan listId
  Future<void> uploadEvidence(RequiredDocument doc) async {
    final file = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (file == null || file.files.isEmpty) return;

    final regId = apl02Data.value?.registrationId;
    if (regId == null) return;

    final listId = doc.listId;
    uploadingListIds.add(listId);

    String? errorMessage;
    if (doc.portfolioId != null) {
      // Dokumen sudah ada entri portfolio, cukup update file-nya
      errorMessage = await _provider.uploadPortfolioDocument(
        registrationId: regId,
        portfolioId: doc.portfolioId!,
        listId: listId,
        file: file.files.single,
      );
    } else {
      // Dokumen belum pernah diupload — buat entri baru
      errorMessage = await _provider.uploadNewDocument(
        registrationId: regId,
        listId: listId,
        file: file.files.single,
      );
    }

    uploadingListIds.remove(listId);

    if (errorMessage == null) {
      Get.snackbar(
        'Berhasil',
        'Dokumen berhasil diupload',
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      // Re-fetch HANYA dokumen portfolio (tidak perlu reload seluruh APL02)
      await refreshDocuments();
    } else {
      Get.snackbar(
        'Gagal',
        'Gagal mengupload dokumen\n$errorMessage',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void submitForm() async {
    if (apl02Data.value == null) return;

    final regId = apl02Data.value!.registrationId;
    isSubmitting.value = true;
    missingFiles.clear();

    // Ambil portfolioIds dari data yang sudah di-fetch
    final List<int> portfolioIds =
        apl02Data.value!.portfolios.map((p) => p.id).toList();

    // Buat list answers berdasarkan element_id yang sesungguhnya (Bukan criterion.id).
    // Suatu Element dianggap K (Kompeten) jika SEMUA Kriteria (KUK) di dalamnya dinilai K (true).
    final List<AnswerModel> answers = [];
    for (var unit in apl02Data.value!.scheme.units) {
      for (var element in unit.elements) {
        bool isElementCompetent = true;
        for (var criterion in element.criteria) {
          // Jika ada satu saja kriteria yang BK (false), maka elemen tersebut BK
          if (userAnswer[criterion.id] == false) {
            isElementCompetent = false;
            break;
          }
        }
        answers.add(AnswerModel(
          elementId: element.id,
          isCompetent: isElementCompetent,
        ));
      }
    }

    final payload = SubmitApl02Request(
      isDeclared: true,
      portfolioIds: portfolioIds,
      answers: answers,
    );

    final result = await _provider.postDatabyId(regId, payload);

    if (result.success) {
      Get.snackbar(
        'Sukses',
        result.message ?? 'APL-02 berhasil disubmit!',
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      // Refresh list pengajuan di home & redirect ke home
      try {
        if (Get.isRegistered<PengajuanController>()) {
          Get.find<PengajuanController>().fetchPengajuan();
        }
      } catch (e) {
        print('[APL02] Fail to refresh pengajuan: $e');
      }
      Get.offAllNamed(AppPages.home);
    } else if (result.missingFiles.isNotEmpty) {
      // E2013 — show missing documents
      missingFiles.value = result.missingFiles;
      _showMissingDocsDialog(result.message ?? 'Dokumen wajib belum diunggah');
    } else {
      Get.snackbar(
        'Gagal',
        result.message ?? 'Terjadi kesalahan saat menyimpan. Coba lagi.',
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }

    isSubmitting.value = false;
  }

  /// Show dialog for missing required documents (E2013)
  void _showMissingDocsDialog(String message) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange[700], size: 28),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Dokumen Belum Lengkap',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            const Text(
              'Dokumen yang belum diunggah:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...missingFiles.map((file) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.cancel, color: Colors.red[400], size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          file,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700], size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Upload dokumen di bagian Portfolio di atas, lalu submit ulang.',
                      style: TextStyle(fontSize: 11, color: Colors.blue[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Tutup'),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  /// Show competency question dialog
  void showCompetencyDialog() {
    if (competencyDialogShown.value) return;
    competencyDialogShown.value = true;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assignment_turned_in,
                color: Color(0xFF4CAF50),
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Apakah Anda kompeten dalam bidang ini?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: const Text(
          'Anda dapat memilih untuk menandai semua kriteria sebagai '
          '"Kompeten" atau mengisi secara manual satu per satu.',
          style: TextStyle(fontSize: 13, color: Colors.black54),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Column(
            children: [
              // Tombol Kompeten
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    selectAll();
                    Get.back();
                    Get.snackbar(
                      'Kompeten',
                      'Semua kriteria ditandai sebagai Kompeten (K)',
                      backgroundColor: const Color(0xFF4CAF50),
                      colorText: Colors.white,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  icon: const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  label: const Text(
                    'Kompeten (Centang Semua K)',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Tombol Isi Manual
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    side: BorderSide(color: Colors.grey[400]!),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.edit_note, color: Colors.grey[700], size: 20),
                  label: Text(
                    'Isi Manual',
                    style: TextStyle(
                        color: Colors.grey[700], fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}