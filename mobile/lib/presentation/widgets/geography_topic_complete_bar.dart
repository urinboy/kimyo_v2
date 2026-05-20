import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/services/learning_progress_service.dart';
import '../../core/theme/colors.dart';
import '../../injection_container.dart' as di;

/// Geografiya mavzusi oxirida — bir marta bosilganda “tugatilgan” deb yoziladi.
class GeographyTopicCompleteBar extends StatelessWidget {
  const GeographyTopicCompleteBar({
    super.key,
    required this.topicId,
    required this.titleTrKey,
    this.dense = false,
  });

  final String topicId;
  /// `context.tr(titleTrKey)` — jurnal uchun sarlavha.
  final String titleTrKey;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final svc = di.sl<LearningProgressService>();

    return ListenableBuilder(
      listenable: svc,
      builder: (context, _) {
        final done = svc.isGeographyTopicComplete(topicId);

        if (done) {
          return Padding(
            padding: EdgeInsets.only(top: dense ? 12 : 20, bottom: 8),
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded,
                    color: Colors.green.shade600, size: dense ? 20 : 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    context.tr('geo_topic_marked_complete'),
                    style: TextStyle(
                      color: isDark ? Colors.greenAccent : Colors.green.shade800,
                      fontWeight: FontWeight.w600,
                      fontSize: dense ? 12 : 14,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.only(top: dense ? 12 : 20, bottom: 8),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: Icon(Icons.task_alt_rounded,
                  color: AppColors.primaryCyan, size: dense ? 18 : 22),
              label: Text(context.tr('geo_mark_section_complete')),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryCyan,
                side:
                    BorderSide(color: AppColors.primaryCyan.withValues(alpha: 0.65)),
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: dense ? 10 : 14,
                ),
              ),
              onPressed: () {
                final line =
                    '${context.tr('activity_subject_geography')}: ${context.tr(titleTrKey)}';
                final ok = svc.tryCompleteGeographyTopic(topicId, line);
                if (ok && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.tr('study_marked_done_snackbar'))),
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }
}
