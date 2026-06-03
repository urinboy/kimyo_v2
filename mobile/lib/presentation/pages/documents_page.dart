import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/colors.dart';
import '../../core/services/document_download_service.dart';
import '../../core/utils/document_pdf_url.dart';
import '../../data/datasources/document_remote_data_source.dart';
import '../../data/models/document_model.dart';
import '../../injection_container.dart' as di;
import '../widgets/module_menu_list_cards.dart';
import 'pdf_viewer_page.dart';

// ─── Fallback data when API is unavailable ────────────────────────────────────
final _kFallbackDocs = [
  DocumentModel(
    id: -1,
    category: 'decisions',
    titleUz: "Vazirlar Mahkamasi Qarori 847-son",
    filePath: 'assets/pdf/qaror_847.pdf',
    originalFilename: 'qaror_847.pdf',
    fileUrl: '',
    fileSize: 0,
    sortOrder: 1,
    isActive: true,
  ),
  DocumentModel(
    id: -2,
    category: 'decisions',
    titleUz: "Prezident Qarori PQ-54",
    filePath: 'assets/pdf/pq_54.pdf',
    originalFilename: 'pq_54.pdf',
    fileUrl: '',
    fileSize: 0,
    sortOrder: 2,
    isActive: true,
  ),
  DocumentModel(
    id: -3,
    category: 'decisions',
    titleUz: "Prezident Qarori PQ-2909 (20.04.2017)",
    filePath: 'assets/pdf/pq_2909.pdf',
    originalFilename: 'pq_2909.pdf',
    fileUrl: '',
    fileSize: 0,
    sortOrder: 3,
    isActive: true,
  ),
  DocumentModel(
    id: -4,
    category: 'decisions',
    titleUz: "Muallif va nashriyot huquqlari to'g'risida",
    filePath: 'assets/pdf/muallif.pdf',
    originalFilename: 'muallif.pdf',
    fileUrl: '',
    fileSize: 0,
    sortOrder: 4,
    isActive: true,
  ),
  DocumentModel(
    id: -5,
    category: 'decisions',
    titleUz: "Kimyodan qiziqarli topshiriqlar",
    filePath: 'assets/pdf/qiziqarli-topshiriqlar.pdf',
    originalFilename: 'qiziqarli-topshiriqlar.pdf',
    fileUrl: '',
    fileSize: 0,
    sortOrder: 5,
    isActive: true,
  ),
  DocumentModel(
    id: -6,
    category: 'laws',
    titleUz: "O'zbekiston Respublikasi Qonuni O'RQ-637-son",
    filePath: 'assets/pdf/orq_637.pdf',
    originalFilename: 'orq_637.pdf',
    fileUrl: '',
    fileSize: 0,
    sortOrder: 1,
    isActive: true,
  ),
  DocumentModel(
    id: -7,
    category: 'laws',
    titleUz: "O'zbekiston Respublikasi Qonuni O'RQ-901-son",
    filePath: 'assets/pdf/orq_901.pdf',
    originalFilename: 'orq_901.pdf',
    fileUrl: '',
    fileSize: 0,
    sortOrder: 2,
    isActive: true,
  ),
];

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key});

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  List<DocumentModel> _allDocs = [];
  bool _loading = true;
  String? _apiError;

  final _remote = di.sl<DocumentRemoteDataSource>();
  final _downloader = di.sl<DocumentDownloadService>();

  @override
  void initState() {
    super.initState();
    _downloader.addListener(_onDownloadUpdate);
    _fetchDocs();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _downloader.ensureOfflineDirectoryReady();
    });
  }

  @override
  void dispose() {
    _downloader.removeListener(_onDownloadUpdate);
    super.dispose();
  }

  void _onDownloadUpdate() => setState(() {});

  Future<void> _fetchDocs() async {
    try {
      final docs = await _remote.getAll();
      if (mounted) setState(() { _allDocs = docs; _loading = false; });
    } catch (_) {
      if (mounted) {
        setState(() {
          _allDocs = _kFallbackDocs;
          _loading = false;
          _apiError = 'offline';
        });
      }
    }
  }

  List<DocumentModel> _filtered(String? category) {
    if (category == null) return _allDocs;
    return _allDocs.where((d) => d.category == category).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.scaffoldBackgroundDark : AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          context.tr('tab_hujjatlar'),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_apiError != null)
            Tooltip(
              message: context.tr('doc_offline_mode'),
              child: const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(Icons.cloud_off_outlined, color: Colors.orangeAccent, size: 22),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: context.tr('doc_refresh'),
            onPressed: () {
              setState(() {
                _loading = true;
                _apiError = null;
              });
              _fetchDocs();
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ModuleNavListCard(
                  title: context.tr('doc_decisions'),
                  icon: Icons.gavel_rounded,
                  accentColor: AppColors.primaryBlue,
                  iconBackgroundLight: AppColors.iconBackgroundBlue,
                  onTap: () => Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => DocumentsCategoryPage(
                        title: context.tr('doc_decisions'),
                        docs: _filtered('decisions'),
                        downloader: _downloader,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ModuleNavListCard(
                  title: context.tr('doc_laws'),
                  icon: Icons.balance_rounded,
                  accentColor: AppColors.iconGreen,
                  iconBackgroundLight: AppColors.iconBackgroundGreen,
                  onTap: () => Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => DocumentsCategoryPage(
                        title: context.tr('doc_laws'),
                        docs: _filtered('laws'),
                        downloader: _downloader,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

/// Ichki ro‘yxat: ko‘k AppBar + API dan kelgan hujjatlar (eski kartochka uslubi).
class DocumentsCategoryPage extends StatefulWidget {
  final String title;
  final List<DocumentModel> docs;
  final DocumentDownloadService downloader;

  const DocumentsCategoryPage({
    super.key,
    required this.title,
    required this.docs,
    required this.downloader,
  });

  @override
  State<DocumentsCategoryPage> createState() => _DocumentsCategoryPageState();
}

class _DocumentsCategoryPageState extends State<DocumentsCategoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.downloader.ensureOfflineDirectoryReady();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.scaffoldBackgroundDark : AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
      body: _DocList(docs: widget.docs, downloader: widget.downloader),
    );
  }
}

// ─── Document list ────────────────────────────────────────────────────────────

class _DocList extends StatelessWidget {
  final List<DocumentModel> docs;
  final DocumentDownloadService downloader;

  const _DocList({required this.docs, required this.downloader});

  @override
  Widget build(BuildContext context) {
    if (docs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.folder_open_rounded, size: 52, color: Colors.grey),
            const SizedBox(height: 12),
            Text(context.tr('doc_empty'),
                style: const TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListenableBuilder(
      listenable: downloader,
      builder: (context, _) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, i) =>
              _DocTile(doc: docs[i], downloader: downloader),
        );
      },
    );
  }
}

// ─── Document tile ────────────────────────────────────────────────────────────

class _DocTile extends StatelessWidget {
  final DocumentModel doc;
  final DocumentDownloadService downloader;

  const _DocTile({required this.doc, required this.downloader});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = Localizations.localeOf(context).languageCode;
    final title = doc.titleFor(lang);
    final status = downloader.statusOf(doc);
    final hasBundled = doc.bundledAssetPath != null;
    final isDownloaded = status == DownloadStatus.done;

    final subtitle = _subtitleLine(context, hasBundled);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _open(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.25)
                    : Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _catColor(doc.category).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.picture_as_pdf_rounded,
                  color: _catColor(doc.category),
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    if (subtitle.isNotEmpty || isDownloaded) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (subtitle.isNotEmpty)
                            Expanded(
                              child: Text(
                                subtitle,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.white54
                                      : AppColors.textSecondary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          if (isDownloaded)
                            Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: _Badge(
                                label: context.tr('doc_downloaded'),
                                color: Colors.green,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildAction(context, status, hasBundled, isDownloaded, isDark),
            ],
          ),
        ),
      ),
    );
  }

  String _subtitleLine(BuildContext context, bool hasBundled) {
    if (doc.fileSizeLabel.isNotEmpty) return doc.fileSizeLabel;
    if (hasBundled) return context.tr('doc_in_app');
    return '';
  }

  void _showDeleteConfirmBottomSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = Localizations.localeOf(context).languageCode;
    final docTitle = doc.titleFor(lang);

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        final bottomPad = MediaQuery.paddingOf(sheetContext).bottom;
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 8, 24, 20 + bottomPad),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  sheetContext.tr('doc_delete_confirm_title'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  sheetContext.tr('doc_delete_confirm_body'),
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.35,
                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  docTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        child: Text(sheetContext.tr('cancel')),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          Navigator.pop(sheetContext);
                          await downloader.deleteLocal(doc);
                        },
                        child: Text(sheetContext.tr('doc_delete_confirm_action')),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAction(
    BuildContext context,
    DownloadStatus status,
    bool hasBundled,
    bool isDownloaded,
    bool isDark,
  ) {
    if (kIsWeb) {
      if (hasBundled) {
        return Icon(
          Icons.visibility_outlined,
          size: 24,
          color: isDark ? Colors.white70 : AppColors.primaryBlue,
        );
      }
      if (downloader.hasFetchablePdfUrl(doc)) {
        return Icon(
          Icons.open_in_new_rounded,
          size: 24,
          color: isDark ? Colors.white70 : AppColors.primaryBlue,
        );
      }
      return const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 28);
    }

    // Serverdan yuklab olingan lokal nusxa — tayyor (✓) + o‘chirish
    if (isDownloaded) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            message: context.tr('doc_offline_ready'),
            child: Icon(
              Icons.check_circle_rounded,
              size: 28,
              color: isDark ? const Color(0xFF69F0AE) : Colors.green.shade700,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 22, color: Colors.red),
            tooltip: context.tr('doc_delete_local'),
            onPressed: () => _showDeleteConfirmBottomSheet(context),
          ),
        ],
      );
    }

    // Downloading → progress ring (indeterminate until server reports size)
    if (status == DownloadStatus.downloading) {
      final pct = downloader.progressOf(doc.originalFilename ?? '');
      final known = pct > 0.001 && pct <= 1.0;
      return SizedBox(
        width: 40,
        height: 40,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: known ? pct.clamp(0.0, 1.0) : null,
              strokeWidth: 2.5,
              color: AppColors.primaryBlue,
            ),
            if (known)
              Text(
                '${(pct * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : AppColors.textPrimary,
                ),
              ),
          ],
        ),
      );
    }

    // `file_url` bo‘sh bo‘lsa ham `/storage/documents/<fayl>` URL tuzilishi mumkin
    if (downloader.hasFetchablePdfUrl(doc)) {
      return IconButton(
        icon: Icon(
          Icons.cloud_download_outlined,
          size: 24,
          color: isDark ? Colors.white70 : AppColors.primaryBlue,
        ),
        tooltip: hasBundled
            ? context.tr('doc_download_update')
            : context.tr('doc_download'),
        onPressed: () => _downloadAndMaybeOpen(context),
      );
    }

    return const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 28);
  }

  /// Bulut tugmasi: yuklaydi; muvaffaqiyatda lokal PDFni ochadi.
  Future<void> _downloadAndMaybeOpen(BuildContext context) async {
    await downloader.download(doc);
    if (!context.mounted) return;
    final st = downloader.statusOf(doc);
    if (st != DownloadStatus.done) {
      if (st == DownloadStatus.error && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('doc_download_failed'))),
        );
      }
      return;
    }
    final path = await downloader.localPathOf(doc);
    if (!context.mounted || path == null) return;
    if (!File(path).existsSync()) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('doc_file_not_on_device'))),
        );
      }
      await downloader.ensureOfflineDirectoryReady();
      return;
    }
    final lang = Localizations.localeOf(context).languageCode;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PdfViewerPage(title: doc.titleFor(lang), filePath: path),
      ),
    );
  }

  Future<void> _open(BuildContext context) async {
    final lang = Localizations.localeOf(context).languageCode;
    final title = doc.titleFor(lang);
    final status = downloader.statusOf(doc);

    if (kIsWeb) {
      if (doc.bundledAssetPath != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PdfViewerPage(
              title: title,
              assetPath: doc.bundledAssetPath,
            ),
          ),
        );
        return;
      }
      if (downloader.hasFetchablePdfUrl(doc)) {
        final baseUrl = di.sl<Dio>().options.baseUrl;
        final url = resolveDocumentPdfUrl(baseUrl, doc);
        if (url.isNotEmpty) {
          launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
          return;
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('doc_file_not_on_device'))),
      );
      return;
    }

    if (status == DownloadStatus.downloading) {
      return;
    }

    if (status == DownloadStatus.done) {
      final path = await downloader.localPathOf(doc);
      if (!context.mounted) return;
      if (path != null && File(path).existsSync()) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PdfViewerPage(title: title, filePath: path),
          ),
        );
        return;
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('doc_file_not_on_device'))),
        );
      }
      await downloader.ensureOfflineDirectoryReady();
      return;
    }

    /// APK ichidagi PDF — tarmoqdan oldin (fallback ro‘yxat va server yo‘qida ham ishlaydi).
    if (doc.bundledAssetPath != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PdfViewerPage(
            title: title,
            assetPath: doc.bundledAssetPath,
          ),
        ),
      );
      return;
    }

    if (downloader.hasFetchablePdfUrl(doc)) {
      await downloader.download(doc);
      if (!context.mounted) return;
      final st = downloader.statusOf(doc);
      if (st != DownloadStatus.done) {
        if (st == DownloadStatus.error && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.tr('doc_download_failed'))),
          );
        }
        return;
      }
      final diskPath = await downloader.localPathOf(doc);
      if (!context.mounted || diskPath == null) return;
      if (!File(diskPath).existsSync()) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.tr('doc_file_not_on_device'))),
          );
        }
        return;
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PdfViewerPage(title: title, filePath: diskPath),
        ),
      );
      return;
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('doc_need_download')),
          action: SnackBarAction(
            label: context.tr('doc_download'),
            onPressed: () => _downloadAndMaybeOpen(context),
          ),
        ),
      );
    }
  }

  Color _catColor(String category) {
    return category == 'laws' ? Colors.green : Colors.red;
  }
}

// ─── Tiny badge ──────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
