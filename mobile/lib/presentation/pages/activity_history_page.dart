import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/services/app_foreground_time_service.dart';
import '../../core/services/learning_progress_service.dart';
import '../../core/theme/colors.dart';
import '../../core/utils/format_foreground_duration.dart';
import '../../core/utils/format_relative_activity_date.dart';
import '../../injection_container.dart' as di;

/// Profildan ochiladigan to‘liq ekran — oxirgi yozuvlar, jami darslar, foreground vaqt.
class ActivityHistoryPage extends StatelessWidget {
  const ActivityHistoryPage({super.key});

  static Color _dot(StudyActivityKind k) =>
      k == StudyActivityKind.chemistry
          ? const Color(0xFF9C27B0)
          : const Color(0xFF43A047);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(context.tr('profile_activity_history')),
        backgroundColor: AppColors.primaryGreenProfile,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        ),
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([
          di.sl<AppForegroundTimeService>(),
          di.sl<LearningProgressService>(),
        ]),
        builder: (context, _) {
          final foregroundSecs = di.sl<AppForegroundTimeService>().totalForegroundSeconds;
          final learning = di.sl<LearningProgressService>();
          final log = learning.activityLogNewestFirst.take(30).toList();

          final lessonsPattern = context.tr('profile_lessons_total_pattern')
              .replaceAll('{n}', '${learning.totalCompletedCount}');

          return Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottomPad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: log.isEmpty
                      ? Center(
                          child: Text(
                            context.tr('activity_history_empty'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white54 : AppColors.textSecondary,
                              height: 1.35,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: log.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 16),
                          itemBuilder: (context, i) {
                            final item = log[i];
                            return _activityRow(
                              title: item.title,
                              subtitle: formatRelativeActivitySubtitle(
                                context,
                                item.at,
                              ),
                              dot: _dot(item.kind),
                              isDark: isDark,
                            );
                          },
                        ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                _summaryRow(
                  context.tr('profile_total_lessons'),
                  lessonsPattern,
                  isDark,
                ),
                const SizedBox(height: 10),
                _summaryRow(
                  context.tr('profile_study_time'),
                  formatForegroundDuration(context, foregroundSecs),
                  isDark,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _activityRow({
    required String title,
    required String subtitle,
    required Color dot,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 5),
          decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white38 : Colors.black45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white60 : AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
