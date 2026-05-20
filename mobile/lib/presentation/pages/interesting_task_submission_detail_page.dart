import 'dart:convert';

import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/network/api_storage_url.dart';
import '../../core/network/dio_client.dart';
import '../../core/theme/colors.dart';
import '../../core/utils/json_bool.dart';
import '../../data/datasources/interesting_task_remote_data_source.dart';
import '../../injection_container.dart';

/// O'qituvchi natijani ko'rsatishga ruxsat bergach, to'liq javoblar bilan ochiladi.
class InterestingTaskSubmissionDetailPage extends StatelessWidget {
  final MySubmissionModel sub;

  const InterestingTaskSubmissionDetailPage({
    super.key,
    required this.sub,
  });

  static String _lang(BuildContext context) => context.locale.languageCode;

  static String _resultTitle(BuildContext context) {
    final l = _lang(context);
    if (l == 'ru') return 'Результат';
    if (l == 'uz') return 'Natija';
    return 'Result';
  }

  static String _totalScoreLabel(BuildContext context) {
    final l = _lang(context);
    if (l == 'ru') return 'Общий балл';
    if (l == 'uz') return 'Umumiy ball';
    return 'Total score';
  }

  static String _qaTitle(BuildContext context) {
    final l = _lang(context);
    if (l == 'ru') return 'Вопросы и ответы';
    if (l == 'uz') return 'Savollar va javoblar';
    return 'Questions & answers';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.scaffoldBackgroundDark : Colors.grey[50]!;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(
          sub.task?['title'] as String? ?? _resultTitle(context),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          _ScoreSummaryCard(sub: sub, isDark: isDark),
          const SizedBox(height: 20),
          if (sub.answers != null) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 12, left: 2),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _qaTitle(context),
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
            ),
            ...sub.answers!.asMap().entries.map(
                  (e) => _AnswerCard(
                    index: e.key,
                    answer: e.value,
                    isDark: isDark,
                  ),
                ),
          ],
        ],
      ),
    );
  }
}

class _ScoreSummaryCard extends StatelessWidget {
  final MySubmissionModel sub;
  final bool isDark;

