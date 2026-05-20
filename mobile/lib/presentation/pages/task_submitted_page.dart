import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/theme/colors.dart';
import '../../data/datasources/interesting_task_remote_data_source.dart';

class TaskSubmittedPage extends StatefulWidget {
  final int submissionId;
  final InterestingTaskRemoteDataSource ds;

  const TaskSubmittedPage({super.key, required this.submissionId, required this.ds});

  @override
  State<TaskSubmittedPage> createState() => _TaskSubmittedPageState();
}

class _TaskSubmittedPageState extends State<TaskSubmittedPage> {
  MySubmissionModel? _sub;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final sub = await widget.ds.mySubmissionDetail(widget.submissionId);
      if (mounted) {
        setState(() {
          _sub = sub;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _statusLabel(BuildContext context, String status) {
    final checked = status == 'checked';
    return checked ? context.tr('task_submit_status_checked') : context.tr('task_submit_status_pending');
  }

  Color _statusColor(String status) {
    return status == 'checked' ? AppColors.primaryGreen : const Color(0xFFFBBF24);
  }

  String _resultLine(BuildContext context) {
    final sub = _sub;
    if (sub != null && sub.resultVisible) {
      return context.tr('task_submit_result_points').replaceAll('{{score}}', '${sub.totalScore}');
    }
    return context.tr('task_submit_result_hidden');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? AppColors.scaffoldBackgroundDark : Colors.grey[50]!;
    final accent = AppColors.primaryPurple;
    final titleColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final bodyMuted = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final cardBg = isDark ? AppColors.cardDark : AppColors.cardWhite;
    final cardBorder = isDark ? Colors.white.withOpacity(0.08) : Colors.grey[200]!;
    final dividerColor = isDark ? Colors.white12 : Colors.black.withOpacity(0.06);

    final statusRaw = _sub?.status ?? 'pending';
    final statusText = _statusLabel(context, statusRaw);
    final statusColor = _statusColor(statusRaw);
    final idToShow = _sub?.id ?? widget.submissionId;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: Text(
          context.tr('task_submit_appbar'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        backgroundColor: accent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        top: false,
        child: _loading
            ? Center(child: CircularProgressIndicator(color: accent))
            : LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight - 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const _SuccessMark(),
                          const SizedBox(height: 24),
                          Text(
                            context.tr('task_submit_success_title'),
                            style: TextStyle(
                              color: titleColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 26,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            context.tr('task_submit_success_body'),
                            style: TextStyle(
                              color: bodyMuted,
                              fontSize: 15,
                              height: 1.55,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 28),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: cardBorder, width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(isDark ? 0.22 : 0.06),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                _StatusRow(
                                  icon: Icons.confirmation_number_outlined,
                                  iconColor: accent,
                                  label: context.tr('task_submit_id_label'),
                                  labelStyle: TextStyle(color: bodyMuted, fontSize: 13),
                                  value: '#$idToShow',
                                  valueStyle: TextStyle(
                                    color: titleColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Divider(color: dividerColor, height: 22),
                                _StatusRow(
                                  icon: Icons.hourglass_empty_rounded,
                                  iconColor: accent,
                                  label: context.tr('task_submit_status_label'),
                                  labelStyle: TextStyle(color: bodyMuted, fontSize: 13),
                                  value: statusText,
                                  valueStyle: TextStyle(
                                    color: statusColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Divider(color: dividerColor, height: 22),
                                _StatusRow(
                                  icon: _sub != null && _sub!.resultVisible
                                      ? Icons.insights_outlined
                                      : Icons.visibility_off_outlined,
                                  iconColor: accent,
                                  label: context.tr('task_submit_result_label'),
                                  labelStyle: TextStyle(color: bodyMuted, fontSize: 13),
                                  value: _resultLine(context),
                                  valueStyle: TextStyle(
                                    color: titleColor.withOpacity(0.85),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.home_outlined, color: Colors.white),
                              label: Text(
                                context.tr('task_submit_home'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accent,
                                elevation: 0,
                                shadowColor: accent.withOpacity(0.35),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _SuccessMark extends StatefulWidget {
  const _SuccessMark();

  @override
  State<_SuccessMark> createState() => _SuccessMarkState();
}

class _SuccessMarkState extends State<_SuccessMark> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final glow = AppColors.solidPurple;
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: glow.withOpacity(0.38),
              blurRadius: 28,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 50),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final TextStyle labelStyle;
  final String value;
  final TextStyle valueStyle;

  const _StatusRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.labelStyle,
    required this.value,
    required this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: labelStyle),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: valueStyle,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
