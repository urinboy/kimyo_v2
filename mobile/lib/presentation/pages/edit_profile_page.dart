import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../core/auth/auth_session.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/colors.dart';
import '../../core/utils/toast_util.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/datasources/reference_remote_data_source.dart';
import '../../injection_container.dart' as di;

/// Profil va parol tahriri — alohida ekran. Maktab/sinf bazadan; yangi qo'shish faqat admin.
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _currentPwController = TextEditingController();
  final _newPwController = TextEditingController();
  final _confirmPwController = TextEditingController();

  List<MobileSchoolListItem> _schools = [];
  List<String> _gradeLabels = [];
  int? _selectedSchoolId;
  String? _selectedGrade;

  bool _refLoading = true;
  bool _refOk = false;

  bool _saving = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  bool get _isAdmin => di.sl<AuthSession>().currentUser?.role == 'admin';

  @override
  void initState() {
    super.initState();
    final u = di.sl<AuthSession>().currentUser;
    if (u != null) {
      _nameController.text = u.name;
      _phoneController.text = u.phone ?? '';
      _selectedSchoolId = u.schoolId;
      final g = u.grade?.trim();
      _selectedGrade = (g == null || g.isEmpty) ? null : g;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadReference());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _currentPwController.dispose();
    _newPwController.dispose();
    _confirmPwController.dispose();
    super.dispose();
  }

  Future<void> _loadReference() async {
    setState(() {
      _refLoading = true;
      _refOk = false;
    });
    try {
      final ref = di.sl<ReferenceRemoteDataSource>();
      final schools = await ref.fetchSchools();
      final grades = await ref.fetchGradeLabels();
      if (!mounted) return;

      final u = di.sl<AuthSession>().currentUser;
      var selSchool = _selectedSchoolId ?? u?.schoolId;
      if (selSchool != null && !schools.any((s) => s.id == selSchool)) {
        selSchool = null;
      }

      var selGrade = _selectedGrade ?? u?.grade?.trim();
      if (selGrade != null && selGrade.isEmpty) selGrade = null;

      var gradeList = List<String>.from(grades);
      if (selGrade != null && !gradeList.contains(selGrade)) {
        gradeList = [...gradeList, selGrade];
        gradeList.sort();
      }

      setState(() {
        _schools = schools;
        _gradeLabels = gradeList;
        _selectedSchoolId = selSchool;
        _selectedGrade = selGrade;
        _refLoading = false;
        _refOk = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _refLoading = false;
        _refOk = false;
      });
    }
  }

  String? _validatePasswordIntent(BuildContext context) {
    final c = _currentPwController.text;
    final n = _newPwController.text;
    final cf = _confirmPwController.text;
    final anyNonEmpty = c.isNotEmpty || n.isNotEmpty || cf.isNotEmpty;
    if (!anyNonEmpty) return null;
    if (c.isEmpty || n.isEmpty || cf.isEmpty) {
      return context.tr('profile_password_fill_all');
    }
    if (n.length < 6) return context.tr('profile_password_too_short');
    if (n != cf) return context.tr('profile_password_mismatch');
    return null;
  }

  Future<void> _save() async {
    if (!_refOk) {
      ToastUtil.showError(context.tr('profile_reference_load_failed'));
      return;
    }

    final pwErr = _validatePasswordIntent(context);
    if (pwErr != null) {
      ToastUtil.showError(pwErr);
      return;
    }

    if (_saving) return;
    setState(() => _saving = true);

    final wantsPw = _currentPwController.text.isNotEmpty;

    try {
      if (wantsPw) {
        await di.sl<AuthRemoteDataSource>().changePassword(
              currentPassword: _currentPwController.text,
              password: _newPwController.text,
              passwordConfirmation: _confirmPwController.text,
            );
      }

      await di.sl<AuthSession>().updateProfile(
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
            schoolId: _selectedSchoolId,
            grade: _selectedGrade,
          );

      if (wantsPw && mounted) {
        _currentPwController.clear();
        _newPwController.clear();
        _confirmPwController.clear();
      }

      if (mounted) Navigator.pop(context, true);
    } on DioException catch (e) {
      if (mounted) {
        final m = formatAuthDioError(e);
        ToastUtil.showError(m ?? context.tr('profile_update_error'));
      }
    } catch (_) {
      if (mounted) ToastUtil.showError(context.tr('profile_update_error'));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _onAddSchoolPressed() async {
    if (!_isAdmin || _saving) return;

    final nameCtrl = TextEditingController();
    final cityCtrl = TextEditingController();

    final submit = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.cardDark : Colors.white,
          title: Text(
            context.tr('profile_add_school'),
            style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: context.tr('profile_new_school_name'),
                  labelStyle: TextStyle(color: isDark ? Colors.white70 : AppColors.textSecondary),
                ),
                style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cityCtrl,
                decoration: InputDecoration(
                  labelText: context.tr('profile_new_school_city'),
                  labelStyle: TextStyle(color: isDark ? Colors.white70 : AppColors.textSecondary),
                ),
                style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(context.tr('cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(context.tr('profile_save')),
            ),
          ],
        );
      },
    );

    try {
      if (submit == true && mounted) {
        final name = nameCtrl.text.trim();
        if (name.isEmpty) {
          ToastUtil.showError(context.tr('profile_new_school_name'));
          return;
        }
        final city = cityCtrl.text.trim();
        final created = await di.sl<ReferenceRemoteDataSource>().createSchool(
              name: name,
              city: city.isEmpty ? null : city,
            );
        await _loadReference();
        if (mounted) {
          setState(() => _selectedSchoolId = created.id);
        }
      }
    } on DioException catch (e) {
      if (mounted) {
        ToastUtil.showError(formatAuthDioError(e) ?? context.tr('profile_update_error'));
      }
    } catch (_) {
      if (mounted) ToastUtil.showError(context.tr('profile_update_error'));
    } finally {
      nameCtrl.dispose();
      cityCtrl.dispose();
    }
  }

  Future<void> _onAddGradePressed() async {
    if (!_isAdmin || _saving) return;

    final labelCtrl = TextEditingController();

    final submit = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.cardDark : Colors.white,
          title: Text(
            context.tr('profile_add_grade'),
            style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
          ),
          content: TextField(
            controller: labelCtrl,
            decoration: InputDecoration(
              labelText: context.tr('profile_new_grade_label'),
              labelStyle: TextStyle(color: isDark ? Colors.white70 : AppColors.textSecondary),
            ),
            style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(context.tr('cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(context.tr('profile_save')),
            ),
          ],
        );
      },
    );

    try {
      if (submit == true && mounted) {
        final label = labelCtrl.text.trim();
        if (label.isEmpty) {
          ToastUtil.showError(context.tr('profile_new_grade_label'));
          return;
        }
        final created = await di.sl<ReferenceRemoteDataSource>().createGradeLabel(label: label);
        await _loadReference();
        if (mounted) {
          setState(() => _selectedGrade = created);
        }
      }
    } on DioException catch (e) {
      if (mounted) {
        ToastUtil.showError(formatAuthDioError(e) ?? context.tr('profile_update_error'));
      }
    } catch (_) {
      if (mounted) ToastUtil.showError(context.tr('profile_update_error'));
    } finally {
      labelCtrl.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(context.tr('profile_edit')),
        backgroundColor: AppColors.primaryGreenProfile,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _saving ? null : () => Navigator.pop(context),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: (_saving || !_refOk) ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      context.tr('profile_save'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                context,
                context.tr('profile_name'),
                Icons.person_rounded,
                _nameController,
                isDark,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                context,
                context.tr('profile_phone'),
                Icons.phone_rounded,
                _phoneController,
                isDark,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildSchoolSection(context, isDark),
              const SizedBox(height: 16),
              _buildGradeSection(context, isDark),
              const SizedBox(height: 28),
              Text(
                context.tr('profile_password_section'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.tr('profile_password_hint'),
                style: TextStyle(
                  fontSize: 12,
                  height: 1.35,
                  color: isDark ? Colors.white54 : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                context,
                context.tr('profile_current_password'),
                Icons.lock_outline_rounded,
                _currentPwController,
                isDark,
                _obscureCurrent,
                () => setState(() => _obscureCurrent = !_obscureCurrent),
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                context,
                context.tr('profile_new_password'),
                Icons.lock_rounded,
                _newPwController,
                isDark,
                _obscureNew,
                () => setState(() => _obscureNew = !_obscureNew),
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                context,
                context.tr('profile_confirm_password'),
                Icons.verified_user_outlined,
                _confirmPwController,
                isDark,
                _obscureConfirm,
                () => setState(() => _obscureConfirm = !_obscureConfirm),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSchoolSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 4),
          child: Text(
            context.tr('profile_school'),
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white54 : AppColors.textSecondary,
            ),
          ),
        ),
        if (_refLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator(color: AppColors.primaryCyan)),
          )
        else if (!_refOk)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('profile_reference_load_failed'),
                  style: TextStyle(color: isDark ? Colors.white70 : AppColors.textSecondary),
                ),
                TextButton.icon(
                  onPressed: _saving ? null : _loadReference,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(context.tr('profile_retry')),
                ),
              ],
            ),
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int?>(
                      value: _selectedSchoolId,
                      isExpanded: true,
                      hint: Text(
                        context.tr('profile_school_pick'),
                        style: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                      ),
                      icon: Icon(Icons.arrow_drop_down_rounded,
                          color: isDark ? Colors.white38 : Colors.black26),
                      dropdownColor: isDark ? AppColors.cardDark : Colors.white,
                      style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary, fontSize: 16),
                      onChanged: _saving
                          ? null
                          : (int? v) => setState(() => _selectedSchoolId = v),
                      items: [
                        DropdownMenuItem<int?>(
                          value: null,
                          child: Text(context.tr('profile_not_set')),
                        ),
                        ..._schools.map(
                          (s) => DropdownMenuItem<int?>(
                            value: s.id,
                            child: Text(
                              s.displayLine,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_isAdmin) ...[
                const SizedBox(width: 4),
                IconButton(
                  onPressed: _saving ? null : _onAddSchoolPressed,
                  tooltip: context.tr('profile_add_school'),
                  icon: Icon(
                    Icons.add_circle_outline_rounded,
                    color: isDark ? Colors.lightGreenAccent : AppColors.primaryGreenProfile,
                  ),
                ),
              ],
            ],
          ),
      ],
    );
  }

  Widget _buildGradeSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 4),
          child: Text(
            context.tr('profile_class'),
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white54 : AppColors.textSecondary,
            ),
          ),
        ),
        if (_refLoading)
          const SizedBox.shrink()
        else if (!_refOk)
          const SizedBox.shrink()
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: _selectedGrade,
                      isExpanded: true,
                      hint: Text(
                        context.tr('profile_grade_pick'),
                        style: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                      ),
                      icon: Icon(Icons.arrow_drop_down_rounded,
                          color: isDark ? Colors.white38 : Colors.black26),
                      dropdownColor: isDark ? AppColors.cardDark : Colors.white,
                      style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary, fontSize: 16),
                      onChanged: _saving
                          ? null
                          : (String? v) => setState(() => _selectedGrade = v),
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text(context.tr('profile_not_set')),
                        ),
                        ..._gradeLabels.map(
                          (g) => DropdownMenuItem<String?>(
                            value: g,
                            child: Text(g),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_isAdmin) ...[
                const SizedBox(width: 4),
                IconButton(
                  onPressed: _saving ? null : _onAddGradePressed,
                  tooltip: context.tr('profile_add_grade'),
                  icon: Icon(
                    Icons.add_circle_outline_rounded,
                    color: isDark ? Colors.lightGreenAccent : AppColors.primaryGreenProfile,
                  ),
                ),
              ],
            ],
          ),
      ],
    );
  }

  Widget _buildTextField(
    BuildContext context,
    String label,
    IconData icon,
    TextEditingController controller,
    bool isDark, {
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 4),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white54 : AppColors.textSecondary,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            enabled: !_saving,
            style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
            decoration: InputDecoration(
              icon: Icon(icon, color: isDark ? Colors.white38 : Colors.black26),
              border: InputBorder.none,
              hintText: label,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(
    BuildContext context,
    String label,
    IconData icon,
    TextEditingController controller,
    bool isDark,
    bool obscure,
    VoidCallback onToggleObscure,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 4),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white54 : AppColors.textSecondary,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            enabled: !_saving,
            keyboardType: TextInputType.visiblePassword,
            style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
            decoration: InputDecoration(
              icon: Icon(icon, color: isDark ? Colors.white38 : Colors.black26),
              border: InputBorder.none,
              hintText: label,
              suffixIcon: IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
                onPressed: _saving ? null : onToggleObscure,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
