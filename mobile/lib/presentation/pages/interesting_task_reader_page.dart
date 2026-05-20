import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../core/theme/colors.dart';
import '../../data/datasources/interesting_task_remote_data_source.dart';

/// `[x]` bilan belgilangan qatorlarni olib tashlaydi: oddiy qator boshidagi `[x]`,
/// shuningdek `- [x]`, `* [x]` (Markdown checklist) va `x]` xato yozuv.
final RegExp _lineMarkedWithBracketX = RegExp(
  r'^\s*(?:[-*+]\s+)?\[\s*x\s*\]\s*',
  caseSensitive: false,
);

/// `[x]` yoki `[ X ]` bilan belgilangan qatorlarni olib tashlaydi.
String stripLinesMarkedWithBracketX(String text) {
  return text
      .split(RegExp(r'\r?\n'))
      .where((line) => !_lineMarkedWithBracketX.hasMatch(line))
      .join('\n');
}

/// Loyihalar (`kind=project`) — savollar ro'yxati (Nazariy kartasi uslubida).
class InterestingTaskReaderPage extends StatefulWidget {
  final int taskId;
  final InterestingTaskRemoteDataSource ds;
  final String titleHint;
  final InterestingTasksListKind expectedKind;

  const InterestingTaskReaderPage({
    super.key,
    required this.taskId,
    required this.ds,
    required this.titleHint,
    this.expectedKind = InterestingTasksListKind.project,
  });

  @override
  State<InterestingTaskReaderPage> createState() =>
      _InterestingTaskReaderPageState();
}

class _InterestingTaskReaderPageState extends State<InterestingTaskReaderPage> {
  TaskWithQuestionsModel? _task;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final task = await widget.ds.getTask(
        widget.taskId,
        expectedKind: widget.expectedKind,
      );
      if (mounted) {
        setState(() {
          _task = task;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  MarkdownStyleSheet _markdownStyle(BuildContext context, bool isDark) {
    return MarkdownStyleSheet(
      p: TextStyle(
        fontSize: 16,
        height: 1.55,
        color: isDark ? Colors.white70 : AppColors.textPrimary,
      ),
      h1: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : AppColors.textPrimary,
      ),
      h2: TextStyle(
        fontSize: 18,
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
    );
  }

  String _questionsTitle(String lang) {
    if (lang == 'uz') return 'Savollar';
    if (lang == 'ru') return 'Вопросы';
    return 'Questions';
  }

  String _emptyQuestionsHint(String lang) {
    if (lang == 'uz') return 'Ushbu loyiha uchun savollar hali qo‘shilmagan.';
    if (lang == 'ru') return 'Для этого проекта вопросы пока не добавлены.';
    return 'No questions for this project yet.';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = Localizations.localeOf(context).languageCode;
    final title = _task?.title ?? widget.titleHint;

    return Scaffold(
      appBar: AppBar(title: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline,
                            size: 48, color: Theme.of(context).colorScheme.error),
                        const SizedBox(height: 12),
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _load,
                          child: Text(lang == 'uz' ? 'Qayta urinish' : (lang == 'ru' ? 'Повторить' : 'Retry')),
                        ),
                      ],
                    ),
                  ),
                )
              : _buildContent(context, isDark, lang),
    );
  }

  Widget _buildContent(BuildContext context, bool isDark, String lang) {
    final task = _task!;
    final questions = task.questions.toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    final visible = <TaskQuestionModel>[];
    for (final q in questions) {
      final cleaned =
          stripLinesMarkedWithBracketX(q.body).trim();
      if (cleaned.isNotEmpty) {
        visible.add(q);
      }
    }

    return SingleChildScrollView(
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
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _questionsTitle(lang),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            if (visible.isEmpty)
              Text(
                _emptyQuestionsHint(lang),
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: isDark ? Colors.white54 : AppColors.textSecondary,
                ),
              )
            else
              ...List.generate(visible.length, (index) {
                final q = visible[index];
                final body = stripLinesMarkedWithBracketX(q.body).trim();
                final mdStyle = _markdownStyle(context, isDark);
                final badgeColor =
                    isDark ? AppColors.primaryPurple.withValues(alpha: 0.35) : const Color(0xFFF3E5F5);
                final badgeFg = isDark ? Colors.white : AppColors.primaryPurple;

                return Padding(
                  padding: EdgeInsets.only(bottom: index < visible.length - 1 ? 20 : 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: badgeFg,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: MarkdownBody(
                          data: body,
                          styleSheet: mdStyle,
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
