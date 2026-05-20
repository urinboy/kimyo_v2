import '../../core/utils/json_bool.dart';

class DocumentModel {
  final int id;
  final String category;
  final String titleUz;
  final String? titleRu;
  final String? titleEn;
  final String filePath;
  final String? originalFilename;
  final String fileUrl;
  final int fileSize;
  final int sortOrder;
  final bool isActive;

  const DocumentModel({
    required this.id,
    required this.category,
    required this.titleUz,
    this.titleRu,
    this.titleEn,
    required this.filePath,
    this.originalFilename,
    required this.fileUrl,
    required this.fileSize,
    required this.sortOrder,
    required this.isActive,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id:               (json['id'] as num).toInt(),
      category:         json['category'] as String,
      titleUz:          json['title_uz'] as String,
      titleRu:          json['title_ru'] as String?,
      titleEn:          json['title_en'] as String?,
      filePath:         json['file_path'] as String,
      originalFilename: json['original_filename'] as String?,
      fileUrl:          json['file_url'] as String,
      fileSize:         (json['file_size'] as num?)?.toInt() ?? 0,
      sortOrder:        (json['sort_order'] as num?)?.toInt() ?? 0,
      isActive:         jsonBool(json['is_active'], fallback: true),
    );
  }

  /// Returns title based on language code, falling back to Uzbek.
  String titleFor(String langCode) {
    switch (langCode) {
      case 'ru':
        return titleRu?.isNotEmpty == true ? titleRu! : titleUz;
      case 'en':
        return titleEn?.isNotEmpty == true ? titleEn! : titleUz;
      default:
        return titleUz;
    }
  }

  /// Local asset path bundled in the APK — null if this doc is server-only.
  String? get bundledAssetPath {
    final name = originalFilename;
    if (name == null || name.isEmpty) return null;
    const bundled = {
      'qaror_847.pdf',
      'pq_54.pdf',
      'pq_2909.pdf',
      'muallif.pdf',
      'qiziqarli-topshiriqlar.pdf',
      'orq_637.pdf',
      'orq_901.pdf',
    };
    return bundled.contains(name) ? 'assets/pdf/$name' : null;
  }

  /// Human-readable file size (e.g. "1.2 MB").
  String get fileSizeLabel {
    if (fileSize <= 0) return '';
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
