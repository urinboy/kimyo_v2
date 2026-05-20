import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../domain/entities/element.dart';
import '../widgets/glass_card.dart';

class ElementTile extends StatelessWidget {
  final ElementEntity element;
  final VoidCallback onTap;

  const ElementTile({
    super.key,
    required this.element,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = element.colorHex != null 
        ? Color(int.parse(element.colorHex!.replaceFirst('#', '0xFF')))
        : AppColors.solidPurple;

    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        borderRadius: 12,
        padding: const EdgeInsets.all(4),
        borderOpacity: 0.15,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${element.atomicNumber}',
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.white54,
                  ),
                ),
                Text(
                  element.mass.toStringAsFixed(2),
                  style: const TextStyle(
                    fontSize: 6,
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
            Center(
              child: Text(
                element.symbol,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: color,
                  shadows: [
                    Shadow(
                      color: color.withOpacity(0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                element.getName('uz'),
                style: const TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                  overflow: TextOverflow.ellipsis,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
