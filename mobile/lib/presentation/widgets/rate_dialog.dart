import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/auth/auth_session.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/network/dio_client.dart';
import '../../core/services/app_review_local_storage.dart';
import '../../core/theme/colors.dart';
import '../../core/utils/toast_util.dart';
import '../../injection_container.dart';

class RateDialog extends StatefulWidget {
  const RateDialog({super.key});

  @override
  State<RateDialog> createState() => _RateDialogState();
}

class _RateDialogState extends State<RateDialog> {
  int _rating = 0;
  bool _submitting = false;
  bool _loading = true;
  bool _locked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitial());
  }

  Future<void> _loadInitial() async {
    final prefs = sl<SharedPreferences>();
    final auth = sl<AuthSession>();
    final dio = sl<DioClient>().dio;

    final state = await AppReviewLocalStorage.resolveDisplayState(
      prefs: prefs,
      auth: auth,
      dio: dio,
    );

    if (!mounted) return;
    setState(() {
      _rating = state.rating;
      _locked = state.locked;
      _loading = false;
    });
  }

  Future<void> _syncAfterConflict() async {
    final prefs = sl<SharedPreferences>();
    final auth = sl<AuthSession>();
    final dio = sl<DioClient>().dio;
    final state = await AppReviewLocalStorage.resolveDisplayState(
      prefs: prefs,
      auth: auth,
      dio: dio,
    );
    if (!mounted) return;
    setState(() {
      _rating = state.rating;
      _locked = state.locked;
    });
  }

  Future<void> _submit() async {
    if (_rating < 1 || _submitting || _locked) return;
    setState(() => _submitting = true);
    final thanksMsg =
        context.tr('rate_thanks').replaceFirst('{}', _rating.toString());
    try {
      final dio = sl<DioClient>().dio;
      final res = await dio.post<Map<String, dynamic>>(
        '/mobile/reviews',
        data: <String, dynamic>{'rating': _rating},
      );
      if (!mounted) return;
      final body = res.data;
      if (body != null && body['status'] == 'success') {
        await AppReviewLocalStorage.saveRating(
          sl<SharedPreferences>(),
          _rating,
        );
        if (!mounted) return;
        Navigator.pop(context);
        ToastUtil.showSuccess(thanksMsg);
        return;
      }
      ToastUtil.showError(context.tr('rate_submit_failed'));
    } on DioException catch (e) {
      if (!mounted) return;
      if (e.response?.statusCode == 409) {
        await _syncAfterConflict();
        if (!mounted) return;
        ToastUtil.showInfo(context.tr('rate_already_submitted'));
        return;
      }
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        ToastUtil.showError(context.tr('rate_error_network'));
        return;
      }
      ToastUtil.showError(context.tr('rate_submit_failed'));
    } catch (_) {
      if (mounted) {
        ToastUtil.showError(context.tr('rate_submit_failed'));
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Widget _buildStarRow(BuildContext context, bool isDark, double maxWidth) {
    const tapSide = 44.0;
    const starSize = 36.0;

    return SizedBox(
      width: maxWidth,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: (_submitting || _locked)
                    ? null
                    : () => setState(() => _rating = index + 1),
                customBorder: const CircleBorder(),
                child: SizedBox(
                  width: tapSide,
                  height: tapSide,
                  child: Center(
                    child: Icon(
                      index < _rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: index < _rating
                          ? Colors.amber
                          : (isDark ? Colors.white24 : Colors.black12),
                      size: starSize,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSubmitActions(BuildContext context, bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 340;

        if (narrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: (_rating == 0 || _submitting) ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.activeBlue,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      isDark ? Colors.white10 : Colors.black12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  elevation: 0,
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        context.tr('rate_submit'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _submitting ? null : () => Navigator.pop(context),
                child: Text(
                  context.tr('cancel'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.activeBlue,
                  ),
                ),
              ),
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: _submitting ? null : () => Navigator.pop(context),
              child: Text(
                context.tr('cancel'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.activeBlue,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: (_rating == 0 || _submitting) ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.activeBlue,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    isDark ? Colors.white10 : Colors.black12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                elevation: 0,
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      context.tr('rate_submit'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.sizeOf(context);
    final screenW = size.width;
    final dialogMaxW = math.min(440.0, screenW * 0.92);
    final insetH = math.max(16.0, screenW * 0.04);

    final subtitleText = _locked && _rating >= 1
        ? context.tr('rate_readonly_subtitle').replaceFirst('{}', '$_rating')
        : context.tr('rate_subtitle');

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: insetH, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogMaxW,
          maxHeight: size.height * 0.88,
        ),
        child: Padding(
          padding: EdgeInsets.all(math.max(16.0, screenW * 0.045).clamp(16.0, 28.0)),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.tr('rate_title'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: math.min(22.0, math.max(17.0, screenW * 0.052)),
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  subtitleText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: math.min(15.0, math.max(12.0, screenW * 0.038)),
                    color: isDark ? Colors.white54 : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child:
                        CircularProgressIndicator(color: AppColors.primaryCyan),
                  )
                else ...[
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return _buildStarRow(
                        context,
                        isDark,
                        constraints.maxWidth,
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  if (_locked)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            _submitting ? null : () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.activeBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          context.tr('rate_done_close'),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  else
                    _buildSubmitActions(context, isDark),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
