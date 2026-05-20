import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/auth/auth_session.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/colors.dart';
import '../../core/utils/toast_util.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../injection_container.dart' as di;
import '../theme/onboarding_brand.dart';

// Qoraqalpog'iston Respublikasi tumanlari ro'yxati
const List<String> _kDistricts = [
  'Nukus shahri',
  'Amudaryo tumani',
  'Beruniy tumani',
  "Bo'zatau tumani",
  'Chimboy tumani',
  'Ellikkala tumani',
  'Kegeyli tumani',
  "Mo'ynoq tumani",
  'Nukus tumani',
  "Qanliko'l tumani",
  "Qo'ng'irot tumani",
  'Shumanay tumani',
  'Taxiatosh tumani',
  "Taxtako'pir tumani",
  "To'rtko'l tumani",
  "Xo'jayli tumani",
];

class AuthFlowPage extends StatefulWidget {
  const AuthFlowPage({super.key});

  @override
  State<AuthFlowPage> createState() => _AuthFlowPageState();
}

class _AuthFlowPageState extends State<AuthFlowPage> {
  final _formLogin = GlobalKey<FormState>();
  final _formReg = GlobalKey<FormState>();

  // Login controllers
  final _loginL = TextEditingController();
  final _passL = TextEditingController();

  // Register controllers
  final _nameR = TextEditingController();
  final _usernameR = TextEditingController();
  final _passR = TextEditingController();
  final _passC = TextEditingController();

  // Register state
  String _selectedDistrict = _kDistricts.first;
  int? _selectedSchoolNumber;

