import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/auth/auth_session.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/colors.dart';
import '../../injection_container.dart' as di;
import '../theme/onboarding_brand.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key, required this.onReady});

  final void Function() onReady;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _progress;
  late final Animation<double> _logoScale;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;
  double _loadProgress = 0;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _progress = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..addListener(() {
        if (mounted) {
          setState(() => _loadProgress = _progress.value * 0.95);
        }
      });

    _logoScale = Tween<double>(begin: 0.78, end: 1.0).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: Curves.easeOutBack,
      ),
    );
    _textOpacity = Tween<double>(begin: 0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.35, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(
      CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _entrance.forward();
    _start();
  }

  Future<void> _start() async {
    await Future.wait<void>([
      _progress.forward(),
      di.sl<AuthSession>().tryValidateOrClear(),
    ]);
    if (!mounted) return;
    setState(() => _loadProgress = 1.0);
    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (mounted) widget.onReady();
  }

  @override
  void dispose() {
    _entrance.dispose();
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: OnboardingBrand.brandGradient(context)),
        child: Stack(
          children: [
            // Yumshoq doirachalar
            Positioned(
              top: -60,
              right: -40,
              child: IgnorePointer(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: OnboardingBrand.softBlob(topRight: true, isDark: isDark),
                ),
              ),
            ),
            Positioned(
              bottom: 120,
              left: -50,
              child: IgnorePointer(
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: OnboardingBrand.softBlob(topRight: false, isDark: isDark),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: _logoScale,
                      child: Container(
                        padding: const EdgeInsets.all(26),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 40,
                              offset: const Offset(0, 16),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.science_rounded,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SlideTransition(
                      position: _textSlide,
                      child: FadeTransition(
                        opacity: _textOpacity,
                        child: Column(
                          children: [
                            Text(
                              context.tr('app_title'),
                              textAlign: TextAlign.center,
                              style: OnboardingBrand.heroTitle(isDark),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              context.tr('splash_tagline'),
                              textAlign: TextAlign.center,
                              style: OnboardingBrand.heroSubtitle(isDark).copyWith(
                                fontSize: 14.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              context.tr('splash_loading'),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.75),
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 32,
              right: 32,
              bottom: 48,
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _loadProgress,
                      minHeight: 4,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      color: AppColors.activeBlue,
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
}
