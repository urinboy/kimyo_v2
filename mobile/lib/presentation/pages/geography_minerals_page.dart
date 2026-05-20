import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/localization/app_localizations.dart';
import '../widgets/geography_topic_complete_bar.dart';

/// Foydali qazilmalar (Geologik tuzilish).
class GeographyMineralsPage extends StatelessWidget {
  const GeographyMineralsPage({super.key});

  static const List<({String title, String sub, String body, IconData icon, Color accent, Color bg})> _rows = [
    (title: 'geo_min_gold', sub: 'geo_min_gold_sub', body: 'geo_min_gold_desc', icon: Icons.star_rounded, accent: Color(0xFFF9A825), bg: Color(0x33F9A825)),
    (title: 'geo_min_copper', sub: 'geo_min_copper_sub', body: 'geo_min_copper_desc', icon: Icons.hardware_rounded, accent: Color(0xFFEF6C00), bg: Color(0x33EF6C00)),
    (title: 'geo_min_gas', sub: 'geo_min_gas_sub', body: 'geo_min_gas_desc', icon: Icons.local_fire_department_rounded, accent: Color(0xFF1E88E5), bg: Color(0x331E88E5)),
    (title: 'geo_min_oil', sub: 'geo_min_oil_sub', body: 'geo_min_oil_desc', icon: Icons.local_gas_station_rounded, accent: Color(0xFF6D4C41), bg: Color(0x336D4C41)),
    (title: 'geo_min_coal', sub: 'geo_min_coal_sub', body: 'geo_min_coal_desc', icon: Icons.local_fire_department_outlined, accent: Color(0xFF546E7A), bg: Color(0x33546E7A)),
    (title: 'geo_min_uranium', sub: 'geo_min_uranium_sub', body: 'geo_min_uranium_desc', icon: Icons.warning_amber_rounded, accent: Color(0xFF43A047), bg: Color(0x3343A047)),
    (title: 'geo_min_build', sub: 'geo_min_build_sub', body: 'geo_min_build_desc', icon: Icons.construction_rounded, accent: Color(0xFF78909C), bg: Color(0x3378909C)),
    (title: 'geo_min_salt', sub: 'geo_min_salt_sub', body: 'geo_min_salt_desc', icon: Icons.diamond_rounded, accent: Color(0xFF8E24AA), bg: Color(0x338E24AA)),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('geo_mins_title')),
        backgroundColor: AppColors.primaryCyan,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            context.tr('geo_mins_head'),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr('geo_mins_lead'),
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: isDark ? Colors.white60 : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          for (final e in _rows) ...[
            _row(context, isDark, e),
            const SizedBox(height: 10),
          ],
          _statBox(context, isDark),
          const GeographyTopicCompleteBar(
            topicId: 'geo_minerals',
            titleTrKey: 'geo_mins_title',
          ),
        ],
      ),
    );
  }

  Widget _row(
    BuildContext context,
    bool isDark,
    ({String title, String sub, String body, IconData icon, Color accent, Color bg}) e,
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
          subtitle: Text(
            context.tr(e.sub),
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white54 : AppColors.textSecondary,
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

  Widget _statBox(BuildContext context, bool isDark) {
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
          Text(
            context.tr('geo_mins_stat_title'),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDark ? Colors.white : const Color(0xFF1A237E),
            ),
          ),
          const SizedBox(height: 12),
          for (final k in [
            'geo_mins_stat_types',
            'geo_mins_stat_mines',
            'geo_mins_stat_gold',
            'geo_mins_stat_uran',
            'geo_mins_stat_export',
          ]) ...[
            Text(
              context.tr(k),
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: isDark ? Colors.white70 : AppColors.textPrimary,
              ),
            ),
            if (k != 'geo_mins_stat_export') const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }
}
