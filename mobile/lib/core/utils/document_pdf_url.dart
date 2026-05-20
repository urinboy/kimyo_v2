import '../../data/models/document_model.dart';
import '../network/api_storage_url.dart';

/// API `file_url` (to‘liq URL yoki `/storage/...`), yoki seeded fayllar uchun `/storage/documents/<originalFilename>`.
String resolveDocumentPdfUrl(String apiV1Base, DocumentModel doc) {
  final raw = doc.fileUrl.trim();
  if (raw.isEmpty) {
    final n = doc.originalFilename;
    if (n == null || n.isEmpty) return '';
    return resolveApiStorageFileUrl(apiV1Base, '/storage/documents/$n');
  }
  return resolveApiStorageFileUrl(apiV1Base, raw);
}
