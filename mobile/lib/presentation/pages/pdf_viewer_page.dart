import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/colors.dart';

/// Opens a PDF from either a bundled [assetPath] or a local [filePath].
/// Exactly one of the two must be provided.
class PdfViewerPage extends StatefulWidget {
  final String title;

  /// Path inside the Flutter assets bundle, e.g. 'assets/pdf/qaror_847.pdf'
  final String? assetPath;

  /// Absolute path on the device filesystem (downloaded file).
  final String? filePath;

  const PdfViewerPage({
    super.key,
    required this.title,
    this.assetPath,
    this.filePath,
  }) : assert(assetPath != null || filePath != null,
            'Provide either assetPath or filePath');

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  PdfControllerPinch? _controller;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initPdf();
  }

  Future<void> _initPdf() async {
    try {
      if (widget.filePath != null) {
        final file = File(widget.filePath!);
        if (!await file.exists()) {
          if (!mounted) return;
          setState(() {
            _error = context.tr('doc_file_not_on_device');
            _isLoading = false;
          });
          return;
        }
      }

      final Future<PdfDocument> document = widget.filePath != null
          ? PdfDocument.openFile(widget.filePath!)
          : PdfDocument.openAsset(widget.assetPath!);
      _controller = PdfControllerPinch(document: document);
      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ctrl = _controller;

    return Scaffold(
      backgroundColor: isDark ? AppColors.scaffoldBackgroundDark : const Color(0xFFF2F2F2),
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          if (!_isLoading && _error == null && ctrl != null)
            PdfPageNumber(
              controller: ctrl,
              builder: (_, loadingState, page, pagesCount) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: Text(
                    loadingState == PdfLoadingState.success
                        ? '$page / $pagesCount'
                        : '',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: AppColors.primaryBlue),
                  const SizedBox(height: 16),
                  Text(context.tr('doc_loading'),
                      style: TextStyle(
                        color: isDark ? Colors.white70 : AppColors.textSecondary,
                      )),
                ],
              ),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 52, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          '${context.tr('doc_pdf_error')}\n$_error',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDark ? Colors.white70 : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ctrl == null
                  ? const SizedBox.shrink()
                  : PdfViewPinch(
                      controller: ctrl,
                      builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
                        options: const DefaultBuilderOptions(),
                        documentLoaderBuilder: (_) => Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(color: AppColors.primaryBlue),
                              const SizedBox(height: 16),
                              Text(context.tr('doc_loading')),
                            ],
                          ),
                        ),
                        pageLoaderBuilder: (_) => const Center(
                          child: CircularProgressIndicator(color: AppColors.primaryBlue),
                        ),
                        errorBuilder: (_, error) => Center(
                          child: Text('${context.tr('doc_pdf_error')}: $error'),
                        ),
                      ),
                    ),
    );
  }
}
