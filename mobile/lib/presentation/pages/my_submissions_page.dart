import 'package:flutter/material.dart';
import '../../injection_container.dart';
import '../../core/network/dio_client.dart';
import '../../core/theme/colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../data/datasources/interesting_task_remote_data_source.dart';
import 'interesting_task_submission_detail_page.dart';

class MySubmissionsPage extends StatefulWidget {
  const MySubmissionsPage({super.key});

  @override
  State<MySubmissionsPage> createState() => _MySubmissionsPageState();
}

class _MySubmissionsPageState extends State<MySubmissionsPage> {
  late final InterestingTaskRemoteDataSource _ds;
  List<MySubmissionModel>? _subs;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _ds = InterestingTaskRemoteDataSourceImpl(dio: sl<DioClient>().dio);
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final subs = await _ds.mySubmissions();
      if (mounted) {
        setState(() {
          _subs = subs;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = context.locale.languageCode;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.scaffoldBackgroundDark : AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryPurple,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          context.tr('my_submissions_title'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryPurple,
              ),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 12),
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _load,
                          child: Text(lang == 'uz' ? 'Qayta urinish' : (lang == 'ru' ? 'Повторить' : 'Retry')),
                        ),
                      ],
                    ),
                  ),
                )
              : _subs == null || _subs!.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 64,
                            color: Theme.of(context).hintColor,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            context.tr('my_submissions_empty'),
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      color: AppColors.primaryPurple,
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _subs!.length,
                        itemBuilder: (_, i) => _SubmissionCard(
                          sub: _subs![i],
                          ds: _ds,
                          isDark: isDark,
                          lang: lang,
                        ),
                      ),
                    ),
    );
  }
}

class _SubmissionCard extends StatelessWidget {
  final MySubmissionModel sub;
  final InterestingTaskRemoteDataSource ds;
  final bool isDark;
  final String lang;

  const _SubmissionCard({
    required this.sub,
    required this.ds,
    required this.isDark,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final isChecked = sub.status == 'checked';
    final canView = isChecked && sub.resultVisible;

    final title = sub.task?['title'] as String? ??
        (lang == 'uz' ? 'Topshiriq' : (lang == 'ru' ? 'Задание' : 'Task'));

    final secondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final primary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;

    Future<void> openDetail() async {
      MySubmissionModel toShow = sub;
      if (sub.answers == null) {
        try {
          toShow = await ds.mySubmissionDetail(sub.id);
        } catch (_) {}
      }
      if (!context.mounted) return;
      await Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (_) => InterestingTaskSubmissionDetailPage(sub: toShow),
        ),
      );
    }

    final pointsLine = context.tr('task_submit_result_points').replaceAll('{{score}}', '${sub.totalScore}');

    Widget trailing;
    if (!isChecked) {
      trailing = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.hourglass_top_rounded, size: 18, color: Colors.amber.shade800),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              context.tr('task_submit_status_pending'),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.amber.shade900,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      );
    } else if (!sub.resultVisible) {
      trailing = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_outline, size: 18, color: AppColors.primaryPurple),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              lang == 'uz'
                  ? 'Natija kutilmoqda'
                  : (lang == 'ru' ? 'Ожидание результата' : 'Awaiting result'),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: AppColors.primaryPurple,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      );
    } else {
      trailing = ElevatedButton(
        onPressed: openDetail,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPurple,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          lang == 'uz' ? 'Natija' : (lang == 'ru' ? 'Результат' : 'Result'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.26)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFFAB47BC).withValues(alpha: 0.22)
                    : const Color(0xFFF3E5F5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lightbulb_outline_rounded,
                color: Color(0xFFAB47BC),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      height: 1.25,
                      color: primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 14, color: secondary),
                      const SizedBox(width: 6),
                      Text(
                        _formatDate(sub.createdAt),
                        style: TextStyle(fontSize: 13, color: secondary),
                      ),
                      if (isChecked) ...[
                        const SizedBox(width: 10),
                        Icon(Icons.star_rounded, size: 16, color: Colors.amber.shade700),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            pointsLine,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.amber.shade800,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (isChecked && !canView) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple.withValues(alpha: isDark ? 0.18 : 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primaryPurple.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lock_outline, size: 18, color: AppColors.primaryPurple),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              context.tr('task_submit_result_hidden'),
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.35,
                                color: isDark
                                    ? const Color(0xFFB39DDB)
                                    : AppColors.primaryPurple,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 132),
              child: Align(
                alignment: Alignment.centerRight,
                child: trailing,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
  }
}
