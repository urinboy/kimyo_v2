import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../injection_container.dart';
import '../bloc/mine_bloc.dart';
import '../bloc/mine_event.dart';
import '../bloc/mine_state.dart';
import '../../core/theme/colors.dart';
import '../widgets/glass_card.dart';
import '../../domain/entities/mine.dart';

class MinesPage extends StatelessWidget {
  const MinesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MineBloc>()..add(LoadMinesEvent()),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text(
            'INTERAKTIV XARITA',
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: BlocBuilder<MineBloc, MineState>(
          builder: (context, state) {
            if (state is MineLoading) {
              return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
            } else if (state is MineLoaded) {
              return _buildMap(context, state.mines);
            } else if (state is MineError) {
              return Center(child: Text('Xatolik: ${state.message}'));
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildMap(BuildContext context, List<MineEntity> mines) {
    return FlutterMap(
      options: const MapOptions(
        initialCenter: LatLng(42.46, 59.61), // Nukus
        initialZoom: 7.0,
        minZoom: 5.0,
        maxZoom: 15.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
        ),
        MarkerLayer(
          markers: mines.map((mine) => Marker(
            point: LatLng(mine.latitude, mine.longitude),
            width: 60,
            height: 60,
            child: GestureDetector(
              onTap: () => _showMineDetails(context, mine),
              child: _buildCustomMarker(mine),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildCustomMarker(MineEntity mine) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.solidPurple.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.solidPurple.withOpacity(0.5), width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.solidPurple.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.solidPurple.withOpacity(0.8),
            child: Text(
              mine.elements.isNotEmpty ? mine.elements.first.symbol : '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const Icon(Icons.arrow_drop_down, color: AppColors.solidPurple, size: 12),
      ],
    );
  }

  void _showMineDetails(BuildContext context, MineEntity mine) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassCard(
        borderRadius: 32,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mine.getName('uz'),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${mine.latitude}, ${mine.longitude}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.solidPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.map_outlined, color: AppColors.solidPurple),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'MAVJUD ELEMENTLAR',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white54,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: mine.elements.map((el) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      el.symbol,
                      style: const TextStyle(
                        color: AppColors.solidPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      el.getName('uz'),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              )).toList(),
            ),
            const SizedBox(height: 24),
            Text(
              mine.getDescription('uz') ?? 'Ushbu kon haqida qo\'shimcha ma\'lumot mavjud emas.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.solidPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('YOPISH', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
