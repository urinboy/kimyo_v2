import 'dart:convert';
import 'dart:math' show Random;

import 'package:flutter/material.dart';

import '../../core/auth/auth_session.dart';
import '../../core/config/mobile_api_settings.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/network/api_storage_url.dart';
import '../../core/network/dio_client.dart';
import '../../core/theme/colors.dart';
import '../../data/datasources/interesting_task_remote_data_source.dart';
import '../../injection_container.dart';
import 'task_submitted_page.dart';

class TaskQuizPage extends StatefulWidget {
  final int taskId;
  final String taskTitle;
  final InterestingTaskRemoteDataSource ds;
  final InterestingTasksListKind expectedKind;

  const TaskQuizPage({
    super.key,
    required this.taskId,
    required this.taskTitle,
    required this.ds,
    this.expectedKind = InterestingTasksListKind.interesting,
  });

  @override
  State<TaskQuizPage> createState() => _TaskQuizPageState();
}

class _TaskQuizPageState extends State<TaskQuizPage> {
  TaskWithQuestionsModel? _task;
  bool _loading = true;
  String? _error;
  bool _submitting = false;

  final Map<int, TextEditingController> _answerCtrl = {};
  final Map<int, String> _matchAnswers = {};
  final _formKey = GlobalKey<FormState>();
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;

  int get _qCount => _task?.questions.length ?? 0;
  int get _submitIdx => _qCount;
  int get _totalPages => _qCount + 1;

  @override
  void initState() {
    super.initState();
    _loadTask();
  }

