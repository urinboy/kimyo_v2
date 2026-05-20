import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/localization/app_localizations.dart';
import '../widgets/geography_topic_complete_bar.dart';

/// "Ob-havo" — ob-havo elementlari va foydali maslahatlar.
class GeographyWeatherPage extends StatelessWidget {
  const GeographyWeatherPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('weather_page_title')),
        backgroundColor: AppColors.primaryCyan,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _topicTile(
            context,
            isDark: isDark,
            titleKey: 'weather_topic_elements',
            bodyKey: 'weather_topic_elements_desc',
            icon: Icons.wb_sunny_rounded,
            iconColor: const Color(0xFF1E88E5),
            bg: const Color(0x331E88E5),
          ),
          const SizedBox(height: 10),
          _topicTile(
            context,
            isDark: isDark,
            titleKey: 'weather_topic_types',
            bodyKey: 'weather_topic_types_desc',
            icon: Icons.cloud_rounded,
            iconColor: const Color(0xFF78909C),
            bg: const Color(0x3378909C),
          ),
          const SizedBox(height: 10),
          _topicTile(
            context,
            isDark: isDark,
            titleKey: 'weather_topic_forecast',
            bodyKey: 'weather_topic_forecast_desc',
            icon: Icons.bar_chart_rounded,
            iconColor: const Color(0xFF43A047),
            bg: const Color(0x3343A047),
          ),
          const SizedBox(height: 10),
          _topicTile(
            context,
            isDark: isDark,
            titleKey: 'weather_topic_dangerous',
            bodyKey: 'weather_topic_dangerous_desc',
            icon: Icons.warning_amber_rounded,
            iconColor: const Color(0xFFE53935),
            bg: const Color(0x33E53935),
          ),
          const SizedBox(height: 10),
          _topicTile(
            context,
            isDark: isDark,
            titleKey: 'weather_topic_local',
            bodyKey: 'weather_topic_local_desc',
            icon: Icons.location_city_rounded,
            iconColor: const Color(0xFF8E24AA),
            bg: const Color(0x338E24AA),
          ),
          const SizedBox(height: 10),
          _topicTile(
            context,
            isDark: isDark,
            titleKey: 'weather_topic_activity',
            bodyKey: 'weather_topic_activity_desc',
            icon: Icons.outdoor_grill_rounded,
            iconColor: const Color(0xFFFB8C00),
            bg: const Color(0x33FB8C00),
          ),
          const SizedBox(height: 20),
          _tipsCard(context, isDark),
          const GeographyTopicCompleteBar(
            topicId: 'geo_weather',
            titleTrKey: 'weather_page_title',
          ),
        ],
      ),
    );
  }

  Widget _topicTile(
    BuildContext context, {
    required bool isDark,
    required String titleKey,
    required String bodyKey,
    required IconData icon,
    required Color iconColor,
    required Color bg,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
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
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.iconBackgroundDark : bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          title: Text(
            context.tr(titleKey),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          iconColor: isDark ? Colors.white70 : AppColors.textSecondary,
          collapsedIconColor: isDark ? Colors.white38 : AppColors.textSecondary,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  context.tr(bodyKey),
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tipsCard(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C3E50) : const Color(0xFFE8EAF6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : const Color(0xFF5C6BC0).withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                color: isDark ? Colors.amber.shade200 : const Color(0xFF3949AB),
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                context.tr('weather_tips_title'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? Colors.white : const Color(0xFF1A237E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _tipRow(context, Icons.smartphone_rounded, 'weather_tip_1', isDark),
          const SizedBox(height: 8),
          _tipRow(context, Icons.tv_rounded, 'weather_tip_2', isDark),
          const SizedBox(height: 8),
          _tipRow(context, Icons.thermostat_rounded, 'weather_tip_3', isDark),
          const SizedBox(height: 8),
          _tipRow(context, Icons.umbrella_rounded, 'weather_tip_4', isDark),
          const SizedBox(height: 8),
          _tipRow(context, Icons.checkroom_rounded, 'weather_tip_5', isDark),
          const SizedBox(height: 8),
          _tipRow(context, Icons.report_problem_rounded, 'weather_tip_6', isDark),
        ],
      ),
    );
  }

  Widget _tipRow(
    BuildContext context,
    IconData icon,
    String trKey,
    bool isDark,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: isDark ? Colors.white60 : const Color(0xFF5C6BC0),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            context.tr(trKey),
            style: TextStyle(
              fontSize: 14,
              height: 1.35,
              color: isDark ? Colors.white70 : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
