import 'package:flutter/material.dart';

import '../../core/auth/auth_session.dart';
import '../../core/network/dio_client.dart';
import '../../core/theme/colors.dart';
import '../../data/datasources/standalone_quiz_remote_data_source.dart';
import '../../injection_container.dart';

/// Serverdagi standalone (ilova) testi: savollar + variantlar.
/// Har savol javob tanlanganida darhol to'g'ri/noto'g'ri ko'rsatiladi.
/// Oxirida batafsil natija sahifasi chiqadi.
class StandaloneQuizPage extends StatefulWidget {
  final int quizId;
  final String title;

  const StandaloneQuizPage({super.key, required this.quizId, required this.title});

  @override
  State<StandaloneQuizPage> createState() => _StandaloneQuizPageState();
}

class _StandaloneQuizPageState extends State<StandaloneQuizPage> {
  late final StandaloneQuizRemoteDataSource _ds;
  ApiQuizDetail? _quiz;
  bool _loading = true;
  String? _error;
  int _idx = 0;
  // question_id → tanlangan option_id
  final Map<int, int> _chosen = {};
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _ds = StandaloneQuizRemoteDataSourceImpl(dio: sl<DioClient>().dio);
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final q = await _ds.getQuiz(widget.quizId);
      if (mounted) {
        setState(() {
          _quiz = q;
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

  bool get _isCurrentAnswered {
    if (_quiz == null) return false;
    return _chosen.containsKey(_quiz!.questions[_idx].id);
  }

  void _handleOptionSelect(ApiQuizQuestion q, ApiQuizOption opt) {
    if (_chosen.containsKey(q.id)) return;
    setState(() {
      _chosen[q.id] = opt.id;
      if (opt.isCorrect) _score++;
    });
  }

  void _next(String lang) {
    if (!_isCurrentAnswered) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(lang == 'uz' ? 'Variant tanlang' : (lang == 'ru' ? 'Выберите вариант' : 'Select an option')),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 1),
        ),
      );
      return;
    }
    if (_idx < _quiz!.questions.length - 1) {
      setState(() => _idx++);
    } else {
      _showResult();
    }
  }

  void _prev() {
    if (_idx > 0) setState(() => _idx--);
  }

  void _showResult() {
    final q = _quiz!;
    final answers = q.questions
        .where((e) => _chosen.containsKey(e.id))
        .map((e) => {'question_id': e.id, 'option_id': _chosen[e.id]!})
        .toList();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (_) => StandaloneQuizResultPage(
          quiz: q,
          chosen: Map.from(_chosen),
          score: _score,
          title: widget.title,
          quizId: widget.quizId,
          answers: answers,
          ds: _ds,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final langId = languageIdFromCode(lang);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        centerTitle: true,
        backgroundColor: AppColors.primaryPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_quiz != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  '${_idx + 1}/${_quiz!.questions.length}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
            ),
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
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _load,
                          child: Text(lang == 'uz' ? 'Qayta' : 'Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : _quiz == null || _quiz!.questions.isEmpty
                  ? Center(child: Text(lang == 'uz' ? 'Savollar yo\'q' : 'No questions'))
                  : _buildQuestion(context, isDark, lang, langId),
    );
  }

  Widget _buildQuestion(BuildContext context, bool isDark, String lang, int langId) {
    final q = _quiz!.questions[_idx];
    final qText = pickTranslatedText(q.translations, langId);
    final isAnswered = _chosen.containsKey(q.id);
    final chosenOptId = _chosen[q.id];

    return Column(
      children: [
        // Progress bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (_idx + 1) / _quiz!.questions.length,
              minHeight: 8,
              backgroundColor: isDark ? Colors.white10 : Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryPurple),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Savol raqami + ball
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    lang == 'uz'
                        ? 'Savol ${_idx + 1}/${_quiz!.questions.length}'
                        : (lang == 'ru'
                            ? 'Вопрос ${_idx + 1}/${_quiz!.questions.length}'
                            : 'Question ${_idx + 1}/${_quiz!.questions.length}'),
                    style: const TextStyle(
                      color: AppColors.primaryPurple,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    lang == 'uz' ? 'Ball: $_score' : (lang == 'ru' ? 'Балл: $_score' : 'Score: $_score'),
                    style: const TextStyle(
                      color: AppColors.primaryPurple,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Savol matni
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? Colors.white10 : Colors.grey[300]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  qText.isEmpty ? '—' : qText,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    height: 1.5,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Variantlar
              ...q.options.map((opt) {
                final text = pickTranslatedText(opt.translations, langId);
                final isSel = chosenOptId == opt.id;

                Color cardColor;
                Color borderColor;
                double borderWidth;
                Widget? trailingIcon;

                if (isAnswered) {
                  if (opt.isCorrect) {
                    cardColor = Colors.green.withOpacity(isDark ? 0.2 : 0.1);
                    borderColor = Colors.green.withOpacity(0.6);
                    borderWidth = 2;
                    trailingIcon = const Icon(Icons.check_circle, color: Colors.green);
                  } else if (isSel) {
                    cardColor = Colors.red.withOpacity(isDark ? 0.2 : 0.1);
                    borderColor = Colors.red.withOpacity(0.6);
                    borderWidth = 2;
                    trailingIcon = const Icon(Icons.cancel, color: Colors.red);
                  } else {
                    cardColor = isDark ? AppColors.cardDark : Colors.white;
                    borderColor = isDark ? Colors.white10 : Colors.grey[300]!;
                    borderWidth = 1;
                  }
                } else if (isSel) {
                  cardColor = AppColors.primaryPurple.withOpacity(0.12);
                  borderColor = AppColors.primaryPurple;
                  borderWidth = 2;
                  trailingIcon = null;
                } else {
                  cardColor = isDark ? AppColors.cardDark : Colors.white;
                  borderColor = isDark ? Colors.white24 : Colors.grey[300]!;
                  borderWidth = 1;
                }

                return GestureDetector(
                  onTap: () => _handleOptionSelect(q, opt),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(width: borderWidth, color: borderColor),
                      boxShadow: [
                        if (!isAnswered)
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            text.isEmpty ? '—' : text,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                              color: isDark ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (trailingIcon != null) ...[const SizedBox(width: 8), trailingIcon],
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        // Navigatsiya tugmalari
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                if (_idx > 0)
                  OutlinedButton(
                    onPressed: _prev,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primaryPurple),
                      foregroundColor: AppColors.primaryPurple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(lang == 'uz' ? 'Orqaga' : (lang == 'ru' ? 'Назад' : 'Back')),
                  ),
                const Spacer(),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isCurrentAnswered ? () => _next(lang) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.primaryPurple.withOpacity(0.4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                    ),
                    child: Text(
                      _idx < _quiz!.questions.length - 1
                          ? (lang == 'uz' ? 'Keyingi' : (lang == 'ru' ? 'Следующий' : 'Next'))
                          : (lang == 'uz' ? 'Yakunlash' : (lang == 'ru' ? 'Завершить' : 'Finish')),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Natija sahifasi — har bir savol ko'rinishi bilan
// ─────────────────────────────────────────────────────────────
class StandaloneQuizResultPage extends StatefulWidget {
  final ApiQuizDetail quiz;
  final Map<int, int> chosen;
  final int score;
  final String title;
  final int quizId;
  final List<Map<String, int>> answers;
  final StandaloneQuizRemoteDataSource ds;

  const StandaloneQuizResultPage({
    super.key,
    required this.quiz,
    required this.chosen,
    required this.score,
    required this.title,
    required this.quizId,
    required this.answers,
    required this.ds,
  });

  @override
  State<StandaloneQuizResultPage> createState() => _StandaloneQuizResultPageState();
}

class _StandaloneQuizResultPageState extends State<StandaloneQuizResultPage> {
  @override
  void initState() {
    super.initState();
    _submitToServer();
  }

  Future<void> _submitToServer() async {
    if (!sl<AuthSession>().isLoggedIn) return;
    try {
      await widget.ds.submitAttempt(widget.quizId, widget.answers);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final total = widget.quiz.questions.length;
    final score = widget.score;
    final percent = total > 0 ? (score / total * 100).toInt() : 0;

    Color feedbackColor;
    String feedback;
    if (percent >= 90) {
      feedback = lang == 'uz' ? 'A\'lo' : (lang == 'ru' ? 'Отлично!' : 'Excellent!');
      feedbackColor = Colors.green;
    } else if (percent >= 70) {
      feedback = lang == 'uz' ? 'Yaxshi' : (lang == 'ru' ? 'Хорошо' : 'Good');
      feedbackColor = Colors.orange;
    } else {
      feedback = lang == 'uz' ? 'Yana harakat qiling' : (lang == 'ru' ? 'Попробуйте ещё' : 'Try again');
      feedbackColor = Colors.red;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(lang == 'uz' ? 'Natija' : (lang == 'ru' ? 'Результат' : 'Result')),
        centerTitle: true,
        backgroundColor: AppColors.primaryPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Icon(
              Icons.sentiment_satisfied_alt_rounded,
              size: 120,
              color: feedbackColor,
            ),
            const SizedBox(height: 24),
            Text(
              lang == 'uz' ? 'Sizning natijangiz' : (lang == 'ru' ? 'Ваш результат' : 'Your result'),
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Text(
              '$score / $total',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryPurple,
              ),
            ),
            Text(
              '$percent%',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Colors.grey[500]),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: feedbackColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: feedbackColor.withOpacity(0.3)),
              ),
              child: Text(
                feedback,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: feedbackColor),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => StandaloneQuizPage(quizId: widget.quizId, title: widget.title),
                    ),
                  );
                },
                icon: const Icon(Icons.refresh_rounded),
                label: Text(
                  lang == 'uz' ? 'Testni qayta ishlash' : (lang == 'ru' ? 'Пересдать тест' : 'Retake quiz'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.home_rounded),
                label: Text(
                  lang == 'uz' ? 'Bosh sahifaga qaytish' : (lang == 'ru' ? 'На главную' : 'Back to home'),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryPurple),
                  foregroundColor: AppColors.primaryPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