  @override
  void dispose() {
    for (final c in _answerCtrl.values) {
      c.dispose();
    }
    _pageCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadTask() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    for (final c in _answerCtrl.values) {
      c.dispose();
    }
    _answerCtrl.clear();
    _matchAnswers.clear();
    try {
      final task = await widget.ds.getTask(
        widget.taskId,
        expectedKind: widget.expectedKind,
      );
      if (!mounted) return;
      if (task.questions.isEmpty) {
        setState(() {
          _error = context.locale.languageCode == 'uz'
              ? "Bu topshiriqda hali savollar yo'q"
              : 'No questions in this task';
          _loading = false;
        });
        return;
      }
      for (final q in task.questions) {
        if (q.questionType == 'match') {
          _matchAnswers[q.id] = jsonEncode({'pairs': <List<int>>[]});
        } else if (q.questionType == 'word_search') {
          _matchAnswers[q.id] = jsonEncode({'found_ids': <int>[]});
        } else if (q.questionType == 'matrix_classification') {
          _matchAnswers[q.id] = jsonEncode({
            'method': <String, String>{},
            'order': <String, int>{},
          });
        } else {
          _answerCtrl[q.id] = TextEditingController();
        }
      }
      setState(() {
        _task = task;
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _submit() async {
    final lang = context.locale.languageCode;
    if (!sl<AuthSession>().isLoggedIn) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(lang == 'uz' ? 'Topshirish uchun tizimga kiring' : 'Please log in to submit'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    for (final q in _task!.questions) {
      if (q.questionType == 'match') {
        final raw = _matchAnswers[q.id];
        if (raw == null || raw.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  lang == 'uz'
                      ? 'Barcha juftlashlarni to\'ldiring'
                      : 'Complete all pairs',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
        try {
          final decoded = jsonDecode(raw) as Map<String, dynamic>;
          final pairs = decoded['pairs'] as List<dynamic>?;
          if (pairs == null || pairs.length != q.matchLeft.length) {
            throw const FormatException('pairs');
          }
        } catch (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  lang == 'uz'
                      ? 'Juftlash: barcha qatorlar bog\'lanishi kerak'
                      : 'Matching: link all rows',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }
      if (q.questionType == 'matrix_classification') {
        final raw = _matchAnswers[q.id];
        if (raw == null || raw.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  lang == 'uz'
                      ? 'Jadval savolida kamida usullarni belgilang'
                      : 'Fill matrix methods before submit',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
        try {
          final decoded = jsonDecode(raw) as Map<String, dynamic>;
          final methodMap = decoded['method'] as Map<String, dynamic>?;
          final rows = q.matrixRows;
          final solvedRows = rows.where((r) {
            final method = methodMap?[r.id.toString()]?.toString();
            return method == 'solve' || method == 'ammonia' || method == 'none';
          }).length;
          if (rows.isNotEmpty && solvedRows < rows.length) {
            throw const FormatException('matrix-methods');
          }
        } catch (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  lang == 'uz'
                      ? 'Jadval: har bir qator uchun usulni tanlang'
                      : 'Matrix: select method for each row',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }
      // word_search uchun qat’iy validatsiya yo’q — faqat JSON mavjudligini tekshirish
    }

    setState(() => _submitting = true);

    final answers = _task!.questions.map((q) {
      if (
          q.questionType == 'match' ||
          q.questionType == 'word_search' ||
          q.questionType == 'matrix_classification') {
        return {
          'question_id': q.id,
          'answer_text': _matchAnswers[q.id] ?? '{}',
        };
      }
      return {
        'question_id': q.id,
        'answer_text': _answerCtrl[q.id]!.text.trim(),
      };
    }).toList();

    try {
      final submissionId = await widget.ds.submit(
        taskId: widget.taskId,
        answers: answers,
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => TaskSubmittedPage(submissionId: submissionId, ds: widget.ds),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${lang == 'uz' ? 'Xatolik' : 'Error'}: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  bool _isQuestionPageComplete(int pageIndex) {
    if (_task == null || pageIndex < 0 || pageIndex >= _qCount) return true;
    final q = _task!.questions[pageIndex];
    if (q.questionType == 'match') {
      final raw = _matchAnswers[q.id];
      if (raw == null || raw.isEmpty) return false;
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        final pairs = decoded['pairs'] as List<dynamic>?;
        return pairs != null && pairs.length == q.matchLeft.length;
      } catch (_) {
        return false;
      }
    }
    if (q.questionType == 'word_search') {
      // Kamida 1 ta so'z topilgan bo'lsa to'liq hisoblanadi
      final raw = _matchAnswers[q.id];
      if (raw == null || raw.isEmpty) return false;
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        final foundIds = decoded['found_ids'] as List<dynamic>?;
        return foundIds != null && foundIds.isNotEmpty;
      } catch (_) {
        return false;
      }
    }
    if (q.questionType == 'matrix_classification') {
      final raw = _matchAnswers[q.id];
      if (raw == null || raw.isEmpty) return false;
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        final methodMap = decoded['method'] as Map<String, dynamic>?;
        if (methodMap == null) return false;
        if (q.matrixRows.isEmpty) return false;
        return q.matrixRows.every((row) {
          final m = methodMap[row.id.toString()]?.toString();
          return m == 'solve' || m == 'ammonia' || m == 'none';
        });
      } catch (_) {
        return false;
      }
    }
    final text = _answerCtrl[q.id]?.text.trim() ?? '';
    return text.isNotEmpty;
  }

  void _nextPage() {
    final lang = context.locale.languageCode;
    if (_currentPage < _submitIdx && !_isQuestionPageComplete(_currentPage)) {
      final q = _task!.questions[_currentPage];
      if (q.questionType == 'match') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              lang == 'uz'
                  ? 'Juftlash: barcha qatorlarni bog\'lang'
                  : 'Matching: link all rows',
            ),
            backgroundColor: Colors.red,
          ),
        );
      } else if (q.questionType == 'word_search') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              lang == 'uz'
                  ? 'Kamida 1 ta so\'zni panjarada toping'
                  : 'Find at least 1 word in the grid',
            ),
            backgroundColor: Colors.red,
          ),
        );
      } else if (q.questionType == 'matrix_classification') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              lang == 'uz'
                  ? 'Jadval: har bir qator uchun usulni tanlang'
                  : 'Matrix: select method for each row',
            ),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              lang == 'uz' ? 'Javobingizni kiriting' : 'Enter your answer',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    if (_currentPage < _totalPages - 1) {
      _pageCtrl.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageCtrl.previousPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.taskTitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Text(
                '${_currentPage + 1}/$_totalPages',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : _buildQuiz(context, isDark),
    );
  }

  Widget _buildError() {
    final lang = context.locale.languageCode;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 56, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _loadTask, child: Text(lang == 'uz' ? 'Qayta urinish' : 'Retry')),
          ],
        ),
      ),
    );
  }

  Widget _buildQuiz(BuildContext context, bool isDark) {
    final lang = context.locale.languageCode;
    final accent = AppColors.primaryPurple;
    final n = _qCount;
    final isSubmit = _currentPage >= _submitIdx;
    final progress = n == 0 ? 0.0 : (isSubmit ? 1.0 : (_currentPage + 1) / n);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isSubmit
                          ? (lang == 'uz' ? 'Topshirish' : 'Submit')
                          : (lang == 'uz' ? 'Savol ${_currentPage + 1}/$n' : 'Question ${_currentPage + 1}/$n'),
                      style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
                    ),
                    Text(
                      lang == 'uz' ? 'Topshiriq' : 'Task',
                      style: TextStyle(color: accent, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: isDark ? Colors.white10 : Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(accent),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageCtrl,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => _currentPage = i),
              children: [
                ..._task!.questions.asMap().entries.map((e) => _buildQuestionPage(context, isDark, e.key, e.value)),
                _buildSubmitPage(context, isDark),
              ],
            ),
          ),
          _buildNavBar(context, isDark),
        ],
      ),
    );
  }

  Widget _questionTypeChip(String questionType) {
    final label = switch (questionType) {
      'image' => 'Rasm',
      'match' => 'Juftlash',
      'word_search' => "So'z qidirish",
      'matrix_classification' => 'Jadval',
      _ => 'Matn',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryPurple.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primaryPurple.withOpacity(0.35)),
      ),
      child: Text(
        label,
        style: const TextStyle(color: AppColors.primaryPurple, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _questionPageHeader(int index, TaskQuestionModel question) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryPurple,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Savol ${index + 1}',
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 8),
        _questionTypeChip(question.questionType),
        const SizedBox(width: 8),
        Text(
          '/ ${_task!.questions.length}',
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildQuestionPage(BuildContext context, bool isDark, int index, TaskQuestionModel question) {
    if (question.questionType == 'matrix_classification') {
      return _MatrixClassificationQuestionPage(
        index: index,
        total: _task!.questions.length,
        question: question,
        isDark: isDark,
        onAnswerJson: (json) {
          _matchAnswers[question.id] = json;
        },
        initialJson: _matchAnswers[question.id],
      );
    }

    if (question.questionType == 'word_search') {
      return _WordSearchQuestionPage(
        index: index,
        total: _task!.questions.length,
        question: question,
        isDark: isDark,
        onAnswerJson: (json) {
          _matchAnswers[question.id] = json;
        },
        initialJson: _matchAnswers[question.id],
      );
    }

    if (question.questionType == 'match') {
      return _MatchQuestionPage(
        index: index,
        total: _task!.questions.length,
        question: question,
        isDark: isDark,
        onAnswerJson: (json) {
          _matchAnswers[question.id] = json;
        },
        initialJson: _matchAnswers[question.id],
      );
    }

    final hasImage = question.questionType == 'image' &&
        question.imageUrl != null &&
        question.imageUrl!.trim().isNotEmpty;
    final dioBase = sl<DioClient>().dio.options.baseUrl;
    final resolvedImageUrl = resolveApiStorageFileUrl(dioBase, question.imageUrl);
    final cardColor = isDark ? AppColors.cardDark : Colors.white;
    final borderColor = isDark ? Colors.white10 : Colors.grey[200]!;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final lang = context.locale.languageCode;

    String imageLoadErrorHint() {
      if (lang == 'ru') {
        return 'Проверьте сеть и что файл есть в storage (php artisan storage:link).';
      }
      if (lang == 'uz') {
        return 'Tarmoqni tekshiring. Serverda php artisan storage:link bajarilgan bo‘lishi kerak.';
      }
      return 'Check your network and storage:link on the server.';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _questionPageHeader(index, question),
          if (hasImage) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ColoredBox(
                color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey[100]!,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final maxH = MediaQuery.of(context).size.height * 0.48;
                    return ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: maxH),
                      child: Image.network(
                        resolvedImageUrl,
                        width: double.infinity,
                        fit: BoxFit.contain,
                        headers: MobileApiSettings.apiKey.isEmpty
                            ? null
                            : {'X-API-Key': MobileApiSettings.apiKey},
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return SizedBox(
                            height: 200,
                            width: double.infinity,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: progress.expectedTotalBytes != null
                                    ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                                    : null,
                                color: AppColors.primaryPurple,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.broken_image_outlined, size: 44, color: Colors.grey[600]),
                              const SizedBox(height: 10),
                              Text(
                                lang == 'ru'
                                    ? 'Изображение не загрузилось'
                                    : lang == 'uz'
                                        ? 'Rasm yuklanmadi'
                                        : 'Image failed to load',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                imageLoadErrorHint(),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey[600], fontSize: 12, height: 1.35),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              question.body,
              style: TextStyle(color: textColor, fontSize: 16, height: 1.6),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            context.locale.languageCode == 'uz' ? 'Javobingiz:' : 'Your answer:',
            style: TextStyle(color: Colors.grey[600], fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _answerCtrl[question.id],
            style: TextStyle(color: textColor, fontSize: 15),
            minLines: 4,
            maxLines: 10,
            validator: (v) => v == null || v.trim().isEmpty
                ? (context.locale.languageCode == 'uz' ? 'Javobingizni kiriting' : 'Enter your answer')
                : null,
            decoration: _inputDecor(
              label: context.locale.languageCode == 'uz' ? 'Javobingizni yozing...' : 'Type your answer...',
              icon: null,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitPage(BuildContext context, bool isDark) {
    final lang = context.locale.languageCode;
    final cardColor = isDark ? AppColors.cardDark : Colors.white;
    final borderColor = isDark ? Colors.white10 : Colors.grey[200]!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: borderColor, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check_circle_outline, color: AppColors.primaryPurple, size: 48),
                ),
                const SizedBox(height: 20),
                Text(
                  lang == 'uz' ? 'Javoblar tayyor!' : 'Answers ready!',
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  lang == 'uz'
                      ? "Siz ${_task!.questions.length} ta savolga javob berdingiz.\nNatijani o'qituvchi tekshirib beradi."
                      : 'You answered ${_task!.questions.length} question(s).\nYour teacher will review the result.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14, height: 1.6),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primaryPurple.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.primaryPurple, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          lang == 'uz'
                              ? "Natija tayyor bo'lgach, o'qituvchi sizga ruxsat beradi va ilovada ko'rish mumkin bo'ladi."
                              : 'When your teacher publishes the result, you will see it in the app.',
                          style: TextStyle(color: Colors.grey[700], fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _submitting ? null : _submit,
              icon: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send_rounded, color: Colors.white),
              label: Text(
                _submitting ? (lang == 'uz' ? 'Yuklanmoqda...' : 'Loading...') : (lang == 'uz' ? 'Topshirish' : 'Submit'),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavBar(BuildContext context, bool isDark) {
    final lang = context.locale.languageCode;
    final isLast = _currentPage == _totalPages - 1;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + bottom),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.grey[200]!)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentPage > 0)
            OutlinedButton.icon(
              onPressed: _prevPage,
              icon: Icon(Icons.arrow_back_ios, size: 16, color: Colors.grey[700]),
              label: Text(lang == 'uz' ? 'Orqaga' : 'Back', style: TextStyle(color: Colors.grey[800])),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey[400]!),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              ),
            )
          else
            const SizedBox.shrink(),
          const Spacer(),
          if (!isLast)
            ElevatedButton.icon(
              onPressed: _nextPage,
              icon: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
              label: Text(
                lang == 'uz' ? 'Keyingi' : 'Next',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                elevation: 0,
              ),
            ),
        ],
      ),
    );
  }

  InputDecoration _inputDecor({required String label, required IconData? icon, required bool isDark}) {
    final fill = isDark ? AppColors.cardDark : Colors.grey[50]!;
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[600]),
      prefixIcon: icon != null ? Icon(icon, color: AppColors.primaryPurple, size: 20) : null,
      filled: true,
      fillColor: fill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primaryPurple, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }
}

