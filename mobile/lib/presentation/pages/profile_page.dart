import 'package:flutter/material.dart';
import '../../core/auth/auth_session.dart';
import '../../core/services/app_foreground_time_service.dart';
import '../../core/services/learning_progress_service.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/colors.dart';
import '../../core/utils/format_foreground_duration.dart';
import '../../core/utils/toast_util.dart';
import '../../injection_container.dart' as di;
import 'activity_history_page.dart';
import 'edit_profile_page.dart';
import '../widgets/logout_confirm_dialog.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static String _fmt(BuildContext context, String? v) {
    final t = v?.trim();
    if (t == null || t.isEmpty) return context.tr('profile_not_set');
    return t;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        di.sl<AuthSession>(),
        di.sl<AppForegroundTimeService>(),
        di.sl<LearningProgressService>(),
      ]),
      builder: (context, _) {
        final user = di.sl<AuthSession>().currentUser;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final displayName = user?.name ?? context.tr('profile_name');
        final phone = _fmt(context, user?.phone);
        final school = _fmt(context, user?.schoolName);
        final grade = user?.grade?.trim();
        final lessonCount = di.sl<LearningProgressService>().totalCompletedCount;
        final gradeLine = (grade != null && grade.isNotEmpty)
            ? '$grade ${context.tr('profile_student_suffix')}'
            : context.tr('profile_not_set');
        final lessonsSubtitle = context.tr('profile_lessons_total_pattern').replaceAll('{n}', '$lessonCount');

        return Scaffold(
          appBar: AppBar(
            title: Text(context.tr('tab_profil')),
            backgroundColor: AppColors.primaryGreenProfile,
            actions: [
              IconButton(
                onPressed: () async {
                  final result = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(builder: (_) => const EditProfilePage()),
                  );
                  if (result == true && context.mounted) {
                    ToastUtil.showSuccess(context.tr('profile_updated'));
                  }
                },
                icon: const Icon(Icons.edit_rounded, color: Colors.white),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildHeaderCard(context, displayName, phone, gradeLine),
              const SizedBox(height: 16),
              _buildTimeCard(context),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 12),
                child: Text(
                  context.tr('profile_personal'),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              _buildInfoCard(
                context,
                title: context.tr('profile_user_info'),
                icon: Icons.person_rounded,
                iconColor: AppColors.primaryGreenProfile,
                bgColor: isDark ? AppColors.iconBackgroundDark : AppColors.iconBackgroundGreenProfile,
                details: [
                  {'label': context.tr('profile_phone'), 'value': phone, 'icon': Icons.phone_outlined},
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                context,
                title: context.tr('profile_edu'),
                icon: Icons.school_rounded,
                iconColor: AppColors.primaryGreenProfile,
                bgColor: isDark ? AppColors.iconBackgroundDark : AppColors.iconBackgroundGreenProfile,
                details: [
                  {'label': context.tr('profile_school'), 'value': school, 'icon': Icons.business_outlined},
                  {
                    'label': context.tr('profile_class'),
                    'value': _fmt(context, user?.grade),
                    'icon': Icons.book_outlined,
                  },
                ],
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 12),
                child: Text(
                  context.tr('profile_activity'),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              _buildSimpleActionCard(
                context,
                title: context.tr('profile_activity_history'),
                subtitle: lessonsSubtitle,
                icon: Icons.trending_up_rounded,
                iconColor: AppColors.primaryBlue,
                bgColor: isDark ? const Color(0xFF1A237E).withValues(alpha: 0.2) : AppColors.iconBackgroundBlue,
                onTap: () {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute(builder: (_) => const ActivityHistoryPage()),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildSimpleActionCard(
                context,
                title: context.tr('profile_logout'),
                subtitle: 'Akkauntdan chiqish',
                icon: Icons.logout_rounded,
                iconColor: AppColors.iconRed,
                bgColor: isDark ? const Color(0xFFB71C1C).withValues(alpha: 0.2) : AppColors.iconBackgroundRed,
                titleColor: AppColors.iconRed,
                onTap: () async {
                  final result = await showDialog<bool>(
                    context: context,
                    builder: (_) => const LogoutConfirmDialog(),
                  );
                  if (result == true && context.mounted) {
                    await di.sl<AuthSession>().signOut();
                    if (context.mounted) {
                      ToastUtil.showInfo(context.tr('profile_logged_out'));
                    }
                  }
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderCard(BuildContext context, String name, String phone, String badgeText) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: isDark ? AppColors.iconBackgroundDark : AppColors.iconBackgroundGreenProfile,
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreenProfile,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primaryGreenProfile,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          if (phone.isNotEmpty)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.phone_outlined, size: 14,
                    color: isDark ? Colors.white38 : Colors.black26),
                const SizedBox(width: 4),
                Text(
                  phone,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white38 : Colors.black26,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryGreenProfile,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.school_rounded, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    badgeText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.access_time_rounded, color: AppColors.iconYellow, size: 32),
          const SizedBox(height: 12),
          Text(
            formatForegroundDuration(
              context,
              di.sl<AppForegroundTimeService>().totalForegroundSeconds,
            ),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          Text(
            context.tr('profile_time'),
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white38 : Colors.black26,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required List<Map<String, dynamic>> details,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.iconBackgroundDark : bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: isDark ? Colors.white10 : Colors.black12),
          ...details.map((detail) => Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(detail['icon'] as IconData, color: isDark ? Colors.white24 : Colors.black26, size: 20),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            detail['label'] as String,
                            style: TextStyle(fontSize: 10, color: isDark ? Colors.white38 : Colors.black26),
                          ),
                          Text(
                            detail['value'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildSimpleActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.iconBackgroundDark : bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: titleColor ?? (isDark ? Colors.white : AppColors.textPrimary),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white24 : Colors.black26, size: 28),
          ],
        ),
      ),
    );
  }
}
