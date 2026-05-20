import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/localization/app_localizations.dart';
import '../widgets/geography_topic_complete_bar.dart';

/// "Iqlim, ob-havo hududiy taqsimlash" — hududiy iqlim mavzulari va statistika.
class GeographyClimateRegionalPage extends StatelessWidget {
  const GeographyClimateRegionalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('geo_climate_regional_title')),
        backgroundColor: AppColors.primaryCyan,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _topicTile(
            context,
            isDark: isDark,
            titleKey: 'geo_topic_continental',
            bodyKey: 'geo_topic_continental_desc',
            icon: Icons.public_rounded,
            iconColor: const Color(0xFF1E88E5),
            bg: const Color(0x331E88E5),
          ),
          const SizedBox(height: 10),
          _topicTile(
            context,
            isDark: isDark,
            titleKey: 'geo_topic_climate_zones',
            bodyKey: 'geo_topic_climate_zones_desc',
            icon: Icons.map_rounded,
            iconColor: const Color(0xFF43A047),
            bg: const Color(0x3343A047),
          ),
          const SizedBox(height: 10),
          _topicTile(
            context,
            isDark: isDark,
            titleKey: 'geo_topic_seasons',
            bodyKey: 'geo_topic_seasons_desc',
            icon: Icons.calendar_month_rounded,
            iconColor: const Color(0xFFFB8C00),
            bg: const Color(0x33FB8C00),
          ),
          const SizedBox(height: 10),
          _topicTile(
            context,
            isDark: isDark,
            titleKey: 'geo_topic_regional_diff',
            bodyKey: 'geo_topic_regional_diff_desc',
            icon: Icons.location_on_rounded,
            iconColor: const Color(0xFF8E24AA),
            bg: const Color(0x338E24AA),
          ),
          const SizedBox(height: 10),
          _topicTile(
            context,
            isDark: isDark,
            titleKey: 'geo_topic_climate_change',
            bodyKey: 'geo_topic_climate_change_desc',
            icon: Icons.trending_up_rounded,
            iconColor: const Color(0xFFEC407A),
            bg: const Color(0x33EC407A),
          ),
          const SizedBox(height: 10),
          _topicTile(
            context,
            isDark: isDark,
            titleKey: 'geo_topic_special_climate',
            bodyKey: 'geo_topic_special_climate_desc',
            icon: Icons.apartment_rounded,
            iconColor: const Color(0xFF00838F),
            bg: const Color(0x3300838F),
          ),
          const SizedBox(height: 20),
          _statsCard(context, isDark),
          const GeographyTopicCompleteBar(
            topicId: 'geo_climate_regional',
            titleTrKey: 'geo_climate_regional_title',
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

  Widget _statsCard(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C3E50) : const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : const Color(0xFF90CAF9).withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('climate_stat_title'),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDark ? Colors.white : const Color(0xFF1565C0),
            ),
          ),
          const SizedBox(height: 12),
          _statLine(context, 'climate_stat_avg', isDark),
          const SizedBox(height: 8),
          _statLine(context, 'climate_stat_hot', isDark),
          const SizedBox(height: 8),
          _statLine(context, 'climate_stat_cold', isDark),
          const SizedBox(height: 8),
          _statLine(context, 'climate_stat_rain', isDark),
          const SizedBox(height: 8),
          _statLine(context, 'climate_stat_sunny', isDark),
        ],
      ),
    );
  }

  Widget _statLine(BuildContext context, String key, bool isDark) {
    return Text(
      context.tr(key),
      style: TextStyle(
        fontSize: 14,
        height: 1.35,
        color: isDark ? Colors.white70 : AppColors.textPrimary,
      ),
    );
  }
}
