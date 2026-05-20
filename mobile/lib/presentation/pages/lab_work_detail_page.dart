import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/colors.dart';
import '../../domain/entities/lab_work.dart';
import '../bloc/lab_work_bloc.dart';
import '../bloc/lab_work_event.dart';
import '../bloc/lab_work_state.dart';

class LabWorkDetailPage extends StatefulWidget {
  final int labId;
  final int labNumber;

  const LabWorkDetailPage({
    super.key,
    required this.labId,
    required this.labNumber,
  });

  @override
  State<LabWorkDetailPage> createState() => _LabWorkDetailPageState();
}

class _LabWorkDetailPageState extends State<LabWorkDetailPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _detailRequested = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 0, vsync: this);
  }

  void _loadDetail() {
    final langCode = context.locale.languageCode;
    context.read<LabWorkBloc>().add(
          LoadLabWorkDetailEvent(widget.labId, langCode: langCode),
        );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_detailRequested) return;
    _detailRequested = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadDetail();
    });
  }

  void _rebuildTabController(int length) {
    if (_tabController.length == length) return;
    final oldIndex = _tabController.index;
    _tabController.dispose();
    _tabController = TabController(
      length: length,
      initialIndex: length > 0 ? oldIndex.clamp(0, length - 1) : 0,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final langCode = context.locale.languageCode;

    return BlocConsumer<LabWorkBloc, LabWorkState>(
      listener: (context, state) {
        if (state is LabWorkDetailLoaded &&
            state.labWork.id == widget.labId) {
          _rebuildTabController(state.labWork.experiments.length);
        }
      },
      builder: (context, state) {
        if (state is LabWorkDetailLoaded &&
            state.labWork.id == widget.labId) {
          final lab = state.labWork;
          final title = lab.getTitle(langCode);
          final desc = lab.getDescription(langCode);

          return Scaffold(
            backgroundColor: isDark
                ? AppColors.scaffoldBackgroundDark
                : AppColors.scaffoldBackground,
            body: NestedScrollView(
              headerSliverBuilder: (context, _) => [
                SliverAppBar(
                  expandedHeight: 170,
                  floating: false,
                  pinned: true,
                  backgroundColor:
                      isDark ? const Color(0xFF1E1E2E) : Colors.white,
                  foregroundColor:
                      isDark ? Colors.white : const Color(0xFF1A1A2E),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding:
                        const EdgeInsets.fromLTRB(56, 0, 16, 14),
                    title: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurple
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${lab.number}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryPurple,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Laboratoriya',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? [
                                  const Color(0xFF2D1B69),
                                  const Color(0xFF1A1A2E)
                                ]
                              : [
                                  const Color(0xFFF3E8FF),
                                  Colors.white
                                ],
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(20, 0, 20, 52),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryPurple
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${lab.number}-Laboratoriya ishi',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryPurple,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                title,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF1A1A2E),
                                  letterSpacing: -0.3,
                                  height: 1.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (desc != null && desc.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  desc,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.white54
                                        : Colors.black45,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  bottom: lab.experiments.isEmpty
                      ? null
                      : PreferredSize(
                          preferredSize: const Size.fromHeight(44),
                          child: Container(
                            color: isDark
                                ? const Color(0xFF1E1E2E)
                                : Colors.white,
                            child: TabBar(
                              controller: _tabController,
                              isScrollable: true,
                              tabAlignment: TabAlignment.start,
                              indicatorColor: AppColors.primaryPurple,
                              indicatorWeight: 3,
                              indicatorSize: TabBarIndicatorSize.label,
                              dividerColor: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.black.withValues(alpha: 0.06),
                              labelColor: AppColors.primaryPurple,
                              unselectedLabelColor: isDark
                                  ? Colors.white38
                                  : Colors.black38,
                              labelStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                              unselectedLabelStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              tabs: lab.experiments
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                final label =
                                    entry.value.getTitle(langCode);
                                final display = label.length > 24
                                    ? '${label.substring(0, 24)}…'
                                    : label;
                                return Tab(
                                  height: 40,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 18,
                                        height: 18,
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryPurple
                                              .withValues(alpha: 0.12),
                                          shape: BoxShape.circle,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          '${entry.key + 1}',
                                          style: const TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.primaryPurple,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(display),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                ),
              ],
              body: lab.experiments.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.science_outlined,
                            size: 56,
                            color: isDark
                                ? Colors.white24
                                : Colors.black12,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tajribalar topilmadi',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white38
                                  : Colors.black38,
                            ),
                          ),
                        ],
                      ),
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: lab.experiments
                          .map((exp) => _ExperimentView(
                                exp: exp,
                                isDark: isDark,
                                langCode: langCode,
                              ))
                          .toList(),
                    ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: isDark
              ? AppColors.scaffoldBackgroundDark
              : AppColors.scaffoldBackground,
          appBar: AppBar(
            title: Text('${widget.labNumber}-Laboratoriya ishi'),
            backgroundColor:
                isDark ? const Color(0xFF1E1E2E) : Colors.white,
            foregroundColor:
                isDark ? Colors.white : const Color(0xFF1A1A2E),
            elevation: 0,
          ),
          body: state is LabWorkError
              ? _buildError(context, state.message)
              : const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.primaryPurple),
                ),
        );
      },
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadDetail,
            icon: const Icon(Icons.refresh),
            label: const Text('Qayta urinish'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPurple),
          ),
        ],
      ),
    );
  }
}

