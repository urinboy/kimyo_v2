import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/services/learning_progress_service.dart';
import '../../core/theme/colors.dart';
import '../../injection_container.dart' as di;

class AchievementsDialog extends StatelessWidget {
  const AchievementsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: di.sl<LearningProgressService>(),
      builder: (context, _) {
        final p = di.sl<LearningProgressService>();

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          backgroundColor: isDark ? AppColors.cardDark : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('profile_achievements'),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildAchievementItem(
                    context.tr('profile_achievement_1'),
                    context.tr('profile_achievement_1_desc'),
                    Icons.school_rounded,
                    p.achievementFirstLessonUnlocked,
                    isDark,
                  ),
                  _buildAchievementItem(
                    context.tr('profile_achievement_2'),
                    context.tr('profile_achievement_2_desc'),
                    Icons.science_rounded,
                    p.achievementChemistry10Unlocked,
                    isDark,
                  ),
                  _buildAchievementItem(
                    context.tr('profile_achievement_3'),
                    context.tr('profile_achievement_3_desc'),
                    Icons.public_rounded,
                    p.achievementGeography10Unlocked,
                    isDark,
                  ),
                  _buildAchievementItem(
                    context.tr('profile_achievement_4'),
                    context.tr('profile_achievement_4_desc'),
                    Icons.star_rounded,
                    p.achievementStudent50Unlocked,
                    isDark,
                  ),
                  _buildAchievementItem(
                    context.tr('profile_achievement_5'),
                    context.tr('profile_achievement_5_desc'),
                    Icons.emoji_events_rounded,
                    p.achievementChampion100Unlocked,
                    isDark,
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        context.tr('close'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.activeBlue,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAchievementItem(
      String title, String desc, IconData icon, bool isUnlocked, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUnlocked
            ? (isDark ? Colors.amber.withValues(alpha: 0.1) : const Color(0xFFFFFDE7))
            : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.02)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isUnlocked
                  ? Colors.black.withValues(alpha: 0.1)
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isUnlocked
                  ? Colors.black87
                  : (isDark ? Colors.white24 : Colors.black12),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isUnlocked
                        ? (isDark ? Colors.white : Colors.black87)
                        : (isDark ? Colors.white38 : Colors.black26),
                  ),
                ),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 12,
                    color: isUnlocked
                        ? (isDark ? Colors.white70 : Colors.black54)
                        : (isDark ? Colors.white24 : Colors.black12),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            isUnlocked ? Icons.check_circle_rounded : Icons.lock_rounded,
            color: isUnlocked
                ? Colors.green
                : (isDark ? Colors.white24 : Colors.black12),
            size: 20,
          ),
        ],
      ),
    );
  }
}
