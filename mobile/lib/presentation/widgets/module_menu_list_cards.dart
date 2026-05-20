import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

/// Kimyo / Geografiya / Hujjatlar hub kartochkalari uchun yagona o‘lchamlar.
abstract final class ModuleMenuListTokens {
  ModuleMenuListTokens._();

  static const double cardRadius = 12;
  static const double iconBoxRadius = 10;
  static const EdgeInsets iconPadding = EdgeInsets.all(10);
  static const double iconSize = 26;
  /// Hujjatlar hub: ikonka qutisi balandligi (padding 10×2 + ikonka 26).
  static const double iconTileExtent = 46;

  static const double titleFontSize = 16;
  static const FontWeight titleWeight = FontWeight.bold;

  static const double subTitleFontSize = 14;
  static const FontWeight subTitleWeight = FontWeight.w500;
  static const double subChevronSize = 20;

  /// Hujjatlar hub bilan bir xil — kartochka ichki padding.
  static const EdgeInsets cardPadding = EdgeInsets.all(16);
}

/// Yuqori darajadagi bo‘lim — [ExpansionTile].
class ModuleExpandableListCard extends StatelessWidget {
  final String title;
  final IconData icon;
  /// Masalan: [AppColors.primaryBlue] yoki [AppColors.primaryPurple].
  final Color accentColor;
  /// Yorug‘ rejimda ikonka fon rangi.
  final Color iconBackgroundLight;
  final List<Widget> children;

  const ModuleExpandableListCard({
    super.key,
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.iconBackgroundLight,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconBg = isDark ? AppColors.iconBackgroundDark : iconBackgroundLight;

    return Material(
      color: isDark ? AppColors.cardDark : Colors.white,
      borderRadius: BorderRadius.circular(ModuleMenuListTokens.cardRadius),
      elevation: isDark ? 0 : 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          unselectedWidgetColor: isDark ? Colors.white70 : Colors.black54,
          listTileTheme: ListTileThemeData(
            dense: true,
            minVerticalPadding: 0,
            contentPadding: EdgeInsets.zero,
            horizontalTitleGap: 16,
            minLeadingWidth: ModuleMenuListTokens.iconTileExtent,
          ),
        ),
        child: ExpansionTile(
          dense: true,
          visualDensity: VisualDensity.compact,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ModuleMenuListTokens.cardRadius),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ModuleMenuListTokens.cardRadius),
          ),
          tilePadding: ModuleMenuListTokens.cardPadding,
          childrenPadding: EdgeInsets.zero,
          leading: SizedBox(
            width: ModuleMenuListTokens.iconTileExtent,
            height: ModuleMenuListTokens.iconTileExtent,
            child: Center(
              child: Container(
                padding: ModuleMenuListTokens.iconPadding,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(ModuleMenuListTokens.iconBoxRadius),
                ),
                child: Icon(icon, color: accentColor, size: ModuleMenuListTokens.iconSize),
              ),
            ),
          ),
          title: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: TextStyle(
                fontWeight: ModuleMenuListTokens.titleWeight,
                fontSize: ModuleMenuListTokens.titleFontSize,
                height: 1.2,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
          iconColor: isDark ? Colors.white70 : Colors.grey,
          collapsedIconColor: isDark ? Colors.white54 : Colors.grey,
          children: children,
        ),
      ),
    );
  }
}

/// Bir bosishda navigatsiya — o‘ngda chevron.
class ModuleNavListCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accentColor;
  final Color iconBackgroundLight;
  final VoidCallback onTap;

  const ModuleNavListCard({
    super.key,
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.iconBackgroundLight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconBg = isDark ? AppColors.iconBackgroundDark : iconBackgroundLight;

    return Material(
      color: isDark ? AppColors.cardDark : Colors.white,
      borderRadius: BorderRadius.circular(ModuleMenuListTokens.cardRadius),
      elevation: isDark ? 0 : 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: InkWell(
        borderRadius: BorderRadius.circular(ModuleMenuListTokens.cardRadius),
        onTap: onTap,
        child: Padding(
          padding: ModuleMenuListTokens.cardPadding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: ModuleMenuListTokens.iconPadding,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius:
                      BorderRadius.circular(ModuleMenuListTokens.iconBoxRadius),
                ),
                child:
                    Icon(icon, color: accentColor, size: ModuleMenuListTokens.iconSize),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: ModuleMenuListTokens.titleWeight,
                    fontSize: ModuleMenuListTokens.titleFontSize,
                    height: 1.2,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isDark ? Colors.white38 : Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Expand ichidagi qator.
class ModuleMenuSubItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const ModuleMenuSubItem({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: ModuleMenuListTokens.subTitleFontSize,
                  fontWeight: ModuleMenuListTokens.subTitleWeight,
                  color: isDark ? Colors.white70 : AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              size: ModuleMenuListTokens.subChevronSize,
              color: isDark ? Colors.white38 : AppColors.textPrimary,
            ),
          ],
        ),
      ),
    );
  }
}
