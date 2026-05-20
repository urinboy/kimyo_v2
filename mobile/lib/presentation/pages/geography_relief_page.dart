import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/localization/app_localizations.dart';
import '../widgets/geography_topic_complete_bar.dart';

/// Relyef turlari (Tabiiy landshaftlar).
class GeographyReliefPage extends StatelessWidget {
  const GeographyReliefPage({super.key});

  static const List<({String title, String body, IconData icon, Color accent, Color bg})> _rows = [
    (title: 'geo_rel_tog', body: 'geo_rel_tog_desc', icon: Icons.terrain_rounded, accent: Color(0xFF6D4C41), bg: Color(0x336D4C41)),
    (title: 'geo_rel_tekis', body: 'geo_rel_tekis_desc', icon: Icons.landscape_rounded, accent: Color(0xFF43A047), bg: Color(0x3343A047)),
    (title: 'geo_rel_cho', body: 'geo_rel_cho_desc', icon: Icons.wb_sunny_rounded, accent: Color(0xFFFB8C00), bg: Color(0x33FB8C00)),
    (title: 'geo_rel_vod', body: 'geo_rel_vod_desc', icon: Icons.waves_rounded, accent: Color(0xFF1E88E5), bg: Color(0x331E88E5)),
    (title: 'geo_rel_plat', body: 'geo_rel_plat_desc', icon: Icons.layers_rounded, accent: Color(0xFF78909C), bg: Color(0x3378909C)),
    (title: 'geo_rel_river', body: 'geo_rel_river_desc', icon: Icons.water_rounded, accent: Color(0xFF00838F), bg: Color(0x3300838F)),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('geo_relief_title')),
        backgroundColor: AppColors.primaryCyan,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            context.tr('geo_relief_uz_relyefi'),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr('geo_relief_lead'),
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: isDark ? Colors.white60 : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          for (final e in _rows) ...[
            _tile(context, isDark, e),
            const SizedBox(height: 10),
          ],
          _stats(context, isDark),
          const GeographyTopicCompleteBar(
            topicId: 'geo_relief',
            titleTrKey: 'geo_relief_title',
          ),
        ],
      ),
    );
  }

  Widget _tile(
    BuildContext context,
    bool isDark,
    ({String title, String body, IconData icon, Color accent, Color bg}) e,
  ) {
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
              color: isDark ? AppColors.iconBackgroundDark : e.bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(e.icon, color: e.accent, size: 24),
          ),
          title: Text(
            context.tr(e.title),
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
                  context.tr(e.body),
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

  Widget _stats(BuildContext context, bool isDark) {
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
            context.tr('geo_relief_stat_title'),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDark ? Colors.white : const Color(0xFF1565C0),
            ),
          ),
          const SizedBox(height: 12),
          for (final k in [
            'geo_relief_stat_high',
            'geo_relief_stat_low',
            'geo_relief_stat_avg',
            'geo_relief_stat_mtn',
            'geo_relief_stat_plain',
          ]) ...[
            Text(
              context.tr(k),
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: isDark ? Colors.white70 : AppColors.textPrimary,
              ),
            ),
            if (k != 'geo_relief_stat_plain') const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }
}
