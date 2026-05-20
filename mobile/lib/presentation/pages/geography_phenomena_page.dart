import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/localization/app_localizations.dart';
import '../widgets/geography_topic_complete_bar.dart';

/// Tabiiy hodisalar (Tabiiy landshaftlar).
class GeographyPhenomenaPage extends StatelessWidget {
  const GeographyPhenomenaPage({super.key});

  static const List<({String title, String body, IconData icon, Color accent, Color bg})> _rows = [
    (title: 'geo_ph_quake', body: 'geo_ph_quake_desc', icon: Icons.vibration_rounded, accent: Color(0xFFE53935), bg: Color(0x33E53935)),
    (title: 'geo_ph_sel', body: 'geo_ph_sel_desc', icon: Icons.water_damage_rounded, accent: Color(0xFF1E88E5), bg: Color(0x331E88E5)),
    (title: 'geo_ph_qong', body: 'geo_ph_qong_desc', icon: Icons.pest_control_rounded, accent: Color(0xFF43A047), bg: Color(0x3343A047)),
    (title: 'geo_ph_drought', body: 'geo_ph_drought_desc', icon: Icons.wb_shade_rounded, accent: Color(0xFFFB8C00), bg: Color(0x33FB8C00)),
    (title: 'geo_ph_wind', body: 'geo_ph_wind_desc', icon: Icons.air_rounded, accent: Color(0xFF78909C), bg: Color(0x3378909C)),
    (title: 'geo_ph_wave', body: 'geo_ph_wave_desc', icon: Icons.thermostat_rounded, accent: Color(0xFF8E24AA), bg: Color(0x338E24AA)),
    (title: 'geo_ph_koch', body: 'geo_ph_koch_desc', icon: Icons.landslide_rounded, accent: Color(0xFF6D4C41), bg: Color(0x336D4C41)),
    (title: 'geo_ph_melt', body: 'geo_ph_melt_desc', icon: Icons.ac_unit_rounded, accent: Color(0xFF4FC3F7), bg: Color(0x334FC3F7)),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('geo_phenomena_title')),
        backgroundColor: AppColors.primaryCyan,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final e in _rows) ...[
            _tile(context, isDark, e),
            const SizedBox(height: 10),
          ],
          const GeographyTopicCompleteBar(
            topicId: 'geo_phenomena',
            titleTrKey: 'geo_phenomena_title',
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
}
