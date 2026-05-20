import 'package:flutter/material.dart';

import '../../injection_container.dart';
import '../../core/network/dio_client.dart';
import '../../core/theme/colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/auth/auth_session.dart';
import '../../data/datasources/interesting_task_remote_data_source.dart';
import 'task_quiz_page.dart';
import 'my_submissions_page.dart';
import 'interesting_task_submission_detail_page.dart';
import 'interesting_task_reader_page.dart';

export '../../data/datasources/interesting_task_remote_data_source.dart' show InterestingTasksListKind;

class InterestingTasksPage extends StatefulWidget {
  final InterestingTasksListKind listKind;

  const InterestingTasksPage({
    super.key,
    this.listKind = InterestingTasksListKind.interesting,
  });

  @override
  State<InterestingTasksPage> createState() => _InterestingTasksPageState();
}

class _InterestingTasksPageState extends State<InterestingTasksPage> {
  late final InterestingTaskRemoteDataSource _ds;
  List<InterestingTaskModel>? _tasks;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _ds = InterestingTaskRemoteDataSourceImpl(dio: sl<DioClient>().dio);
    _load();
  }

  @override
  void didUpdateWidget(covariant InterestingTasksPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listKind != widget.listKind) {
      _tasks = null;
      _load();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _tasks = null;
    });
    try {
      final tasks = await _ds.getTasks(listKind: widget.listKind);
      if (mounted) {
        setState(() {
          _tasks = tasks;
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = context.locale.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.listKind == InterestingTasksListKind.project
              ? context.tr('menu_projects')
              : context.tr('periodic_qiziqarli'),
        ),
        centerTitle: true,
        actions: [
          if (sl<AuthSession>().isLoggedIn &&
              widget.listKind != InterestingTasksListKind.project)
            IconButton(
              icon: const Icon(Icons.assignment_turned_in_outlined),
              tooltip: lang == 'uz' ? 'Mening javoblarim' : 'My submissions',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MySubmissionsPage()),
              ),
            ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
                        const SizedBox(height: 12),
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: _load, child: Text(lang == 'uz' ? 'Qayta urinish' : 'Retry')),
                      ],
                    ),
                  ),
                )
              : _tasks!.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.listKind == InterestingTasksListKind.project
                                ? Icons.folder_special_outlined
                                : Icons.lightbulb_outline,
                            size: 64,
                            color: Theme.of(context).hintColor,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.listKind == InterestingTasksListKind.project
                                ? context.tr('empty_projects_tasks')
                                : context.tr('empty_interesting_tasks'),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _tasks!.length,
                        itemBuilder: (context, i) {
                          final isProject = widget.listKind ==
                              InterestingTasksListKind.project;
                          final previousMs =
                              i > 0 ? _tasks![i - 1].mySubmission : null;
                          final previousTaskBlocksStart = !isProject &&
                              i > 0 &&
                              !submissionAllowsNextInterestingTask(previousMs);
                          return _TaskCard(
                            task: _tasks![i],
                            ds: _ds,
                            isDark: isDark,
                            lang: lang,
                            onRefresh: _load,
                            listKind: widget.listKind,
                            isProject: isProject,
                            previousTaskBlocksStart: previousTaskBlocksStart,
                          );
                        },
                      ),
                    ),
    );
  }
}

class _TaskCard extends StatefulWidget {
  final InterestingTaskModel task;
  final InterestingTaskRemoteDataSource ds;
  final bool isDark;
  final String lang;
  final VoidCallback onRefresh;
  final InterestingTasksListKind listKind;
  /// Loyihalar — faqat matn o‘qish (Nazariy kabi), quiz yo‘q.
  final bool isProject;
  /// Oldingi topshiriq natijasi (tekshirilgan va ko‘rinadigan) bo‘lmaguncha keyingi «Boshlash» bloklanadi.
  final bool previousTaskBlocksStart;

  const _TaskCard({
    required this.task,
    required this.ds,
    required this.isDark,
    required this.lang,
    required this.onRefresh,
    required this.listKind,
    required this.isProject,
    required this.previousTaskBlocksStart,
  });

