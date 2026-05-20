import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/colors.dart';
import '../../domain/entities/lab_work.dart';
import '../bloc/lab_work_bloc.dart';
import '../bloc/lab_work_event.dart';
import '../bloc/lab_work_state.dart';
import 'lab_work_detail_page.dart';

class LabWorksPage extends StatefulWidget {
  const LabWorksPage({super.key});

  @override
  State<LabWorksPage> createState() => _LabWorksPageState();
}

class _LabWorksPageState extends State<LabWorksPage> {
  List<LabWorkEntity> _cachedLabs = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final langCode = context.locale.languageCode;
      context
          .read<LabWorkBloc>()
          .add(LoadLabWorksEvent(langCode: langCode));
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final langCode = context.locale.languageCode;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.scaffoldBackgroundDark : AppColors.scaffoldBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(isDark),
            Expanded(
              child: BlocConsumer<LabWorkBloc, LabWorkState>(
                listener: (context, state) {
                  if (state is LabWorksLoaded) {
                    _cachedLabs = state.labWorks;
                  }
                },
                builder: (context, state) {
                  if (state is LabWorkLoading && _cachedLabs.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primaryPurple),
                    );
                  }
                  if (state is LabWorkError && _cachedLabs.isEmpty) {
                    return _buildError(context, state.message);
                  }
                  if (_cachedLabs.isNotEmpty) {
                    return _buildList(context, _cachedLabs, isDark, langCode);
                  }
                  if (state is LabWorksLoaded && state.labWorks.isEmpty) {
                    return _buildEmpty(isDark);
                  }
                  return const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primaryPurple),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.science_outlined,
                    color: AppColors.primaryPurple, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                'Laboratoriya Ishlari',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Kimyo tajribalari va javoblari',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, List<LabWorkEntity> labs, bool isDark,
      String langCode) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: labs.length,
      separatorBuilder: (context, i) => const SizedBox(height: 10),
      itemBuilder: (context, i) => _LabCard(
        lab: labs[i],
        isDark: isDark,
        langCode: langCode,
      ),
    );
  }

  Widget _buildEmpty(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.science_outlined,
              size: 64,
              color: AppColors.primaryPurple.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            'Laboratoriyalar topilmadi',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white54 : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.read<LabWorkBloc>().add(
                    LoadLabWorksEvent(langCode: context.locale.languageCode),
                  ),
              icon: const Icon(Icons.refresh),
              label: const Text('Qayta urinish'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Lab Card ─────────────────────────────────────────────────────────────────

class _LabCard extends StatelessWidget {
  final LabWorkEntity lab;
  final bool isDark;
  final String langCode;

  const _LabCard(
      {required this.lab, required this.isDark, required this.langCode});

  @override
  Widget build(BuildContext context) {
    final title = lab.getTitle(langCode);
    final expCount = lab.experimentsCount ?? lab.experiments.length;
    final isActive = lab.status == 'active';

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.07)
                : Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () async {
                await Navigator.push<void>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<LabWorkBloc>(),
                      child: LabWorkDetailPage(
                          labId: lab.id, labNumber: lab.number),
                    ),
                  ),
                );
                if (!context.mounted) return;
                context.read<LabWorkBloc>().add(
                      LoadLabWorksEvent(langCode: langCode),
                    );
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color:
                            AppColors.primaryPurple.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${lab.number}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1A1A2E),
                            ),
                          ),
                          if (expCount > 0) ...[
                            const SizedBox(height: 3),
                            Text(
                              '$expCount ta tajriba',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.white38
                                    : Colors.black38,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.green.withValues(alpha: 0.12)
                            : Colors.grey.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isActive
                                  ? Colors.green.shade400
                                  : Colors.grey.shade400,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.chevron_right,
                              color: isDark
                                  ? Colors.white30
                                  : Colors.black26,
                              size: 18),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
