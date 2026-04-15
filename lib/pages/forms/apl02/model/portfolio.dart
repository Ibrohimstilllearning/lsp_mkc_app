import 'package:lsp_mkc_app/pages/forms/apl02/model/document_list.dart';

class Portfolio {
  final int id;
  final int userId;
  final int listId;
  final String uploadDocument;
  final bool isActive;
  final DocumentList documentList;

  Portfolio({ 
  required this.id, 
  required this.userId, 
  required this.listId, 
  required this.uploadDocument, 
  required this.isActive, 
  required this.documentList
  });

  factory Portfolio.fromJson(Map<String, dynamic> json) {
    return Portfolio(
      id: json['id'], 
      userId: json['user_id'], 
      listId: json['list_id'], 
      uploadDocument: json['upload_document'], 
      isActive: json['is_active'], 
      documentList: DocumentList.fromJson(json['document_list'])
      );
  }

}