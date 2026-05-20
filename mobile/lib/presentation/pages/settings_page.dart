import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/theme_service.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/locale_service.dart';
import '../../core/services/app_review_local_storage.dart';
import '../../core/network/dio_client.dart';
import '../../core/auth/auth_session.dart';
import '../../injection_container.dart' as di;
import '../widgets/language_dialog.dart';
import '../widgets/about_dialog.dart';
import '../widgets/rate_dialog.dart';
import 'author_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int? _rateStarsSubtitle;

  @override
  void initState() {
    super.initState();
    _loadRateStarsSubtitle();
  }

  Future<void> _loadRateStarsSubtitle() async {
    final prefs = di.sl<SharedPreferences>();
    final auth = di.sl<AuthSession>();
    final dio = di.sl<DioClient>().dio;
    final state = await AppReviewLocalStorage.resolveDisplayState(
      prefs: prefs,
      auth: auth,
      dio: dio,
    );
    if (!mounted) return;
    setState(() {
      _rateStarsSubtitle =
          (state.locked && state.rating >= 1) ? state.rating : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenW = MediaQuery.sizeOf(context).width;
    final hPad = (screenW * 0.04).clamp(12.0, 28.0);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('tab_sozlamalar')),
        backgroundColor: AppColors.primaryOrange,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 16 + bottomInset),
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: math.min(8.0, hPad * 0.5),
              bottom: 12,
            ),
            child: Text(
              context.tr('settings_general'),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          _buildSettingsCard(
            context,
            title: context.tr('settings_language'),
            subtitle: LocaleService().currentLanguageName,
            icon: Icons.language_rounded,
            iconColor: AppColors.primaryOrange,
            bgColor: isDark ? AppColors.iconBackgroundDark : AppColors.iconBackgroundOrange,
            trailing: Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white24 : Colors.black26, size: 28),
            onTap: () => showDialog(
              context: context,
              builder: (_) => const LanguageDialog(),
            ),
          ),
          const SizedBox(height: 12),
          _buildSettingsCard(
            context,
            title: context.tr('settings_dark_mode'),
            subtitle: isDark ? context.tr('settings_dark_mode') : context.tr('settings_dark_mode'), // Can be refined
            icon: Icons.wb_sunny_rounded,
            iconColor: AppColors.primaryOrange,
            bgColor: isDark ? AppColors.iconBackgroundDark : AppColors.iconBackgroundOrange,
            trailing: Switch(
              value: isDark,
              onChanged: (val) => ThemeService().toggleTheme(val),
              activeColor: AppColors.activeBlue,
            ),
            onTap: () {},
          ),
          const SizedBox(height: 24),
          Padding(
            padding: EdgeInsets.only(
              left: math.min(8.0, hPad * 0.5),
              bottom: 12,
            ),
            child: Text(
              context.tr('settings_about'),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          _buildSettingsCard(
            context,
            title: context.tr('settings_about'),
            subtitle: context.tr('settings_about_sub'),
            icon: Icons.info_outline_rounded,
            iconColor: AppColors.primaryOrange,
            bgColor: isDark ? AppColors.iconBackgroundDark : AppColors.iconBackgroundOrange,
            trailing: Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white24 : Colors.black26, size: 28),
            onTap: () => showDialog(
              context: context,
              builder: (_) => const AboutDialogWidget(),
            ),
          ),
          const SizedBox(height: 12),
          _buildSettingsCard(
            context,
            title: context.tr('settings_author'),
            icon: Icons.person_outline_rounded,
            iconColor: AppColors.primaryBlue,
            bgColor: isDark ? const Color(0xFF1A237E).withOpacity(0.2) : AppColors.iconBackgroundBlue,
            trailing: Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white24 : Colors.black26, size: 28),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AuthorPage()),
            ),
          ),
          const SizedBox(height: 12),
          _buildSettingsCard(
            context,
            title: context.tr('settings_rate'),
            subtitle: _rateStarsSubtitle != null
                ? context
                    .tr('settings_rate_submitted')
                    .replaceFirst('{}', '${_rateStarsSubtitle!}')
                : context.tr('settings_rate_sub'),
            icon: Icons.star_rounded,
            iconColor: AppColors.iconYellow,
            bgColor: isDark ? const Color(0xFF3E2723).withOpacity(0.2) : AppColors.iconBackgroundYellow,
            trailing: Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white24 : Colors.black26, size: 28),
            onTap: () => showDialog<void>(
              context: context,
              builder: (_) => const RateDialog(),
            ).then((_) => _loadRateStarsSubtitle()),
          ),
          const SizedBox(height: 12),
          _buildSettingsCard(
            context,
            title: context.tr('settings_version'),
            subtitle: 'v2.5.13 (26)',
            icon: Icons.get_app_rounded,
            iconColor: AppColors.primaryOrange,
            bgColor: isDark ? AppColors.iconBackgroundDark : AppColors.iconBackgroundOrange,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Yangi',
                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required String title,
    String? subtitle,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pad = (MediaQuery.sizeOf(context).width * 0.04).clamp(12.0, 18.0);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(pad),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.04),
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
                color: bgColor,
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
