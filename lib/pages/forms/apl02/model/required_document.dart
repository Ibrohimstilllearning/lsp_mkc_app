import 'package:lsp_mkc_app/pages/forms/apl02/model/document_list.dart';
import 'package:lsp_mkc_app/pages/forms/apl02/model/portfolio.dart';

/// Merepresentasikan satu dokumen yang DIBUTUHKAN dalam APL02.
///
/// Sumber data bisa dari dua tempat:
/// 1. [portfolio]         — dari response APL02 (portfolios[])
/// 2. [documentProfileId] — dari GET /document-profiles
class RequiredDocument {
  final DocumentList documentList;
  final Portfolio? portfolio;

  /// ID dari /document-profiles jika dokumen sudah pernah diupload via profil
  final int? documentProfileId;

  /// Status upload dari /document-profiles (true jika file_url ada)
  final bool isUploadedFromProfile;

  /// Override file url from DocumentProfile or SchemePortfolio
  final String? uploadedFileUrl;

  RequiredDocument({
    required this.documentList,
    this.portfolio,
    this.documentProfileId,
    this.isUploadedFromProfile = false,
    this.uploadedFileUrl,
  });

  /// Apakah dokumen sudah diupload (dari sumber manapun)
  bool get isUploaded =>
      isUploadedFromProfile || (portfolio?.isUploaded ?? false);

  String get fileUrl => uploadedFileUrl ?? portfolio?.uploadDocument ?? 'File Tersimpan';

  /// ID untuk update dokumen yang sudah ada:
  /// Prioritas: documentProfileId → portfolio.id
  int? get portfolioId => documentProfileId ?? portfolio?.id;

  /// list_id dari document_list — dipakai saat upload dokumen baru
  int get listId => documentList.id;

  /// Nama dokumen
  String get title => documentList.title;
}