  const _ScoreSummaryCard({
    required this.sub,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? AppColors.cardDark : Colors.white;
    final borderColor = isDark ? Colors.white10 : Colors.grey[200]!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryPurple.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.emoji_events_rounded, color: AppColors.primaryPurple, size: 36),
          ),
          const SizedBox(height: 14),
          Text(
            InterestingTaskSubmissionDetailPage._totalScoreLabel(context),
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          ShaderMask(
            shaderCallback: (b) => const LinearGradient(
              colors: [Color(0xFFA855F7), Color(0xFFEC4899)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ).createShader(b),
            child: Text(
              '${sub.totalScore}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 52,
                fontWeight: FontWeight.bold,
                height: 1.05,
              ),
            ),
          ),
          if (sub.teacherComment != null && sub.teacherComment!.isNotEmpty) ...[
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withOpacity(isDark ? 0.1 : 0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryPurple.withOpacity(0.22)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.format_quote_rounded, color: AppColors.primaryPurple, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      sub.teacherComment!,
                      style: TextStyle(
                        color: isDark ? Colors.white.withOpacity(0.85) : Colors.grey[800],
                        fontSize: 14,
                        height: 1.55,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AnswerCard extends StatelessWidget {
  final int index;
  final Map<String, dynamic> answer;
  final bool isDark;

  const _AnswerCard({
    required this.index,
    required this.answer,
    required this.isDark,
  });

  String _pointsLabel(BuildContext context, int score) {
    final l = context.locale.languageCode;
    if (l == 'ru') return '$score б.';
    if (l == 'uz') return '$score ball';
    return '$score pts';
  }

  String _notGradedLabel(BuildContext context) {
    final l = context.locale.languageCode;
    if (l == 'ru') return 'Не оценено';
    if (l == 'uz') return 'Baholanmagan';
    return 'Not graded';
  }

  String _teacherCommentPrefix(BuildContext context) {
    final l = context.locale.languageCode;
    if (l == 'ru') return 'Учитель: ';
    if (l == 'uz') return "O'qituvchi izohi: ";
    return 'Teacher: ';
  }

  String _questionLabel(BuildContext context, int n) {
    final l = context.locale.languageCode;
    if (l == 'ru') return 'Вопрос $n';
    if (l == 'uz') return 'Savol $n';
    return 'Question $n';
  }

  @override
  Widget build(BuildContext context) {
    final isCorrect = jsonBoolOrNull(answer['is_correct']);
    final score = answer['score'] as int? ?? 0;
    final question = answer['question'] as Map<String, dynamic>?;

    final cardColor = isDark ? AppColors.cardDark : Colors.white;
    final borderColor = isDark ? Colors.white10 : Colors.grey[200]!;
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;

    final statusColor = isCorrect == null
        ? (isDark ? Colors.white38 : Colors.grey[500]!)
        : isCorrect
            ? AppColors.primaryGreen
            : const Color(0xFFEF4444);
    final statusBg = statusColor.withOpacity(0.14);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
                  _questionLabel(context, index + 1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withOpacity(0.35)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isCorrect == null
                          ? Icons.help_outline_rounded
                          : isCorrect
                              ? Icons.check_circle_rounded
                              : Icons.cancel_rounded,
                      color: statusColor,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isCorrect == null ? _notGradedLabel(context) : _pointsLabel(context, score),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (question != null) ...[
            const SizedBox(height: 14),
            if ((question['question_type'] as String?) == 'image' &&
                question['image_url'] != null &&
                (question['image_url'] as String).isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ColoredBox(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100]!,
                  child: LayoutBuilder(
                    builder: (ctx, _) {
                      final maxH = MediaQuery.of(ctx).size.height * 0.4;
                      return ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: maxH),
                        child: Image.network(
                          resolveApiStorageFileUrl(
                            sl<DioClient>().dio.options.baseUrl,
                            question['image_url'] as String?,
                          ),
                          fit: BoxFit.contain,
                          width: double.infinity,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return SizedBox(
                              height: 120,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primaryPurple,
                                  value: progress.expectedTotalBytes != null
                                      ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (_, _, __) => Padding(
                            padding: const EdgeInsets.all(20),
                            child: Icon(Icons.broken_image_outlined, size: 40, color: Colors.grey[500]),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
            Text(
              question['body'] as String? ?? '',
              style: TextStyle(color: textPrimary, fontSize: 15, height: 1.55, fontWeight: FontWeight.w500),
            ),
          ],
          const SizedBox(height: 14),
          Text(
            context.locale.languageCode == 'uz'
                ? 'Sizning javobingiz'
                : context.locale.languageCode == 'ru'
                    ? 'Ваш ответ'
                    : 'Your answer',
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.grey[300]!,
              ),
            ),
            child: _AnswerBody(
              question: question,
              answer: answer,
              isDark: isDark,
            ),
          ),
          if (answer['teacher_comment'] != null && (answer['teacher_comment'] as String).isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              '${_teacherCommentPrefix(context)}${answer['teacher_comment']}',
              style: TextStyle(
                color: AppColors.primaryPurple,
                fontSize: 13,
                fontStyle: FontStyle.italic,
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AnswerBody extends StatelessWidget {
  final Map<String, dynamic>? question;
  final Map<String, dynamic> answer;
  final bool isDark;

  const _AnswerBody({
    required this.question,
    required this.answer,
    required this.isDark,
  });

  TextStyle get _bodyStyle => TextStyle(
        color: isDark ? Colors.white70 : Colors.grey[800],
        fontSize: 14,
        height: 1.55,
      );

  @override
  Widget build(BuildContext context) {
    final qt = question?['question_type'] as String? ?? 'text';
    final text = answer['answer_text'] as String? ?? '';
    if (qt == 'match') {
      try {
        final decoded = jsonDecode(text) as Map<String, dynamic>;
        final pairs = decoded['pairs'] as List<dynamic>?;
        final md = question?['match_data'];
        Map<String, dynamic>? mm;
        if (md is Map<String, dynamic>) {
          mm = md;
        } else if (md is Map) {
          mm = md.map((k, v) => MapEntry(k.toString(), v));
        }
        final left = (mm?['left'] as List<dynamic>? ?? []).map((e) => e.toString()).toList();
        final right = (mm?['right'] as List<dynamic>? ?? []).map((e) => e.toString()).toList();
        if (pairs == null || pairs.isEmpty) {
          return Text(text, style: _bodyStyle);
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: pairs.map<Widget>((p) {
            final pair = p as List<dynamic>;
            final li = pair[0] as int;
            final ri = pair[1] as int;
            final la = li < left.length ? left[li] : '[$li]';
            final ra = ri < right.length ? right[ri] : '[$ri]';
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.link_rounded, size: 16, color: AppColors.primaryPurple.withOpacity(0.9)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$la — $ra',
                      style: _bodyStyle,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      } catch (_) {
        return Text(text, style: _bodyStyle);
      }
    }
    if (qt == 'word_search') {
      try {
        final decoded = jsonDecode(text) as Map<String, dynamic>;
        final foundIds = ((decoded['found_ids'] as List<dynamic>? ?? const [])
                .map((e) => int.tryParse(e.toString()))
                .whereType<int>())
            .toSet();

        final md = question?['match_data'];
        Map<String, dynamic>? mm;
        if (md is Map<String, dynamic>) {
          mm = md;
        } else if (md is Map) {
          mm = md.map((k, v) => MapEntry(k.toString(), v));
        }

        final clues = (mm?['clues'] as List<dynamic>? ?? const []);
        if (clues.isEmpty) return Text(text, style: _bodyStyle);

        final titleStyle = TextStyle(
          color: AppColors.primaryGreen,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        );
        final subStyle = TextStyle(
          color: isDark ? Colors.white60 : Colors.grey[600],
          fontSize: 12,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.locale.languageCode == 'ru'
                  ? 'Найдено: ${foundIds.length}/${clues.length}'
                  : context.locale.languageCode == 'uz'
                      ? 'Topilganlari: ${foundIds.length}/${clues.length}'
                      : 'Found: ${foundIds.length}/${clues.length}',
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 10),
            ...clues.map((c) {
              final cm = (c is Map<String, dynamic>) ? c : Map<String, dynamic>.from(c as Map);
              final id = (cm['id'] as num?)?.toInt();
              final ok = id != null && foundIds.contains(id);
              final formula = cm['formula']?.toString() ?? '-';
              final commonName = cm['common_name']?.toString() ?? '';
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                decoration: BoxDecoration(
                  color: ok
                      ? AppColors.primaryGreen.withOpacity(0.09)
                      : (isDark ? Colors.white.withOpacity(0.03) : Colors.white),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: ok
                        ? AppColors.primaryGreen.withOpacity(0.45)
                        : (isDark ? Colors.white10 : Colors.grey[300]!),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      ok ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      color: ok ? AppColors.primaryGreen : (isDark ? Colors.white38 : Colors.grey[500]),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(formula, style: titleStyle),
                          if (commonName.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(commonName, style: subStyle),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      } catch (_) {
        return Text(text, style: _bodyStyle);
      }
    }
    if (qt == 'matrix_classification') {
      try {
        final decoded = jsonDecode(text) as Map<String, dynamic>;
        final methodMap = (decoded['method'] as Map?)?.map((k, v) => MapEntry(k.toString(), v.toString())) ?? <String, String>{};
        final orderMap = (decoded['order'] as Map?)?.map((k, v) => MapEntry(k.toString(), v)) ?? <String, dynamic>{};

        final md = question?['match_data'];
        Map<String, dynamic>? mm;
        if (md is Map<String, dynamic>) {
          mm = md;
        } else if (md is Map) {
          mm = md.map((k, v) => MapEntry(k.toString(), v));
        }
        final rows = (mm?['rows'] as List<dynamic>? ?? const []);
        if (rows.isEmpty) return Text(text, style: _bodyStyle);

        final lang = context.locale.languageCode;
        String methodLabel(String? m) {
          if (m == 'solve') return 'Solve';
          if (m == 'ammonia') return lang == 'ru' ? 'Аммиачный' : 'Ammiakli';
          if (m == 'none') return lang == 'ru' ? 'Не относится' : lang == 'uz' ? 'Tegishli emas' : 'Not applicable';
          return '-';
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rows.asMap().entries.map((entry) {
            final row = (entry.value is Map<String, dynamic>)
                ? (entry.value as Map<String, dynamic>)
                : Map<String, dynamic>.from(entry.value as Map);
            final id = (row['id'] as num?)?.toInt();
            final txt = row['text']?.toString() ?? '';
            final key = id?.toString() ?? '';
            final method = methodMap[key];
            final order = orderMap[key];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.03) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? Colors.white10 : Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${entry.key + 1}. $txt', style: _bodyStyle.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    'Usul: ${methodLabel(method)}  ·  Ketma-ketlik: ${order ?? '-'}',
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.grey[700],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      } catch (_) {
        return Text(text, style: _bodyStyle);
      }
    }
    return Text(text, style: _bodyStyle);
  }
}
