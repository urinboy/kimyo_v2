import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/document_model.dart';
import '../utils/document_pdf_url.dart';

enum DownloadStatus { none, downloading, done, error }

/// Manages local offline copies of server documents.
///
/// Fayllar: `ApplicationDocumentsDirectory/offline_docs/<originalFilename>`
/// The download status is persisted in SharedPreferences.
class DocumentDownloadService extends ChangeNotifier {
  DocumentDownloadService({
    required this.dio,
    required this.prefs,
  });

  final Dio dio;
  final SharedPreferences prefs;

  static const _kPrefix = 'doc_dl_';

  // In-memory download progress map: filename → 0.0–1.0
  final Map<String, double> _progress = {};
  final Map<String, DownloadStatus> _statusCache = {};

  /// Disk papkasi tayyor bo‘lgandan keyin `statusOf` faylni bevosita tekshiradi.
  String? _offlineRoot;

  // Bir xil fayl uchun takrorlanuvchi Dio chaqiruqlarini birlashtirish
  final Map<String, Future<void>> _activeDownloads = {};

  double progressOf(String filename) => _progress[filename] ?? 0.0;

  // ---------- status ----------

  DownloadStatus statusOf(DocumentModel doc) {
    if (kIsWeb) return DownloadStatus.none;
    final name = doc.originalFilename;
    if (name == null || name.isEmpty) return DownloadStatus.none;

    if (_statusCache[name] == DownloadStatus.downloading) {
      return DownloadStatus.downloading;
    }

    if (_offlineRoot != null) {
      final file = File('$_offlineRoot/$name');
      if (file.existsSync()) {
        _statusCache[name] = DownloadStatus.done;
        if (prefs.getBool('$_kPrefix$name') != true) {
          prefs.setBool('$_kPrefix$name', true);
        }
        return DownloadStatus.done;
      }
      if (prefs.getBool('$_kPrefix$name') == true) {
        prefs.remove('$_kPrefix$name');
      }
      _statusCache.remove(name);
    } else if (prefs.getBool('$_kPrefix$name') == true) {
      _statusCache[name] = DownloadStatus.done;
      return DownloadStatus.done;
    }

    if (_statusCache.containsKey(name)) {
      return _statusCache[name]!;
    }

    _statusCache[name] = DownloadStatus.none;
    return DownloadStatus.none;
  }

  bool isDownloaded(DocumentModel doc) => statusOf(doc) == DownloadStatus.done;

  /// Sahifa ochilganda chaqing — diskdagi nusxalar bo‘yicha ikonka/holat to‘g‘ri bo‘ladi.
  Future<void> ensureOfflineDirectoryReady() async {
    if (kIsWeb) return;
    await _docsDir;
    notifyListeners();
  }

  // ---------- paths ----------

  Future<Directory> get _docsDir async {
    if (kIsWeb) throw UnsupportedError('Local directory storage is not supported on web.');
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/offline_docs');
    if (!dir.existsSync()) await dir.create(recursive: true);
    _offlineRoot = dir.path;
    return dir;
  }

  Future<String?> localPathOf(DocumentModel doc) async {
    if (kIsWeb) return null;
    final name = doc.originalFilename;
    if (name == null || name.isEmpty) return null;
    final dir = await _docsDir;
    final file = File('${dir.path}/$name');
    return file.existsSync() ? file.path : null;
  }

  // ---------- download ----------

  Future<void> download(DocumentModel doc) async {
    if (kIsWeb) return;
    final name = doc.originalFilename;
    if (name == null || name.isEmpty) return;
    final url = resolveDocumentPdfUrl(dio.options.baseUrl, doc);
    if (url.isEmpty) return;

    final future = _activeDownloads.putIfAbsent(
      name,
      () => _performDownload(doc, name, url),
    );
    try {
      await future;
    } finally {
      if (identical(_activeDownloads[name], future)) {
        _activeDownloads.remove(name);
      }
    }
  }

  Future<void> _performDownload(DocumentModel doc, String name, String url) async {
    _statusCache[name] = DownloadStatus.downloading;
    _progress[name] = 0.0;
    notifyListeners();

    try {
      final dir = await _docsDir;
      final savePath = '${dir.path}/$name';

      await dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            _progress[name] = received / total;
            notifyListeners();
          }
        },
        options: Options(
          receiveTimeout: const Duration(minutes: 5),
          headers: const {'Accept': '*/*'},
        ),
      );

      _statusCache[name] = DownloadStatus.done;
      _progress[name] = 1.0;
      await prefs.setBool('$_kPrefix$name', true);
    } catch (e) {
      _statusCache[name] = DownloadStatus.error;
      _progress[name] = 0.0;
      if (kDebugMode) debugPrint('DocumentDownload error: $e');
    }

    notifyListeners();
  }

  /// Tarmoq URL mavjud bo‘lsa yuklab, yo‘lini qaytaradi; allaqachon diskda bo‘lsa darhol yo‘l.
  /// [fileUrl] bo‘sh fallback uchun `/storage/documents/<original_filename>` tuziladi.
  Future<String?> ensurePdfOnDisk(DocumentModel doc) async {
    if (kIsWeb) return null;
    await _docsDir;
    final cached = await localPathOf(doc);
    if (cached != null) return cached;

    final url = resolveDocumentPdfUrl(dio.options.baseUrl, doc);
    if (url.isEmpty) return null;

    await download(doc);
    return await localPathOf(doc);
  }

  bool hasFetchablePdfUrl(DocumentModel doc) =>
      resolveDocumentPdfUrl(dio.options.baseUrl, doc).isNotEmpty;

  // ---------- delete local copy ----------

  Future<void> deleteLocal(DocumentModel doc) async {
    if (kIsWeb) return;
    final name = doc.originalFilename;
    if (name == null || name.isEmpty) return;
    final path = await localPathOf(doc);
    if (path != null) {
      final file = File(path);
      if (file.existsSync()) await file.delete();
    }
    _statusCache[name] = DownloadStatus.none;
    _progress.remove(name);
    await prefs.remove('$_kPrefix$name');
    notifyListeners();
  }
}
