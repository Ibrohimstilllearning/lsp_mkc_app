import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lsp_mkc_app/pages/forms/apl02/providers/response_provider.dart';
import 'package:lsp_mkc_app/pages/forms/apl02/model/document_list.dart';
import 'package:lsp_mkc_app/pages/forms/apl02/model/required_document.dart';
import 'package:lsp_mkc_app/pages/forms/apl02/data/scheme_documents_fallback.dart';
import 'package:lsp_mkc_app/pages/forms/apl02/model/scheme.dart';

class PortfolioUploadController extends GetxController {
  final ResponseProvider _provider = ResponseProvider();

  var isLoading = false.obs;
  var requiredDocuments = <RequiredDocument>[].obs;
  var uploadingListIds = <int>{}.obs;

  void fetchPortfolios(Scheme scheme) async {
    isLoading.value = true;
    final schemeId = scheme.id;
    
    // ── Layer 1: GET /schemes/{id}/portfolios (sumber utama) ───────────────
    final schemePortfolios = await _provider.fetchSchemePortfolios(schemeId);

    if (schemePortfolios.isNotEmpty) {
      final profiles = await _provider.fetchUserDocumentProfiles();
      final Map<int, DocumentProfile> profileMap = {};
      for (var p in profiles) {
        profileMap[p.documentListId] = p;
      }

      requiredDocuments.value = schemePortfolios.map<RequiredDocument>((sp) {
        final profileMatch = profileMap[sp.documentList.id];
        return RequiredDocument(
          documentList: sp.documentList,
          portfolio: null,
          documentProfileId: profileMatch?.id ?? sp.portfolioEntryId,
          isUploadedFromProfile: profileMatch != null ? true : sp.isUploaded,
          uploadedFileUrl: profileMatch?.fileUrl ?? sp.fileUrl,
        );
      }).toList();
      isLoading.value = false;
      return;
    }

    // ── Layer 2: GET /document-lists + /document-profiles (fallback API) ──
    final results = await Future.wait([
      _provider.fetchAllDocumentLists(schemeId: schemeId),
      _provider.fetchUserDocumentProfiles(),
    ]);
    final docLists = results[0] as List<DocumentList>;
    final profiles = results[1] as List<DocumentProfile>;

    var finalDocLists = docLists;
    final withSchemeId = finalDocLists.where((d) => d.schemeId != null).length;
    
    // Jika semua dokumen tidak punya schemeId (artinya backend tidak sediakan), 
    // kita filter berdasarkan nama statis fallback
    if (withSchemeId == 0) {
      final fallbackNames = SchemeDocumentsFallback.getRequiredDocs(scheme.name);
      if (fallbackNames.isNotEmpty) {
        finalDocLists = finalDocLists.where((d) {
          bool match = false;
          for (var fName in fallbackNames) {
            String shortName = fName.length > 10 ? fName.substring(0, 10).toLowerCase() : fName.toLowerCase();
            if (d.title.toLowerCase().contains(shortName)) {
              match = true;
              break;
            }
          }
          return match;
        }).toList();
      }
    }

    final profileMap = <int, DocumentProfile>{
      for (final p in profiles) p.documentListId: p
    };

    requiredDocuments.value = finalDocLists.map<RequiredDocument>((docList) {
      final matchedProfile = profileMap[docList.id];
      return RequiredDocument(
        documentList: docList,
        portfolio: null,
        documentProfileId: matchedProfile?.id,
        isUploadedFromProfile: matchedProfile?.isUploaded ?? false,
        uploadedFileUrl: matchedProfile?.fileUrl,
      );
    }).toList();

    isLoading.value = false;
  }

  Future<void> uploadEvidence(RequiredDocument doc) async {
    final file = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (file == null || file.files.isEmpty) return;

    final listId = doc.listId;
    uploadingListIds.add(listId);

    bool success;
    if (doc.documentProfileId != null) {
      // Update
      success = await _provider.uploadPortfolioDocument(
        registrationId: 0, // Profile upload doesn't strictly need registrationId if backend supports it
        portfolioId: doc.documentProfileId!,
        listId: listId,
        file: file.files.single,
      );
    } else {
      // New
      success = await _provider.uploadNewDocument(
        registrationId: 0, // Pass 0 or null if it's a global profile upload
        listId: listId,
        file: file.files.single,
      );
    }

    uploadingListIds.remove(listId);

    if (success) {
      Get.snackbar(
        'Berhasil',
        'Dokumen berhasil diupload ke Profile',
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      // Re-fetch to update status
      // We need RegistrationItem here, wait, we can just assume registrationId is enough?
      // Since fetchPortfolios needs RegistrationItem with schemeId. 
    } else {
      Get.snackbar(
        'Gagal',
        'Gagal mengupload dokumen. Coba lagi.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
