import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../data/models/chemical_reaction_models.dart';
import '../../data/datasources/chemical_reactions_remote_data_source.dart';
import '../../injection_container.dart' as di;

/// Kimyo → formulalar → kimyoviy reaksiyalar. Ma'lumotlar API dan.
class ChemicalReactionsPage extends StatefulWidget {
  const ChemicalReactionsPage({super.key});

  @override
  State<ChemicalReactionsPage> createState() => _ChemicalReactionsPageState();
}

class _ChemicalReactionsPageState extends State<ChemicalReactionsPage> {
  final ChemicalReactionsRemoteDataSource _remote =
      di.sl<ChemicalReactionsRemoteDataSource>();

  List<ChemicalReactionTypeDto> _types = [];
  List<ChemicalReactionSymbolDto> _symbols = [];
  bool _loading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final bundle = await _remote.fetchAll();
      if (!mounted) return;
      setState(() {
        _types = bundle.types;
        _symbols = bundle.symbols;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  void _showDetail(ChemicalReactionTypeDto type) {
    final lang = context.locale.languageCode;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.72,
          minChildSize: 0.45,
          maxChildSize: 0.94,
          expand: false,
          builder: (_, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                      children: [
                        Text(
                          type.nameFor(lang),
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF424242),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (type.modalFormula != null &&
                            type.modalFormula!.isNotEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppColors.iconBackground,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              type.modalFormula!,
                              style: GoogleFonts.robotoMono(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryPurple,
                              ),
                            ),
                          )
                        else if (type.badgeFor(lang) != null &&
                            type.badgeFor(lang)!.isNotEmpty)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.iconBackground,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                type.badgeFor(lang)!,
                                style: GoogleFonts.robotoMono(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryPurple,
                                ),
                              ),
                            ),
                          ),
                        if ((type.descriptionFor(lang) ?? '').isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            type.descriptionFor(lang)!,
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              height: 1.45,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
                        if (type.examples.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          Text(
                            context.tr('chem_rx_examples'),
                            style: GoogleFonts.outfit(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF424242),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...type.examples.map(
                            (eq) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('• ',
                                      style: GoogleFonts.robotoMono(
                                          fontSize: 15,
                                          color: Colors.grey.shade700)),
                                  Expanded(
                                    child: Text(
                                      eq,
                                      style: GoogleFonts.robotoMono(
                                        fontSize: 14,
                                        height: 1.35,
                                        color: Colors.grey.shade900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primaryPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () => Navigator.pop(ctx),
                          child: Text(
                            context.tr('chem_rx_close'),
                            style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w700, fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = context.locale.languageCode;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.scaffoldBackgroundDark
          : AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          context.tr('menu_formulas_sub'),
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryPurple,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loading ? null : _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryPurple))
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_off_outlined,
                            size: 56, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          context.tr('chem_rx_error'),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            color: isDark ? Colors.white70 : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primaryPurple,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _load,
                          icon: const Icon(Icons.refresh),
                          label: Text(context.tr('chem_rx_retry')),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('chem_rx_section_types'),
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? Colors.white70
                              : const Color(0xFF616161),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._types.map((t) => _ReactionCard(
                            type: t,
                            isDark: isDark,
                            lang: lang,
                            onTap: () => _showDetail(t),
                          )),
                      const SizedBox(height: 24),
                      _SymbolsLegend(symbols: _symbols, isDark: isDark, lang: lang),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
    );
  }
}

class _ReactionCard extends StatelessWidget {
  const _ReactionCard({
    required this.type,
    required this.isDark,
    required this.lang,
    required this.onTap,
  });

  final ChemicalReactionTypeDto type;
  final bool isDark;
  final String lang;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        elevation: isDark ? 0 : 2,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isDark
                            ? type.iconTint.withValues(alpha: 0.2)
                            : type.cardTint,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child:
                          Icon(Icons.science_rounded, color: type.iconTint, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        type.nameFor(lang),
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded,
                        color: isDark ? Colors.white24 : Colors.black26),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black26 : Colors.grey.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    type.formula,
                    style: GoogleFonts.robotoMono(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.6,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SymbolsLegend extends StatelessWidget {
  const _SymbolsLegend({
    required this.symbols,
    required this.isDark,
    required this.lang,
  });

  final List<ChemicalReactionSymbolDto> symbols;
  final bool isDark;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final sorted = [...symbols]..sort((a, b) => a.order.compareTo(b.order));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF2C2C2E)
            : const Color(0xFFE5E5EA).withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('chem_rx_symbols_title'),
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white70 : const Color(0xFF616161),
            ),
          ),
          const SizedBox(height: 16),
          ...sorted.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 36,
                    child: Text(
                      s.symbol,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      s.descFor(lang),
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        color: isDark ? Colors.white60 : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
