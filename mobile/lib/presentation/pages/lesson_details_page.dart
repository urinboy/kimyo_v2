import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../widgets/lesson_markdown_with_math.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/repositories/lesson_repository.dart';
import '../../core/theme/colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/services/learning_progress_service.dart';
import '../../injection_container.dart' as di;
import 'virtual_lab_page.dart';

class LessonDetailsPage extends StatefulWidget {
  final LessonEntity lesson;

  const LessonDetailsPage({super.key, required this.lesson});

  @override
  State<LessonDetailsPage> createState() => _LessonDetailsPageState();
}

class _LessonDetailsPageState extends State<LessonDetailsPage> {
  late final ScrollController _scroll;
  bool _loggedComplete = false;

  /// Ro‘yxatdan kelgan yengil model; keyin to‘liq dars bilan almashtiriladi.
  late LessonEntity _lesson;
  bool _loadingLesson = true;
  Object? _loadError;

  @override
  void initState() {
    super.initState();
    _lesson = widget.lesson;
    _scroll = ScrollController()..addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeNoScrollShortcut();
      _fetchFullLesson();
    });
  }

  Future<void> _fetchFullLesson() async {
    final result = await di.sl<LessonRepository>().getLesson(widget.lesson.id);
    if (!mounted) return;
    result.fold(
      (e) => setState(() {
        _loadingLesson = false;
        _loadError = e;
      }),
      (lesson) => setState(() {
        _lesson = lesson;
        _loadingLesson = false;
        _loadError = null;
      }),
    );
    if (mounted) WidgetsBinding.instance.addPostFrameCallback((_) => _maybeNoScrollShortcut());
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_loggedComplete || !_scroll.hasClients) return;
    final max = _scroll.position.maxScrollExtent;
    if (max <= 4) return;
    if (_scroll.position.pixels >= max - 72) _tryMarkComplete();
  }

  void _maybeNoScrollShortcut() {
    if (_loggedComplete || !_scroll.hasClients) return;
    if (_scroll.position.maxScrollExtent <= 4) _tryMarkComplete();
  }

  void _tryMarkComplete() {
    if (_loggedComplete || !mounted) return;
    _loggedComplete = true;
    final lang = context.locale.languageCode;
    final title = widget.lesson.getTitle(lang);
    final line =
        '${context.tr('activity_subject_chemistry')}: $title';
    final svc = di.sl<LearningProgressService>();
    final first = svc.tryCompleteChemistryLesson(_lesson.id, line);
    if (first) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('study_marked_done_snackbar'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final langCode = context.locale.languageCode;
    final title = _lesson.getTitle(langCode);
    final content = _lesson.getContent(langCode) ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      bottomNavigationBar: _lesson.type == 'lab' &&
              _lesson.labItemsCount > 0
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VirtualLabPage(
                          lessonId: _lesson.id,
                          lessonTitle: title,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.science_rounded),
                  label: Text(context.tr('virtual_lab_start_btn')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.solidPurple,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            )
          : null,
      body: _loadingLesson && content.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppColors.solidPurple))
          : _loadError != null && content.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('$_loadError', textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () {
                            setState(() {
                              _loadingLesson = true;
                              _loadError = null;
                            });
                            _fetchFullLesson();
                          },
                          child: Text(context.tr('retry')),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
        controller: _scroll,
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              LessonMarkdownWithMath(
                data: content.isEmpty ? '...' : content,
                isDark: isDark,
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: isDark ? Colors.white70 : AppColors.textPrimary,
                  ),
                  h1: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                  h2: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                  code: const TextStyle(
                    backgroundColor: Colors.black12,
                    fontFamily: 'monospace',
                  ),
                  listBullet: TextStyle(
                    color: isDark ? Colors.white70 : AppColors.textPrimary,
                  ),
                ),
              ),
              if (_loadingLesson && content.isNotEmpty)
                Positioned(
                  top: 0,
                  right: 0,
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.solidPurple.withValues(alpha: 0.85),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