  bool _isRegister = false;
  bool _loading = false;
  bool _obscL = true;
  bool _obscR1 = true;
  bool _obscR2 = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ToastUtil.init(context);
    });
  }

  @override
  void dispose() {
    _loginL.dispose();
    _passL.dispose();
    _nameR.dispose();
    _usernameR.dispose();
    _passR.dispose();
    _passC.dispose();
    super.dispose();
  }

  String? _vLogin(String? v) {
    if (v == null || v.trim().isEmpty) return context.tr('auth_error_login');
    return null;
  }

  String? _vPass(String? v) {
    if (v == null || v.isEmpty) return context.tr('auth_error_password');
    if (v.length < 6) return context.tr('auth_error_password_len');
    return null;
  }

  Future<void> _submitLogin() async {
    if (!(_formLogin.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    final auth = di.sl<AuthSession>();
    final src = di.sl<AuthRemoteDataSource>();
    try {
      final r = await src.login(
        login: _loginL.text.trim(),
        password: _passL.text,
      );
      await auth.setSessionFromAuthResult(r);
      if (mounted) ToastUtil.showSuccess(context.tr('auth_success_login'));
    } on DioException catch (e) {
      if (!mounted) return;
      final m = formatAuthDioError(e) ?? context.tr('auth_error_generic');
      ToastUtil.showError(m);
    } catch (e) {
      if (mounted) ToastUtil.showError(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submitRegister() async {
    if (!(_formReg.currentState?.validate() ?? false)) return;
    if (_selectedSchoolNumber == null) {
      ToastUtil.showError(context.tr('auth_error_school'));
      return;
    }
    if (_passR.text != _passC.text) {
      ToastUtil.showError(context.tr('auth_error_password_mismatch'));
      return;
    }
    setState(() => _loading = true);
    final auth = di.sl<AuthSession>();
    final src = di.sl<AuthRemoteDataSource>();
    try {
      final r = await src.register(
        name: _nameR.text.trim(),
        username: _usernameR.text.trim().toLowerCase(),
        district: _selectedDistrict,
        schoolNumber: _selectedSchoolNumber!,
        password: _passR.text,
        passwordConfirmation: _passC.text,
      );
      await auth.setSessionFromAuthResult(r);
      if (mounted) ToastUtil.showSuccess(context.tr('auth_success_register'));
    } on DioException catch (e) {
      if (!mounted) return;
      final m = formatAuthDioError(e) ?? context.tr('auth_error_generic');
      ToastUtil.showError(m);
    } catch (e) {
      if (mounted) ToastUtil.showError(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final h = MediaQuery.sizeOf(context).height;
    final heroH = (h * 0.32).clamp(200.0, 280.0);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: OnboardingBrand.brandGradient(context)),
        child: Stack(
          children: [
            Positioned(
              top: 40,
              right: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: OnboardingBrand.softBlob(topRight: true, isDark: isDark),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  SizedBox(
                    height: heroH,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.science_rounded,
                              size: 44,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            context.tr('app_title'),
                            textAlign: TextAlign.center,
                            style: OnboardingBrand.heroTitle(isDark),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            context.tr('auth_hero_welcome'),
                            textAlign: TextAlign.center,
                            style: OnboardingBrand.heroSubtitle(isDark).copyWith(fontSize: 15),
                          ),
                          const SizedBox(height: 20),
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
                      elevation: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(28),
                            topRight: Radius.circular(28),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 24,
                              offset: const Offset(0, -4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(28),
                            topRight: Radius.circular(28),
                          ),
                          child: Stack(
                            children: [
                              SingleChildScrollView(
                                padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 320),
                                  switchInCurve: Curves.easeOutCubic,
                                  switchOutCurve: Curves.easeInCubic,
                                  transitionBuilder: (child, a) {
                                    final offset = Tween<Offset>(
                                      begin: const Offset(0, 0.05),
                                      end: Offset.zero,
                                    ).animate(
                                      CurvedAnimation(parent: a, curve: Curves.easeOutCubic),
                                    );
                                    return FadeTransition(
                                      opacity: a,
                                      child: SlideTransition(position: offset, child: child),
                                    );
                                  },
                                  child: _isRegister
                                      ? _buildRegisterBody(context, isDark)
                                      : _buildLoginBody(context, isDark),
                                ),
                              ),
                              if (_loading)
                                Positioned.fill(
                                  child: ColoredBox(
                                    color: (isDark ? AppColors.cardDark : Colors.white)
                                        .withValues(alpha: 0.7),
                                    child: const Center(
                                      child: Card(
                                        child: Padding(
                                          padding: EdgeInsets.all(24),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              CircularProgressIndicator(
                                                color: AppColors.primaryCyan,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
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

  Widget _buildLoginBody(BuildContext context, bool isDark) {
    return Form(
      key: _formLogin,
      child: Column(
        key: const ValueKey('login'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionTitle(
            isDark,
            context.tr('auth_login_title'),
            context.tr('auth_login_subtitle'),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _loginL,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.none,
            autocorrect: false,
            enableSuggestions: false,
            style: GoogleFonts.outfit(),
            decoration: OnboardingBrand.authField(
              context: context,
              label: context.tr('auth_login_field'),
              prefixIcon: Icons.badge_outlined,
              isDark: isDark,
            ).copyWith(hintText: context.tr('auth_username_hint')),
            validator: _vLogin,
            enabled: !_loading,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _passL,
            obscureText: _obscL,
            style: GoogleFonts.outfit(),
            decoration: OnboardingBrand.authField(
              context: context,
              label: context.tr('auth_password'),
              prefixIcon: Icons.lock_outline_rounded,
              isDark: isDark,
              suffix: IconButton(
                onPressed: _loading ? null : () => setState(() => _obscL = !_obscL),
                icon: Icon(
                  _obscL ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                ),
              ),
            ),
            validator: _vPass,
            enabled: !_loading,
            onFieldSubmitted: (_) => _submitLogin(),
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: _loading ? null : _submitLogin,
            style: OnboardingBrand.primaryCta(),
            child: Text(context.tr('auth_login_action')),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _loading ? null : () => setState(() => _isRegister = true),
            child: Text(
              context.tr('auth_no_account_register'),
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryCyan,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterBody(BuildContext context, bool isDark) {
    final borderColor = isDark ? Colors.white12 : const Color(0xFFE0E0E0);
    final fillColor = isDark ? const Color(0xFF252525) : const Color(0xFFF8F8F8);
    final labelStyle = GoogleFonts.outfit(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: isDark ? Colors.white54 : AppColors.textSecondary,
    );

    return Form(
      key: _formReg,
      child: Column(
        key: const ValueKey('register'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Material(
              color: isDark ? AppColors.iconBackgroundDark : const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(12),
              child: IconButton(
                onPressed: _loading ? null : () => setState(() => _isRegister = false),
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primaryCyan),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _sectionTitle(
            isDark,
            context.tr('auth_register_title'),
            context.tr('auth_register_subtitle'),
          ),
          const SizedBox(height: 16),

          // Full name
          TextFormField(
            controller: _nameR,
            style: GoogleFonts.outfit(),
            decoration: OnboardingBrand.authField(
              context: context,
              label: context.tr('auth_name'),
              prefixIcon: Icons.person_outline_rounded,
              isDark: isDark,
            ),
            enabled: !_loading,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return context.tr('auth_error_name');
              return null;
            },
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 14),

          // Username — tizimga kirish identifikatori (telefon shart emas)
          TextFormField(
            controller: _usernameR,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.none,
            autocorrect: false,
            enableSuggestions: false,
            style: GoogleFonts.outfit(),
            decoration: OnboardingBrand.authField(
              context: context,
              label: context.tr('auth_username'),
              prefixIcon: Icons.alternate_email_rounded,
              isDark: isDark,
            ).copyWith(hintText: context.tr('auth_username_hint')),
            enabled: !_loading,
            validator: (v) {
              final t = v?.trim() ?? '';
              if (t.isEmpty) return context.tr('auth_error_username');
              if (t.length < 3) return context.tr('auth_error_username_len');
              if (!RegExp(r'^[a-zA-Z0-9._-]+$').hasMatch(t)) {
                return context.tr('auth_error_username_chars');
              }
              return null;
            },
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 14),

          // Region — fixed
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Icon(Icons.location_city_outlined,
                    size: 20,
                    color: isDark ? Colors.white54 : AppColors.textSecondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.tr('auth_region'), style: labelStyle),
                      const SizedBox(height: 2),
                      Text(
                        "Qoraqalpog'iston Respublikasi",
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.lock_outline, size: 16, color: Colors.grey),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // District dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedDistrict,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primaryCyan),
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                dropdownColor: isDark ? const Color(0xFF252525) : Colors.white,
                hint: Text(context.tr('auth_district_hint'), style: labelStyle),
                items: _kDistricts
                    .map((d) => DropdownMenuItem(
                          value: d,
                          child: Text(d),
                        ))
                    .toList(),
                onChanged: _loading
                    ? null
                    : (v) => setState(() {
                          _selectedDistrict = v ?? _selectedDistrict;
                          _selectedSchoolNumber = null;
                        }),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // School number picker (1–58)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _selectedSchoolNumber == null
                    ? borderColor
                    : AppColors.primaryCyan.withValues(alpha: 0.4),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedSchoolNumber,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primaryCyan),
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                dropdownColor: isDark ? const Color(0xFF252525) : Colors.white,
                hint: Text(context.tr('auth_school_number_hint'), style: labelStyle),
                items: List.generate(
                  58,
                  (i) => DropdownMenuItem(
                    value: i + 1,
                    child: Text(
                      '${i + 1}-sonli umumta\'lim maktabi',
                      style: GoogleFonts.outfit(fontSize: 14),
                    ),
                  ),
                ),
                onChanged: _loading
                    ? null
                    : (v) => setState(() => _selectedSchoolNumber = v),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Password
          TextFormField(
            controller: _passR,
            obscureText: _obscR1,
            style: GoogleFonts.outfit(),
            decoration: OnboardingBrand.authField(
              context: context,
              label: context.tr('auth_password'),
              prefixIcon: Icons.lock_outline_rounded,
              isDark: isDark,
              suffix: IconButton(
                onPressed: _loading ? null : () => setState(() => _obscR1 = !_obscR1),
                icon: Icon(
                  _obscR1 ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                ),
              ),
            ),
            validator: _vPass,
            enabled: !_loading,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 14),

          // Confirm password
          TextFormField(
            controller: _passC,
            obscureText: _obscR2,
            style: GoogleFonts.outfit(),
            decoration: OnboardingBrand.authField(
              context: context,
              label: context.tr('auth_password_confirm'),
              prefixIcon: Icons.verified_user_outlined,
              isDark: isDark,
              suffix: IconButton(
                onPressed: _loading ? null : () => setState(() => _obscR2 = !_obscR2),
                icon: Icon(
                  _obscR2 ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                ),
              ),
            ),
            validator: _vPass,
            enabled: !_loading,
            onFieldSubmitted: (_) => _submitRegister(),
          ),
          const SizedBox(height: 24),

          FilledButton(
            onPressed: _loading ? null : _submitRegister,
            style: OnboardingBrand.primaryCta(),
            child: Text(context.tr('auth_register_action')),
          ),
          TextButton(
            onPressed: _loading ? null : () => setState(() => _isRegister = false),
            child: Text(
              context.tr('auth_has_account_login'),
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryCyan,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(
    bool isDark,
    String title,
    String subtitle, {
    TextAlign textAlign = TextAlign.center,
  }) {
    return Column(
      crossAxisAlignment: textAlign == TextAlign.end
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.center,
      children: [
        Text(
          title,
          textAlign: textAlign,
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          textAlign: textAlign,
          style: GoogleFonts.outfit(
            fontSize: 14,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}
