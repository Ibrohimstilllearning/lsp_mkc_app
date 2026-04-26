import 'package:lsp_mkc_app/pages/forms/apl02/model/document_list.dart';

class Portfolio {
  final int id;
  final int userId;
  final int listId;
  final String? uploadDocument; // nullable — belum tentu sudah diupload
  final String status; // "pending", "approved", etc.
  final bool isActive;
  final DocumentList documentList;

  Portfolio({
    required this.id,
    required this.userId,
    required this.listId,
    this.uploadDocument,
    this.status = 'pending',
    required this.isActive,
    required this.documentList,
  });

  /// Apakah dokumen sudah diupload
  bool get isUploaded =>
      uploadDocument != null && uploadDocument!.isNotEmpty;

  factory Portfolio.fromJson(Map<String, dynamic> json) {
    return Portfolio(
      id: json['id'],
      userId: json['user_id'],
      listId: json['list_id'],
      uploadDocument: json['upload_document'] as String?,
      status: json['status'] ?? 'pending',
      isActive: json['is_active'] ?? true,
      documentList: DocumentList.fromJson(json['document_list']),
    );
  }
}