class _MatrixClassificationQuestionPage extends StatefulWidget {
  final int index;
  final int total;
  final TaskQuestionModel question;
  final bool isDark;
  final ValueChanged<String> onAnswerJson;
  final String? initialJson;

  const _MatrixClassificationQuestionPage({
    required this.index,
    required this.total,
    required this.question,
    required this.isDark,
    required this.onAnswerJson,
    this.initialJson,
  });

  @override
  State<_MatrixClassificationQuestionPage> createState() => _MatrixClassificationQuestionPageState();
}

class _MatrixClassificationQuestionPageState extends State<_MatrixClassificationQuestionPage> {
  final Map<int, String> _method = {};
  final Map<int, TextEditingController> _orderCtrls = {};

  @override
  void initState() {
    super.initState();
    for (final row in widget.question.matrixRows) {
      _method[row.id] = '';
      _orderCtrls[row.id] = TextEditingController();
    }
    final raw = widget.initialJson;
    if (raw != null && raw.isNotEmpty) {
      try {
        final m = jsonDecode(raw) as Map<String, dynamic>;
        final methodMap = (m['method'] as Map?)?.map((k, v) => MapEntry(k.toString(), v.toString())) ?? {};
        final orderMap = (m['order'] as Map?)?.map((k, v) => MapEntry(k.toString(), v)) ?? {};
        for (final row in widget.question.matrixRows) {
          final idKey = row.id.toString();
          final selected = methodMap[idKey];
          if (selected == 'solve' || selected == 'ammonia' || selected == 'none') {
            _method[row.id] = selected!;
          }
          final ord = orderMap[idKey];
          if (ord != null) {
            _orderCtrls[row.id]?.text = ord.toString();
          }
        }
      } catch (_) {
        // ignore invalid draft
      }
    }
    _emit();
  }