  @override
  State<_TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<_TaskCard> {
  bool _loadingResult = false;

  Future<void> _openResult(int submissionId) async {
    setState(() => _loadingResult = true);
    try {
      final sub = await widget.ds.mySubmissionDetail(submissionId);
      if (!mounted) return;
      await Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (_) => InterestingTaskSubmissionDetailPage(sub: sub),
        ),
      );
      widget.onRefresh();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.lang == 'uz' ? 'Xatolik' : 'Error'}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loadingResult = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final isDark = widget.isDark;
    final lang = widget.lang;

    if (widget.isProject) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () {
              Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => InterestingTaskReaderPage(
                    taskId: task.id,
                    ds: widget.ds,
                    titleHint: task.title,
                    expectedKind: widget.listKind,
                  ),
                ),
              );
            },
            child: Ink(
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black26
                        : Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.primaryPurple.withOpacity(0.22)
                            : const Color(0xFFF3E5F5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.folder_special_outlined,
                        color: AppColors.primaryPurple,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                          if (task.description != null &&
                              task.description!.trim().isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              task.description!,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.35,
                                color: isDark
                                    ? Colors.white54
                                    : AppColors.textSecondary,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: isDark ? Colors.white38 : AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    final ms = task.mySubmission;

    Widget action;
    if (ms == null) {
      if (widget.previousTaskBlocksStart) {
        action = Opacity(
          opacity: 0.55,
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    lang == 'uz'
                        ? 'Avvalgi topshiriq natijasi chiqmaguncha keyingisini boshlash mumkin emas'
                        : (lang == 'ru'
                            ? 'Следующее задание доступно после результата по предыдущему'
                            : 'Finish the previous task and wait for your result first'),
                  ),
                  backgroundColor: Colors.red.shade700,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              lang == 'uz' ? 'Boshlash' : (lang == 'ru' ? 'Начать' : 'Start'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      } else {
        action = ElevatedButton(
          onPressed: () => Navigator.push<void>(
            context,
            MaterialPageRoute<void>(
              builder: (_) => TaskQuizPage(
                taskId: task.id,
                taskTitle: task.title,
                ds: widget.ds,
                expectedKind: widget.listKind,
              ),
            ),
          ).then((_) => widget.onRefresh()),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryPurple,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            lang == 'uz' ? 'Boshlash' : (lang == 'ru' ? 'Начать' : 'Start'),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      }
    } else if (ms.status == 'pending') {
      action = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.hourglass_top_rounded, size: 18, color: Colors.amber.shade800),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              lang == 'uz'
                  ? 'Tekshirilmoqda'
                  : (lang == 'ru' ? 'На проверке' : 'Under review'),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.amber.shade900,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      );
    } else if (ms.status == 'checked' && !ms.resultVisible) {
      action = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_outline, size: 18, color: AppColors.primaryPurple),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              lang == 'uz'
                  ? 'Natija kutilmoqda'
                  : (lang == 'ru' ? 'Ожидание результата' : 'Awaiting result'),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: AppColors.primaryPurple,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      );
    } else if (ms.status == 'checked' && ms.resultVisible) {
      action = ElevatedButton(
        onPressed: _loadingResult ? null : () => _openResult(ms.id),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPurple,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _loadingResult
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Text(
                lang == 'uz' ? 'Natija' : (lang == 'ru' ? 'Результат' : 'Result'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
      );
    } else {
      action = const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFFAB47BC).withOpacity(0.22) : const Color(0xFFF3E5F5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFAB47BC), size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lang == 'uz'
                        ? '${task.questionsCount} ta savol'
                        : (lang == 'ru' ? '${task.questionsCount} вопросов' : '${task.questionsCount} questions'),
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white54 : AppColors.textSecondary,
                    ),
                  ),
                  if (task.description != null && task.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      task.description!,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white38 : AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 132),
              child: Align(
                alignment: Alignment.centerRight,
                child: action,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
