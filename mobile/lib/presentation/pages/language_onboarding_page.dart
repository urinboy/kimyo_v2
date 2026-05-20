import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/auth/auth_session.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/locale_service.dart';
import '../../core/theme/colors.dart';
import '../../injection_container.dart' as di;
import '../theme/onboarding_brand.dart';
import '../widgets/language_flag.dart';

class LanguageOnboardingPage extends StatefulWidget {
  const LanguageOnboardingPage({super.key});

  @override
  State<LanguageOnboardingPage> createState() => _LanguageOnboardingPageState();
}

class _LanguageOnboardingPageState extends State<LanguageOnboardingPage> {
  String _selected = 'uz';

  @override
  void initState() {
    super.initState();
    _selected = LocaleService().locale.value.languageCode;
  }

  Future<void> _continue() async {
    await LocaleService().setLocaleFromOnboarding(_selected);
    di.sl<AuthSession>().markLanguageOnboardingComplete();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final h = MediaQuery.sizeOf(context).height;
    final topH = (h * 0.24).clamp(160.0, 220.0);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: OnboardingBrand.brandGradient(context)),
        child: Stack(
          children: [
            Positioned(
              bottom: 100,
              right: -30,
              child: IgnorePointer(
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: OnboardingBrand.softBlob(topRight: true, isDark: isDark),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  SizedBox(
                    height: topH,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              context.tr('onboarding_badge'),
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            context.tr('onboarding_lang_title'),
                            textAlign: TextAlign.center,
                            style: OnboardingBrand.heroTitle(isDark).copyWith(fontSize: 26),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            context.tr('onboarding_lang_subtitle'),
                            textAlign: TextAlign.center,
                            style: OnboardingBrand.heroSubtitle(isDark).copyWith(fontSize: 14.5),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Material(
                      color: isDark ? AppColors.scaffoldBackgroundDark : AppColors.scaffoldBackground,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(28),
                            topRight: Radius.circular(28),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, -4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: ListView(
                                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                                children: [
                                  _langTile('Oʻzbek tili', 'uz', isDark),
                                  const SizedBox(height: 12),
                                  _langTile('Русский', 'ru', isDark),
                                  const SizedBox(height: 12),
                                  _langTile('English', 'en', isDark),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                              child: FilledButton(
                                onPressed: _continue,
                                style: OnboardingBrand.primaryCta().copyWith(
                                  minimumSize: const WidgetStatePropertyAll(
                                    Size(double.infinity, 52),
                                  ),
                                ),
                                child: Text(
                                  context.tr('onboarding_lang_continue'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _langTile(
    String label,
    String code,
    bool isDark,
  ) {
    final active = _selected == code;
    return Material(
      color: isDark
          ? (active ? const Color(0xFF152A2E) : const Color(0xFF1E1E1E))
          : (active ? const Color(0xFFE0F7FA) : const Color(0xFFFAFAFA)),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () => setState(() => _selected = code),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: active ? AppColors.primaryCyan : (isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE0E0E0)),
              width: active ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: LanguageFlag(
                    langCode: code,
                    width: 40,
                    height: 28,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
              if (active)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primaryCyan,
                  size: 26,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