  @override
  void dispose() {
    for (final c in _orderCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _emit() {
    final methodOut = <String, String>{};
    final orderOut = <String, int>{};
    for (final row in widget.question.matrixRows) {
      final selected = _method[row.id] ?? '';
      if (selected == 'solve' || selected == 'ammonia' || selected == 'none') {
        methodOut[row.id.toString()] = selected;
      }
      final rawOrder = _orderCtrls[row.id]?.text.trim() ?? '';
      if (rawOrder.isNotEmpty) {
        final n = int.tryParse(rawOrder);
        if (n != null && n > 0) {
          orderOut[row.id.toString()] = n;
        }
      }
    }
    widget.onAnswerJson(jsonEncode({'method': methodOut, 'order': orderOut}));
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    final isDark = widget.isDark;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final border = isDark ? Colors.white12 : Colors.grey[300]!;
    final lang = Localizations.localeOf(context).languageCode;
    final sequenceEnabled = q.matrixSequence?.enabled ?? true;
    final sequenceLabel = q.matrixSequence?.label?.trim().isNotEmpty == true
        ? q.matrixSequence!.label!
        : (lang == 'uz'
            ? 'Ketma-ketlik'
            : lang == 'ru'
                ? 'Последовательность'
                : 'Sequence');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Savol ${widget.index + 1}',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primaryPurple.withValues(alpha: 0.35)),
                ),
                child: const Text(
                  'Jadval',
                  style: TextStyle(color: AppColors.primaryPurple, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Text('/ ${widget.total}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!, width: 2),
            ),
            child: Text(q.body, style: TextStyle(color: textColor, fontSize: 15, height: 1.6)),
          ),
          const SizedBox(height: 10),
          Text(
            lang == 'uz'
                ? 'Har bir qator uchun usulni tanlang. Ketma-ketlik ixtiyoriy.'
                : lang == 'ru'
                    ? 'Для каждой строки выберите метод. Последовательность необязательна.'
                    : 'Choose method for each row. Sequence is optional.',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          const SizedBox(height: 12),
          ...q.matrixRows.map((row) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#${row.id}  ${row.text}',
                    style: TextStyle(color: textColor, fontSize: 14, height: 1.45, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  InputDecorator(
                    decoration: InputDecoration(
                      labelText: lang == 'uz'
                          ? 'Usul'
                          : (lang == 'ru' ? 'Метод' : 'Method'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: (_method[row.id]?.isNotEmpty ?? false) ? _method[row.id] : null,
                        hint: Text(lang == 'uz' ? 'Tanlang' : (lang == 'ru' ? 'Выберите' : 'Select')),
                        items: [
                          DropdownMenuItem(
                            value: 'none',
                            child: Text(
                              lang == 'ru'
                                  ? 'Не относится'
                                  : lang == 'uz'
                                      ? 'Tegishli emas'
                                      : 'Not applicable',
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'solve',
                            child: Text(lang == 'ru' ? 'Сольве' : 'Solve'),
                          ),
                          DropdownMenuItem(
                            value: 'ammonia',
                            child: Text(lang == 'ru' ? 'Аммиачный' : 'Ammiakli'),
                          ),
                        ],
                        onChanged: (v) {
                          setState(() {
                            _method[row.id] = v ?? '';
                          });
                          _emit();
                        },
                      ),
                    ),
                  ),
                  if (sequenceEnabled) ...[
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _orderCtrls[row.id],
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _emit(),
                      decoration: InputDecoration(
                        labelText: sequenceLabel,
                        hintText: lang == 'uz' ? 'Masalan: 5' : (lang == 'ru' ? 'Например: 5' : 'e.g. 5'),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        isDense: true,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

enum _TapSide { left, right }

class _MatchQuestionPage extends StatefulWidget {
  final int index;
  final int total;
  final TaskQuestionModel question;
  final bool isDark;
  final ValueChanged<String> onAnswerJson;
  final String? initialJson;

  const _MatchQuestionPage({
    required this.index,
    required this.total,
    required this.question,
    required this.isDark,
    required this.onAnswerJson,
    this.initialJson,
  });

  @override
  State<_MatchQuestionPage> createState() => _MatchQuestionPageState();
}

class _MatchQuestionPageState extends State<_MatchQuestionPage> {
  final Map<int, int> _leftToRight = {};
  _TapSide? _pendingSide;
  int? _pendingIdx;
  late final List<int> _leftOrder;
  late final List<int> _rightOrder;
  static const List<Color> _pairPalette = [
    Color(0xFF7E57C2), // purple
    Color(0xFF26A69A), // teal
    Color(0xFF42A5F5), // blue
    Color(0xFFEF5350), // red
    Color(0xFFFFA726), // orange
    Color(0xFF66BB6A), // green
    Color(0xFFAB47BC), // violet
    Color(0xFF5C6BC0), // indigo
    Color(0xFF8D6E63), // brown
    Color(0xFFEC407A), // pink
  ];

  @override
  void initState() {
    super.initState();
    final n = widget.question.matchLeft.length;
    // Foydalanuvchi talabi: chap ustun bazadagi tartibda qoladi.
    _leftOrder = n == 0 ? <int>[] : List<int>.generate(n, (i) => i);
    // O'ng ustun har safar random bo'ladi.
    _rightOrder = n == 0 ? <int>[] : (List<int>.generate(n, (i) => i)..shuffle(Random()));
    final raw = widget.initialJson;
    if (raw != null && raw.isNotEmpty) {
      try {
        final m = jsonDecode(raw) as Map<String, dynamic>;
        final pairs = m['pairs'] as List<dynamic>?;
        if (pairs != null) {
          for (final p in pairs) {
            final pair = p as List<dynamic>;
            _leftToRight[pair[0] as int] = pair[1] as int;
          }
        }
      } catch (_) {}
    }
  }

  List<List<int>> _serializePairs() => _leftToRight.entries.map((e) => [e.key, e.value]).toList();

  Color _pairBaseColor(int leftIdx) => _pairPalette[leftIdx % _pairPalette.length];

  int? _leftIndexForRight(int rightIdx) {
    for (final e in _leftToRight.entries) {
      if (e.value == rightIdx) return e.key;
    }
    return null;
  }

  String _alphaBadge(int index) {
    var n = index + 1;
    final out = StringBuffer();
    while (n > 0) {
      final rem = (n - 1) % 26;
      out.writeCharCode(65 + rem);
      n = (n - 1) ~/ 26;
    }
    return out.toString().split('').reversed.join();
  }

  void _emit() {
    widget.onAnswerJson(jsonEncode({'pairs': _serializePairs()}));
  }

  void _onChap(int i) {
    if (_leftToRight.containsKey(i)) {
      if (_pendingSide == _TapSide.right && _pendingIdx != null) {
        setState(() {
          _leftToRight.remove(i);
          _leftToRight[i] = _pendingIdx!;
          _pendingSide = null;
          _pendingIdx = null;
        });
        _emit();
        return;
      }
      setState(() => _leftToRight.remove(i));
      _emit();
      return;
    }
    if (_pendingSide == _TapSide.left && _pendingIdx == i) {
      setState(() {
        _pendingSide = null;
        _pendingIdx = null;
      });
      return;
    }
    if (_pendingSide == _TapSide.right && _pendingIdx != null) {
      setState(() {
        _leftToRight[i] = _pendingIdx!;
        _pendingSide = null;
        _pendingIdx = null;
      });
      _emit();
      return;
    }
    setState(() {
      _pendingSide = _TapSide.left;
      _pendingIdx = i;
    });
  }

  void _onOng(int j) {
    int? chapIdx;
    for (final e in _leftToRight.entries) {
      if (e.value == j) {
        chapIdx = e.key;
        break;
      }
    }
    if (chapIdx != null) {
      if (_pendingSide == _TapSide.left && _pendingIdx != null) {
        setState(() {
          _leftToRight.remove(chapIdx);
          _leftToRight[_pendingIdx!] = j;
          _pendingSide = null;
          _pendingIdx = null;
        });
        _emit();
        return;
      }
      setState(() => _leftToRight.remove(chapIdx));
      _emit();
      return;
    }
    if (_pendingSide == _TapSide.right && _pendingIdx == j) {
      setState(() {
        _pendingSide = null;
        _pendingIdx = null;
      });
      return;
    }
    if (_pendingSide == _TapSide.left && _pendingIdx != null) {
      setState(() {
        _leftToRight[_pendingIdx!] = j;
        _pendingSide = null;
        _pendingIdx = null;
      });
      _emit();
      return;
    }
    setState(() {
      _pendingSide = _TapSide.right;
      _pendingIdx = j;
    });
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    final isDark = widget.isDark;
    final cardColor = isDark ? AppColors.cardDark : Colors.white;
    final borderBase = isDark ? Colors.white10 : Colors.grey[200]!;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final lang = Localizations.localeOf(context).languageCode;
    final shuffleHint = switch (lang) {
      'ru' =>
        'Левая колонка фиксированная. Правая — каждый раз в случайном порядке. Нажмите элемент с одной стороны, затем его пару с другой.',
      'en' =>
        'Left column stays fixed. Right column is randomized each time. To match: tap one row on either side, then its pair on the other side.',
      _ =>
        'Chap ustun o‘zgarmaydi, o‘ng ustun esa har safar tasodifiy chiqadi. Mos keluvchilarni bog‘lash: '
            'avval bir tomondan bitta qator, keyin juftini bosing.',
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Savol ${widget.index + 1}',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primaryPurple.withOpacity(0.35)),
                ),
                child: const Text(
                  'Juftlash',
                  style: TextStyle(color: AppColors.primaryPurple, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Text('/ ${widget.total}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderBase, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(q.body, style: TextStyle(color: textColor, fontSize: 16, height: 1.6)),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primaryPurple.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primaryPurple.withOpacity(0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.shuffle_rounded, size: 18, color: AppColors.primaryPurple.withOpacity(0.9)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    shuffleHint,
                    style: TextStyle(color: Colors.grey[700], fontSize: 12.5, height: 1.45),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _matchColumn(
                  title: 'Chap',
                  items: q.matchLeft,
                  order: _leftOrder,
                  isChap: true,
                  isDark: isDark,
                  textColor: textColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _matchColumn(
                  title: 'O‘ng',
                  items: q.matchRight,
                  order: _rightOrder,
                  isChap: false,
                  isDark: isDark,
                  textColor: textColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _matchColumn({
    required String title,
    required List<String> items,
    required List<int> order,
    required bool isChap,
    required bool isDark,
    required Color textColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.primaryPurple.withOpacity(isDark ? 0.18 : 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primaryPurple.withOpacity(0.25)),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.primaryPurple,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(order.length, (v) {
          final logicalIdx = order[v];
          final isPaired = isChap
              ? _leftToRight.containsKey(logicalIdx)
              : _leftToRight.values.contains(logicalIdx);
          final isPending = _pendingSide != null &&
              _pendingIdx == logicalIdx &&
              ((isChap && _pendingSide == _TapSide.left) || (!isChap && _pendingSide == _TapSide.right));

          Color bg = isDark ? AppColors.cardDark : Colors.white;
          Color borderColor = isDark ? Colors.white12 : Colors.grey[300]!;
          double borderW = 2;
          final pairLeftIdx = isChap ? logicalIdx : _leftIndexForRight(logicalIdx);
          final pairColor = pairLeftIdx == null ? null : _pairBaseColor(pairLeftIdx);

          if (isPaired && pairColor != null) {
            bg = pairColor.withOpacity(isDark ? 0.24 : 0.10);
            borderColor = pairColor.withOpacity(0.82);
          } else if (isPending) {
            bg = AppColors.primaryPurple.withOpacity(isDark ? 0.2 : 0.1);
            borderColor = AppColors.primaryPurple.withOpacity(0.85);
          }

          final circleBg = isDark ? Colors.white10 : Colors.grey[100]!;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => isChap ? _onChap(logicalIdx) : _onOng(logicalIdx),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor, width: borderW),
                    boxShadow: [
                      if (!isPaired && !isPending)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: circleBg,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          isChap ? '${v + 1}' : _alphaBadge(v),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: (isPaired && pairColor != null)
                                ? pairColor.withOpacity(0.95)
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          items[logicalIdx],
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  Word Search savol sahifasi
// ══════════════════════════════════════════════════════════════════

typedef _CellKey = ({int row, int col});

class _WordSearchQuestionPage extends StatefulWidget {
  final int index;
  final int total;
  final TaskQuestionModel question;
  final bool isDark;
  final ValueChanged<String> onAnswerJson;
  final String? initialJson;

  const _WordSearchQuestionPage({
    required this.index,
    required this.total,
    required this.question,
    required this.isDark,
    required this.onAnswerJson,
    this.initialJson,
  });

  @override
  State<_WordSearchQuestionPage> createState() => _WordSearchQuestionPageState();
}

class _WordSearchQuestionPageState extends State<_WordSearchQuestionPage> {
  final Set<_CellKey> _foundCells = {};
  final List<_CellKey> _selectedCells = [];
  final Set<_CellKey> _selectedSet = {};
  final List<int> _foundClueIds = [];
  String? _lastFoundFormula;

  @override
  void initState() {
    super.initState();
    final raw = widget.initialJson;
    if (raw != null && raw.isNotEmpty) {
      try {
        final m = jsonDecode(raw) as Map<String, dynamic>;
        final ids = (m['found_ids'] as List<dynamic>?)
                ?.map((e) => e as int)
                .toList() ??
            [];
        _foundClueIds.addAll(ids);
      } catch (_) {}
    }
  }

  void _onCellTap(int row, int col) {
    final key = (row: row, col: col);

    // Allaqachon topilgan hujayrani qayta tanlash mumkin emas
    if (_foundCells.contains(key)) return;

    // Tanlanganlar ro'yxatida oxirgi element bo'lsa — olib tashlash
    if (_selectedSet.contains(key)) {
      if (_selectedCells.isNotEmpty && _selectedCells.last == key) {
        setState(() {
          _selectedCells.removeLast();
          _selectedSet.remove(key);
        });
      }
      return;
    }

    setState(() {
      _selectedCells.add(key);
      _selectedSet.add(key);
      _lastFoundFormula = null;
    });

    _checkMatch();
  }

  void _checkMatch() {
    if (_selectedCells.isEmpty) return;
    final grid = widget.question.wordSearchGrid;
    final spelling = _selectedCells
        .map((k) => grid[k.row][k.col])
        .join()
        .toUpperCase();
    final reversed = spelling.split('').reversed.join();

    for (final clue in widget.question.wordSearchClues) {
      if (_foundClueIds.contains(clue.id)) continue;
      if (spelling == clue.answer || reversed == clue.answer) {
        setState(() {
          _foundCells.addAll(_selectedCells);
          _foundClueIds.add(clue.id);
          _selectedCells.clear();
          _selectedSet.clear();
          _lastFoundFormula = clue.formula;
        });
        _emit();
        return;
      }
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedCells.clear();
      _selectedSet.clear();
    });
  }

  void _emit() {
    widget.onAnswerJson(jsonEncode({'found_ids': _foundClueIds}));
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    final isDark = widget.isDark;
    final lang = Localizations.localeOf(context).languageCode;
    final grid = q.wordSearchGrid;
    final clues = q.wordSearchClues;
    // Har bir qatordagi ustun soni turlicha bo'lsa ham overflow bo'lmasin.
    final numCols = grid.isEmpty
        ? 1
        : grid.fold<int>(0, (maxCols, row) => row.length > maxCols ? row.length : maxCols);
    final foundCount = _foundClueIds.length;
    final totalClues = clues.length;

    final cardColor = isDark ? AppColors.cardDark : Colors.white;
    final borderBase = isDark ? Colors.white10 : Colors.grey[200]!;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;

    final hintText = switch (lang) {
      'ru' => 'Нажимайте на ячейки по порядку, чтобы собрать слово. Видны только формулы — найдите соответствующие термины в сетке!',
      'en' => 'Tap cells in order to spell a word. Only formulas are shown — find matching terms in the grid!',
      _ => 'Hujayralarga ketma-ket bosing va kimyoviy terminni tering. Faqat formulalar ko‘rinadi.',
    };

    final currentSpelling = _selectedCells.isEmpty
        ? ''
        : _selectedCells.map((k) => grid[k.row][k.col]).join();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Sarlavha ──
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Savol ${widget.index + 1}',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primaryGreen.withOpacity(0.4)),
                ),
                child: Text(
                  "So'z qidirish",
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('/ ${widget.total}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            ],
          ),
          const SizedBox(height: 16),

          // ── Savol matni ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderBase, width: 2),
            ),
            child: Text(q.body, style: TextStyle(color: textColor, fontSize: 15, height: 1.6)),
          ),
          const SizedBox(height: 12),

          // ── Yo'riqnoma ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.07),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primaryGreen.withOpacity(0.22)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 17, color: AppColors.primaryGreen.withOpacity(0.85)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hintText,
                    style: TextStyle(color: Colors.grey[700], fontSize: 12, height: 1.45),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Natija banneri ──
          if (_lastFoundFormula != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(isDark ? 0.18 : 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.green.shade400.withOpacity(0.6)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      lang == 'uz'
                          ? '🎉 Topildi: $_lastFoundFormula'
                          : lang == 'ru'
                              ? '🎉 Найдено: $_lastFoundFormula'
                              : '🎉 Found: $_lastFoundFormula',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ── Grid ──
          LayoutBuilder(
            builder: (ctx, constraints) {
              final availW = constraints.maxWidth;
              const gap = 4.0;
              // Hujayra marginlari o'rniga aniq gap ishlatamiz:
              // width = (N * cell) + ((N - 1) * gap)
              final rawSize = (availW - (numCols - 1) * gap) / numCols;
              // Kichik ekranlarda ham sig'ishi uchun minimumni pastroq olamiz.
              final cellSize = rawSize.clamp(20.0, 52.0);
              return Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderBase, width: 2),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: List.generate(grid.length, (r) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(grid[r].length, (c) {
                        final key = (row: r, col: c);
                        final isFound = _foundCells.contains(key);
                        final isSelected = _selectedSet.contains(key);
                        final isLast = _selectedCells.isNotEmpty && _selectedCells.last == key;

                        Color bgColor;
                        Color borderColor;
                        Color txtColor;

                        if (isFound) {
                          bgColor = Colors.green.withOpacity(isDark ? 0.25 : 0.15);
                          borderColor = Colors.green.shade400;
                          txtColor = Colors.green.shade700;
                        } else if (isSelected) {
                          bgColor = AppColors.primaryPurple.withOpacity(isDark ? 0.35 : 0.18);
                          borderColor = isLast
                              ? AppColors.primaryPurple
                              : AppColors.primaryPurple.withOpacity(0.55);
                          txtColor = AppColors.primaryPurple;
                        } else {
                          bgColor = isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50]!;
                          borderColor = isDark ? Colors.white12 : Colors.grey[300]!;
                          txtColor = textColor;
                        }

                        return Padding(
                          padding: EdgeInsets.only(right: c == grid[r].length - 1 ? 0 : gap),
                          child: GestureDetector(
                            onTap: () => _onCellTap(r, c),
                            child: Container(
                              width: cellSize,
                              height: cellSize,
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: borderColor, width: isSelected ? 2 : 1.5),
                              ),
                              alignment: Alignment.center,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  grid[r][c],
                                  style: TextStyle(
                                    color: txtColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: cellSize < 36 ? 11 : 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  }),
                ),
              );
            },
          ),
          const SizedBox(height: 14),

          // ── Joriy tanlov ──
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey[100]!,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _selectedCells.isEmpty
                          ? (isDark ? Colors.white12 : Colors.grey[300]!)
                          : AppColors.primaryPurple.withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    _selectedCells.isEmpty
                        ? (lang == 'uz' ? 'Hujayralarni bosing...' : 'Tap cells...')
                        : currentSpelling,
                    style: TextStyle(
                      color: _selectedCells.isEmpty ? Colors.grey[500] : AppColors.primaryPurple,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
              if (_selectedCells.isNotEmpty) ...[
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _clearSelection,
                  child: Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withOpacity(0.35)),
                    ),
                    child: const Icon(Icons.backspace_outlined, size: 20, color: Colors.red),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),

          // ── Izohlar (clues) ──
          Row(
            children: [
              Text(
                lang == 'uz'
                    ? 'Qidiriladigan so\'zlar'
                    : lang == 'ru'
                        ? 'Слова для поиска'
                        : 'Words to find',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$foundCount/$totalClues',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...clues.map((clue) {
            final isFound = _foundClueIds.contains(clue.id);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isFound
                    ? Colors.green.withOpacity(isDark ? 0.18 : 0.08)
                    : cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isFound
                      ? Colors.green.shade400.withOpacity(0.6)
                      : borderBase,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isFound
                          ? Colors.green.withOpacity(0.2)
                          : AppColors.primaryPurple.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: isFound
                        ? const Icon(Icons.check, size: 16, color: Colors.green)
                        : Text(
                            '${clue.id}',
                            style: const TextStyle(
                              color: AppColors.primaryPurple,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          clue.formula,
                          style: TextStyle(
                            color: isFound
                                ? Colors.green.shade700
                                : AppColors.primaryPurple,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isFound)
                    const Icon(Icons.check_circle, color: Colors.green, size: 22),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
