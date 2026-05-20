import 'package:flutter/material.dart';
import '../../domain/entities/element.dart';
import '../../core/theme/colors.dart';
import '../widgets/glass_card.dart';

class ElementDetailsPage extends StatelessWidget {
  final ElementEntity element;

  const ElementDetailsPage({super.key, required this.element});

  @override
  Widget build(BuildContext context) {
    final color = element.colorHex != null 
        ? Color(int.parse(element.colorHex!.replaceFirst('#', '0xFF')))
        : AppColors.solidPurple;

    return Scaffold(
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.15),
              ),
            ),
          ),
          
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Text(
                          element.symbol,
                          style: TextStyle(
                            fontSize: 80,
                            fontWeight: FontWeight.bold,
                            color: color,
                            shadows: [
                              Shadow(
                                color: color.withOpacity(0.5),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          element.getName('uz'),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoGrid(context),
                      const SizedBox(height: 24),
                      Text(
                        'Tavsif',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GlassCard(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          element.translations.firstWhere((t) => t.languageCode == 'uz').description ?? 'Ma\'lumotlar mavjud emas...',
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 2.5,
      children: [
        _buildInfoItem('Atom Raqami', '${element.atomicNumber}', Icons.numbers_rounded),
        _buildInfoItem('Atom Massasi', '${element.mass}', Icons.monitor_weight_outlined),
        _buildInfoItem('Turi', element.type.toUpperCase(), Icons.category_outlined),
        _buildInfoItem('Holati', 'Noma\'lum', Icons.science_outlined),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.white38),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 10, color: Colors.white38),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
