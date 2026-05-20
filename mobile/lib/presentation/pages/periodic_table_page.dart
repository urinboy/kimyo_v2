import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../injection_container.dart';
import '../bloc/element_bloc.dart';
import '../bloc/element_event.dart';
import '../bloc/element_state.dart';
import '../../core/theme/colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../domain/entities/element.dart';

class PeriodicTablePage extends StatefulWidget {
  const PeriodicTablePage({super.key});

  @override
  State<PeriodicTablePage> createState() => _PeriodicTablePageState();
}

class _PeriodicTablePageState extends State<PeriodicTablePage> {
  String selectedCategory = 'Barchasi';

  /// Backend `elements.type` qiymatlari bilan mos (`metal`, `halogen` va h.k.).
  final List<Map<String, dynamic>> categories = [
    {'id': 'Barchasi', 'key': 'periodic_all', 'color': Colors.grey},
    {'id': 'alkali', 'key': 'periodic_alkali', 'color': const Color(0xFFFF8A80)},
    {'id': 'alkaline', 'key': 'periodic_alkaline', 'color': const Color(0xFFFFD180)},
    {'id': 'transition', 'key': 'periodic_transition', 'color': const Color(0xFFFFF59D)},
    {'id': 'metal', 'key': 'periodic_metal', 'color': const Color(0xFFA5D6A7)},
    {'id': 'metalloid', 'key': 'periodic_metalloid', 'color': const Color(0xFF80DEEA)},
    {'id': 'nonmetal', 'key': 'periodic_nonmetal', 'color': const Color(0xFF90CAF9)},
    {'id': 'halogen', 'key': 'periodic_halogen', 'color': const Color(0xFFCE93D8)},
    {'id': 'noble', 'key': 'periodic_noble', 'color': const Color(0xFFF48FB1)},
    {'id': 'lanthanide', 'key': 'periodic_lanthanide', 'color': const Color(0xFFB388FF)},
    {'id': 'actinide', 'key': 'periodic_actinide', 'color': const Color(0xFFF8BBD0)},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (_) => sl<ElementBloc>()..add(LoadElementsEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            context.tr('periodic_interaktiv'),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // Category Filter
            Container(
              height: 50,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected = selectedCategory == cat['id'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(context.tr(cat['key'])),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          selectedCategory = cat['id'];
                        });
                      },
                      selectedColor: AppColors.primaryPurple.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.primaryPurple : (isDark ? Colors.white70 : Colors.black87),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: isSelected ? AppColors.primaryPurple : (isDark ? Colors.white24 : Colors.black12),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            BlocBuilder<ElementBloc, ElementState>(
              builder: (context, state) {
                if (state is! ElementLoaded || !state.fromCache) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.primaryPurple.withOpacity(0.35)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.cloud_off_rounded, size: 18, color: AppColors.primaryPurple.withOpacity(0.9)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            context.tr('elements_offline_banner'),
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.3,
                              color: isDark ? Colors.white70 : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Periodic Table Grid
            Expanded(
              child: BlocBuilder<ElementBloc, ElementState>(
                builder: (context, state) {
                  if (state is ElementLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ElementLoaded) {
                    final filteredElements = selectedCategory == 'Barchasi'
                        ? state.elements
                        : state.elements.where((e) => e.type == selectedCategory).toList();

                    return InteractiveViewer(
                      boundaryMargin: const EdgeInsets.all(20),
                      minScale: 0.1,
                      maxScale: 2.0,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _buildTableGrid(context, state.elements, filteredElements),
                      ),
                    );
                  } else if (state is ElementError) {
                    return Center(child: Text(state.message));
                  }
                  return const SizedBox();
                },
              ),
            ),

            // Legend
            _buildLegend(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTableGrid(BuildContext context, List<ElementEntity> allElements, List<ElementEntity> filteredElements) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: Column(
          children: [
            for (int row = 1; row <= 7; row++)
              Row(
                children: [
                  for (int col = 1; col <= 18; col++)
                    _buildElementCell(context, allElements, filteredElements, row, col),
                ],
              ),
            const SizedBox(height: 20),
            // Lanthanides & Actinides
            for (int row = 8; row <= 9; row++)
              Row(
                children: [
                  const SizedBox(width: 64 * 2), // Offset (cellSize * 2)
                  for (int col = 3; col <= 17; col++)
                    _buildElementCell(context, allElements, filteredElements, row, col),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildElementCell(
    BuildContext context, 
    List<ElementEntity> allElements, 
    List<ElementEntity> filteredElements, 
    int row, 
    int col
  ) {
    const double size = 60.0;
    final element = _findElementByPos(allElements, row, col);
    if (element == null) return const SizedBox(width: size, height: size);

    final isFiltered = filteredElements.contains(element);
    final color = _getCategoryColor(element.type);

    return GestureDetector(
      onTap: () => _showElementDialog(context, element),
      child: Opacity(
        opacity: isFiltered ? 1.0 : 0.2,
        child: Container(
          width: size,
          height: size,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color, width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${element.atomicNumber}',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
              Text(
                element.symbol,
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                  color: color.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ElementEntity? _findElementByPos(List<ElementEntity> elements, int row, int col) {
    try {
      return elements.firstWhere((e) => e.row == row && e.column == col);
    } catch (_) {
      return null;
    }
  }

  Color _getCategoryColor(String type) {
    for (final c in categories) {
      if (c['id'] == type) return c['color'] as Color;
    }
    return Colors.blueGrey;
  }

  void _showElementDialog(BuildContext context, ElementEntity element) {
    final name = element.getName(context.locale.languageCode);
    final categoryKey = 'periodic_${element.type}';
    final categoryName = context.tr(categoryKey);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('$name (${element.symbol})'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDialogRow(context, 'periodic_atom_num', '${element.atomicNumber}'),
            const SizedBox(height: 8),
            _buildDialogRow(context, 'periodic_mass', '${element.mass}'),
            const SizedBox(height: 8),
            _buildDialogRow(context, 'periodic_category', categoryName),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr('close')),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogRow(BuildContext context, String labelKey, String value) {
    return Row(
      children: [
        Text(
          '${context.tr(labelKey)}: ',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(value),
      ],
    );
  }

  Widget _buildLegend(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02),
        border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.1))),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: categories.where((c) => c['id'] != 'Barchasi').map((cat) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: (cat['color'] as Color).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: cat['color'] as Color),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                context.tr(cat['key']),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