// ─── Experiment View ──────────────────────────────────────────────────────────

class _ExperimentView extends StatelessWidget {
  final LabExperimentEntity exp;
  final bool isDark;
  final String langCode;

  const _ExperimentView({
    required this.exp,
    required this.isDark,
    required this.langCode,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Reactions
        if (exp.reactions.isNotEmpty) ...[
          _SectionHeader(title: 'Kimyoviy reaksiyalar', icon: Icons.science, isDark: isDark),
          const SizedBox(height: 8),
          ...exp.reactions.map((r) => _ReactionCard(reaction: r, isDark: isDark)),
          const SizedBox(height: 16),
        ],

        // Observations
        if (exp.observations.isNotEmpty) ...[
          _SectionHeader(title: 'Kuzatiladigan holatlar', icon: Icons.visibility_outlined, isDark: isDark),
          const SizedBox(height: 8),
          _GlassContainer(
            isDark: isDark,
            child: Column(
              children: exp.observations.asMap().entries.map((entry) {
                final text = entry.value.getText(langCode);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 22, height: 22,
                        decoration: BoxDecoration(
                          color: AppColors.primaryPurple.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${entry.key + 1}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryPurple,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          text,
                          style: TextStyle(
                            fontSize: 13.5,
                            color: isDark ? Colors.white.withValues(alpha: 0.87) : const Color(0xFF1A1A2E),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Products
        if (exp.products.isNotEmpty) ...[
          _SectionHeader(title: 'Hosil bo\'lgan moddalar', icon: Icons.biotech_outlined, isDark: isDark),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: exp.products.map((p) => _ProductChip(product: p, isDark: isDark, langCode: langCode)).toList(),
          ),
          const SizedBox(height: 16),
        ],

        // Scientific explanation
        if (exp.getExplanation(langCode)?.isNotEmpty == true) ...[
          _SectionHeader(title: 'Ilmiy izoh', icon: Icons.lightbulb_outline, isDark: isDark),
          const SizedBox(height: 8),
          _GlassContainer(
            isDark: isDark,
            accent: const Color(0xFFFFF8E1),
            accentDark: const Color(0xFF2D2A1A),
            child: Text(
              exp.getExplanation(langCode)!,
              style: TextStyle(
                fontSize: 13.5,
                color: isDark ? Colors.white.withValues(alpha: 0.87) : const Color(0xFF3E3100),
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

// ─── Reaction Card ────────────────────────────────────────────────────────────

class _ReactionCard extends StatelessWidget {
  final LabReactionEntity reaction;
  final bool isDark;

  const _ReactionCard({required this.reaction, required this.isDark});

  String get _typeLabel {
    switch (reaction.type) {
      case 'molecular':   return 'Molekulyar';
      case 'full_ionic':  return "To'la ionli";
      case 'short_ionic': return 'Qisqa ionli';
      default:            return reaction.type;
    }
  }

  Color get _typeBg {
    switch (reaction.type) {
      case 'molecular':   return const Color(0xFFEDE7F6);
      case 'full_ionic':  return const Color(0xFFE3F2FD);
      case 'short_ionic': return const Color(0xFFE8F5E9);
      default:            return const Color(0xFFF5F5F5);
    }
  }

  Color get _typeColor {
    switch (reaction.type) {
      case 'molecular':   return const Color(0xFF7B1FA2);
      case 'full_ionic':  return const Color(0xFF1565C0);
      case 'short_ionic': return const Color(0xFF2E7D32);
      default:            return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.05)),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: _typeColor.withValues(alpha: isDark ? 0.7 : 1.0),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark
                            ? _typeColor.withValues(alpha: 0.15)
                            : _typeBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _typeLabel,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? _typeColor.withValues(alpha: 0.9)
                              : _typeColor,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      reaction.formula,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace',
                        color:
                            isDark ? Colors.white : const Color(0xFF1A1A2E),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Product Chip ─────────────────────────────────────────────────────────────

class _ProductChip extends StatelessWidget {
  final LabProductEntity product;
  final bool isDark;
  final String langCode;

  const _ProductChip({required this.product, required this.isDark, required this.langCode});

  @override
  Widget build(BuildContext context) {
    final name = product.getName(langCode);
    final sym = product.stateSymbol;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.07) : const Color(0xFFF3E5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white10 : AppColors.primaryPurple.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                product.chemicalFormula,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.primaryPurple,
                ),
              ),
              if (sym.isNotEmpty)
                Text(sym, style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.primaryPurple,
                  fontWeight: FontWeight.w900,
                )),
            ],
          ),
          if (name.isNotEmpty && name != product.chemicalFormula) ...[
            const SizedBox(height: 2),
            Text(
              name,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isDark;

  const _SectionHeader({required this.title, required this.icon, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primaryPurple.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: AppColors.primaryPurple),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white70 : const Color(0xFF333355),
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _GlassContainer extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final Color? accent;
  final Color? accentDark;

  const _GlassContainer({
    required this.child,
    required this.isDark,
    this.accent,
    this.accentDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? (accentDark ?? Colors.white.withValues(alpha: 0.05))
            : (accent ?? Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: child,
    );
  }
}
