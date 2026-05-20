import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/colors.dart';
import '../../core/localization/app_localizations.dart';
import '../bloc/element_bloc.dart';
import '../bloc/element_event.dart';
import '../bloc/element_state.dart';
import '../../domain/entities/element.dart';

import '../../injection_container.dart';

class ElementInfoPage extends StatefulWidget {
  const ElementInfoPage({super.key});

  @override
  State<ElementInfoPage> createState() => _ElementInfoPageState();
}

class _ElementInfoPageState extends State<ElementInfoPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (_) => sl<ElementBloc>()..add(LoadElementsEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.tr('menu_elements_sub')),
          backgroundColor: AppColors.primaryPurple,
        ),
        body: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: context.tr('search_hint'),
                    border: InputBorder.none,
                    icon: const Icon(Icons.search_rounded),
                  ),
                ),
              ),
            ),
            
            Expanded(
              child: BlocBuilder<ElementBloc, ElementState>(
                builder: (context, state) {
                  if (state is ElementLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ElementError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDark ? Colors.white70 : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    );
                  } else if (state is ElementLoaded) {
                    final filteredElements = state.elements.where((element) {
                      final name = element.getName(context.locale.languageCode).toLowerCase();
                      final symbol = element.symbol.toLowerCase();
                      return name.contains(_searchQuery) || symbol.contains(_searchQuery);
                    }).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (state.fromCache)
                          Material(
                            color: Colors.transparent,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryPurple.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.primaryPurple.withOpacity(0.35),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.cloud_off_rounded, size: 20, color: AppColors.primaryPurple.withOpacity(0.9)),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        context.tr('elements_offline_banner'),
                                        style: TextStyle(
                                          fontSize: 13,
                                          height: 1.35,
                                          color: isDark ? Colors.white.withOpacity(0.9) : AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        Expanded(
                          child: filteredElements.isEmpty
                              ? Center(child: Text(context.tr('no_results')))
                              : ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                  itemCount: filteredElements.length,
                                  itemBuilder: (context, index) {
                                    final element = filteredElements[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 16),
                                      child: _buildElementCard(
                                        context,
                                        element: element,
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildElementCard(
    BuildContext context, {
    required ElementEntity element,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final name = element.getName(context.locale.languageCode);
    final description = element.getDescription(context.locale.languageCode);
    final categoryKey = 'periodic_${element.type}';
    final categoryName = context.tr(categoryKey);
    final color = _getCategoryColor(element.type);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '${element.atomicNumber}',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$name (${element.symbol})',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      categoryName,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${element.mass}',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            '${context.tr('properties')}:',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildPropertyRow(context, context.tr('periodic_atom_num'), '${element.atomicNumber}', isDark),
          _buildPropertyRow(context, context.tr('periodic_symbol'), element.symbol, isDark),
          _buildPropertyRow(context, context.tr('periodic_mass'), '${element.mass}', isDark),
          _buildPropertyRow(context, context.tr('periodic_category'), categoryName, isDark),
        ],
      ),
    );
  }

  Widget _buildPropertyRow(BuildContext context, String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          Text(value, style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 14)),
        ],
      ),
    );
  }

  Color _getCategoryColor(String type) {
    switch (type) {
      case 'alkali': return const Color(0xFFFF8A80);
      case 'alkaline': return const Color(0xFFFFD180);
      case 'transition': return const Color(0xFFFFE57F);
      case 'post-transition': return const Color(0xFFCCFF90);
      case 'metalloid': return const Color(0xFFA7FFEB);
      case 'nonmetal': return const Color(0xFF80D8FF);
      case 'noble': return const Color(0xFF82B1FF);
      case 'lanthanide': return const Color(0xFFB388FF);
      case 'actinide': return const Color(0xFFF8BBD0);
      default: return Colors.grey;
    }
  }
}
