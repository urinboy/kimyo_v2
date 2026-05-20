import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/localization/app_localizations.dart';
import '../widgets/geography_topic_complete_bar.dart';

/// Tog' jinslari / tog' tizimlari (Geologik tuzilish).
class GeographyRocksPage extends StatelessWidget {
  const GeographyRocksPage({super.key});

  static const List<({String name, String m, String body, Color accent, Color bg})> _mountains = [
    (name: 'geo_mtn_tyan', m: 'geo_mtn_tyan_m', body: 'geo_mtn_tyan_desc', accent: Color(0xFF1E88E5), bg: Color(0x331E88E5)),
    (name: 'geo_mtn_pamir', m: 'geo_mtn_pamir_m', body: 'geo_mtn_pamir_desc', accent: Color(0xFF43A047), bg: Color(0x3343A047)),
    (name: 'geo_mtn_nurota', m: 'geo_mtn_nurota_m', body: 'geo_mtn_nurota_desc', accent: Color(0xFF8D6E63), bg: Color(0x338D6E63)),
    (name: 'geo_mtn_kopet', m: 'geo_mtn_kopet_m', body: 'geo_mtn_kopet_desc', accent: Color(0xFFFB8C00), bg: Color(0x33FB8C00)),
    (name: 'geo_mtn_qoratov', m: 'geo_mtn_qoratov_m', body: 'geo_mtn_qoratov_desc', accent: Color(0xFFF9A825), bg: Color(0x33F9A825)),
    (name: 'geo_mtn_qurama', m: 'geo_mtn_qurama_m', body: 'geo_mtn_qurama_desc', accent: Color(0xFF00838F), bg: Color(0x3300838F)),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? AppColors.scaffoldBackgroundDark : Colors.grey[50];
    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: Text(context.tr('geo_rocks_title')),
        backgroundColor: AppColors.primaryCyan,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final e in _mountains) ...[
            _mountainTile(context, isDark, e),
            const SizedBox(height: 10),
          ],
          _summary(context, isDark),
          const GeographyTopicCompleteBar(
            topicId: 'geo_rocks',
            titleTrKey: 'geo_rocks_title',
          ),
        ],
      ),
    );
  }

  Widget _mountainTile(
    BuildContext context,
    bool isDark,
    ({String name, String m, String body, Color accent, Color bg}) e,
  ) {
    final name = e.name;
    final m = e.m;
    final body = e.body;
    final accent = e.accent;
    final bg = e.bg;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade200;
    return Material(
      color: isDark ? AppColors.cardDark : Colors.white,
      elevation: isDark ? 0 : 0.5,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          childrenPadding: EdgeInsets.zero,
          leading: SizedBox(
            width: 48,
            height: 48,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: isDark ? AppColors.iconBackgroundDark : bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.landscape_rounded, color: accent, size: 24),
            ),
          ),
          title: Text(
            context.tr(name),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              context.tr(m),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white60 : accent,
              ),
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
                  context.tr(body),
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

  Widget _summary(BuildContext context, bool isDark) {
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200;
    final fill = isDark ? AppColors.cardDark : Colors.white;
    final titleColor = isDark ? AppColors.primaryCyan : const Color(0xFF00838F);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.terrain_rounded, color: titleColor, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.tr('geo_mount_info_title'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...[
            'geo_mount_info_share',
            'geo_mount_info_peak',
            'geo_mount_info_systems',
            'geo_mount_info_glaciers',
            'geo_mount_info_value',
          ].expand((k) {
            return [
              Text(
                context.tr(k),
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                ),
              ),
              if (k != 'geo_mount_info_value') const SizedBox(height: 6),
            ];
          }),
        ],
      ),
    );
  }
}
