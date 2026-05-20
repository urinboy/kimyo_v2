import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/colors.dart';

/// Birinchi ochilish oqimlari: splash, til, auth — bir xil rang va o‘lchamlar
abstract final class OnboardingBrand {
  static const _cyan = AppColors.primaryCyan;
  static const _blue = AppColors.activeBlue;

  static List<Color> get gradientTopLight => [
        const Color(0xFF6B4B9E).withValues(alpha: 0.95),
        _blue.withValues(alpha: 0.88),
        _cyan.withValues(alpha: 0.85),
      ];

  static List<Color> get gradientTopDark => [
        const Color(0xFF1A0F2E).withValues(alpha: 0.98),
        const Color(0xFF0D2B3D).withValues(alpha: 0.95),
        const Color(0xFF0A3A42).withValues(alpha: 0.9),
      ];

  static LinearGradient brandGradient(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: dark ? gradientTopDark : gradientTopLight,
    );
  }

  static BoxDecoration softBlob({required bool topRight, bool isDark = false}) {
    return BoxDecoration(
      shape: BoxShape.circle,
      color: (isDark ? Colors.white : AppColors.primaryPurple).withValues(alpha: 0.08),
    );
  }

  static TextStyle heroTitle(bool isDark) {
    return GoogleFonts.outfit(
      fontSize: 28,
      fontWeight: FontWeight.w800,
      height: 1.15,
      color: Colors.white,
      letterSpacing: -0.5,
    );
  }

  static TextStyle heroSubtitle(bool isDark) {
    return GoogleFonts.outfit(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      height: 1.4,
      color: Colors.white.withValues(alpha: 0.9),
    );
  }

  static InputDecoration authField({
    required BuildContext context,
    required String label,
    IconData? prefixIcon,
    Widget? suffix,
    bool isDark = false,
  }) {
    final base = isDark
        ? const Color(0xFF1E1E1E)
        : Colors.white;
    final border = isDark
        ? const Color(0xFF2D2D2D)
        : const Color(0xFFE0E0E0);

    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.outfit(
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        fontSize: 14,
      ),
      filled: true,
      fillColor: isDark ? base : const Color(0xFFFAFAFA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      prefixIcon: prefixIcon == null
          ? null
          : Icon(prefixIcon, size: 22, color: _cyan),
      suffixIcon: suffix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _cyan, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.iconRed),
      ),
    );
  }

  static ButtonStyle primaryCta() {
    return FilledButton.styleFrom(
      elevation: 0,
      backgroundColor: _cyan,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      textStyle: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    );
  }
}
