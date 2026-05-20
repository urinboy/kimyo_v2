import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/theme/colors.dart';
import '../../data/local/regional_minerals_data.dart';
import 'regional_mineral_detail_page.dart';

/// Qoraqalpog'iston minerallari: Google Maps + ro'yxat (oldingi `old_codes/minerals` MainPage mantig'i).
class RegionalMineralsPage extends StatefulWidget {
  const RegionalMineralsPage({super.key});

  @override
  State<RegionalMineralsPage> createState() => _RegionalMineralsPageState();
}

class _RegionalMineralsPageState extends State<RegionalMineralsPage> {
  late String _selectedName;
  GoogleMapController? _mapController;

  static const LatLng _initialTarget = LatLng(43.65, 59.2);
  static const double _initialZoom = 6.6;
  static const double _mapMinZoom = 5;
  static const double _mapMaxZoom = 18;
  static const double _singlePointZoom = 11;
  static const double _boundsPaddingPx = 56;

  @override
  void initState() {
    super.initState();
    _selectedName = regionalMinerals.first.name;
  }

  void _scheduleFitToSelection() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _fitMapToSelectedMineral();
    });
  }

  Future<void> _fitMapToSelectedMineral() async {
    final ctrl = _mapController;
    if (ctrl == null || !mounted) return;

    RegionalMineral? mineral;
    for (final m in regionalMinerals) {
      if (m.name == _selectedName) {
        mineral = m;
        break;
      }
    }
    if (mineral == null || mineral.locations.isEmpty) return;

    final pts = mineral.locations
        .map((l) => LatLng(l['latitude']!, l['longitude']!))
        .toList();

    if (pts.length == 1) {
      await ctrl.animateCamera(
        CameraUpdate.newLatLngZoom(pts.first, _singlePointZoom),
      );
      return;
    }

    var minLat = pts.first.latitude;
    var maxLat = pts.first.latitude;
    var minLng = pts.first.longitude;
    var maxLng = pts.first.longitude;
    for (final p in pts.skip(1)) {
      minLat = math.min(minLat, p.latitude);
      maxLat = math.max(maxLat, p.latitude);
      minLng = math.min(minLng, p.longitude);
      maxLng = math.max(maxLng, p.longitude);
    }
    const eps = 0.002;
    if ((maxLat - minLat).abs() < 1e-6) {
      minLat -= eps;
      maxLat += eps;
    }
    if ((maxLng - minLng).abs() < 1e-6) {
      minLng -= eps;
      maxLng += eps;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    try {
      await ctrl.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, _boundsPaddingPx),
      );
    } catch (_) {
      await ctrl.animateCamera(
        CameraUpdate.newLatLngZoom(pts.first, _singlePointZoom),
      );
    }
  }

  Future<void> _zoomBy(double delta) async {
    final ctrl = _mapController;
    if (ctrl == null) return;
    final z = await ctrl.getZoomLevel();
    final next = (z + delta).clamp(_mapMinZoom, _mapMaxZoom);
    if (next == z) return;
    await ctrl.animateCamera(CameraUpdate.zoomTo(next));
  }

  Set<Marker> _googleMarkers(BuildContext context) {
    final quantityLabel = context.tr('regional_minerals_quantity_label');
    final markers = <Marker>{};
    for (final m in regionalMinerals) {
      if (m.name != _selectedName) continue;
      for (final loc in m.locations) {
        final lat = loc['latitude']!;
        final lng = loc['longitude']!;
        final id = '${m.name}_${lat}_$lng';
        markers.add(
          Marker(
            markerId: MarkerId(id),
            position: LatLng(lat, lng),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
            infoWindow: InfoWindow(
              title: m.name,
              snippet: '$quantityLabel: ${m.quantity}',
            ),
          ),
        );
      }
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final markers = _googleMarkers(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('menu_regional_minerals'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor:
          isDark ? AppColors.scaffoldBackgroundDark : AppColors.scaffoldBackground,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final mapH = constraints.maxHeight * 0.4;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Material(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  elevation: isDark ? 0 : 1,
                  shadowColor: Colors.black.withValues(alpha: 0.08),
                  child: Container(
                    height: mapH.clamp(180.0, 320.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? Colors.white12 : AppColors.iconBackground,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        GoogleMap(
                          initialCameraPosition: const CameraPosition(
                            target: _initialTarget,
                            zoom: _initialZoom,
                          ),
                          mapType: MapType.normal,
                          markers: markers,
                          minMaxZoomPreference: const MinMaxZoomPreference(
                            _mapMinZoom,
                            _mapMaxZoom,
                          ),
                          zoomControlsEnabled: false,
                          myLocationButtonEnabled: false,
                          compassEnabled: true,
                          onMapCreated: (c) {
                            _mapController = c;
                            _scheduleFitToSelection();
                          },
                        ),
                        Positioned(
                          left: 8,
                          bottom: 8,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _MapZoomControl(
                                isDark: isDark,
                                icon: Icons.add_rounded,
                                onPressed: () => _zoomBy(1),
                              ),
                              const SizedBox(height: 6),
                              _MapZoomControl(
                                isDark: isDark,
                                icon: Icons.remove_rounded,
                                onPressed: () => _zoomBy(-1),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    context.tr('regional_minerals_map_hint'),
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: regionalMinerals.length,
                  itemBuilder: (context, index) {
                    final mineral = regionalMinerals[index];
                    final selected = mineral.name == _selectedName;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Material(
                        color: isDark ? AppColors.cardDark : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        elevation: isDark ? 0 : 1,
                        shadowColor: Colors.black.withValues(alpha: 0.06),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  RegionalMineralDetailPage(mineral: mineral),
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: selected
                                    ? AppColors.primaryPurple.withValues(alpha: 0.55)
                                    : (isDark ? Colors.white10 : Colors.transparent),
                                width: selected ? 2 : 1,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: SizedBox(
                                    width: 56,
                                    height: 56,
                                    child: Image.asset(
                                      mineral.modelPath,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        mineral.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: isDark ? Colors.white : AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${context.tr('regional_minerals_quantity_label')}: ${mineral.quantity}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isDark ? Colors.white60 : AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() => _selectedName = mineral.name);
                                    _scheduleFitToSelection();
                                  },
                                  icon: Icon(
                                    selected ? Icons.visibility : Icons.visibility_off,
                                    color: selected
                                        ? AppColors.primaryPurple
                                        : (isDark ? Colors.white38 : AppColors.textSecondary),
                                  ),
                                  tooltip: selected
                                      ? context.tr(
                                          'regional_minerals_hide_on_map',
                                        )
                                      : context.tr('regional_minerals_show_on_map'),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: isDark ? Colors.white24 : AppColors.textSecondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MapZoomControl extends StatelessWidget {
  const _MapZoomControl({
    required this.isDark,
    required this.icon,
    required this.onPressed,
  });

  final bool isDark;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: (isDark ? const Color(0xFF2C2C2C) : Colors.white).withValues(alpha: 0.94),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 22, color: AppColors.primaryPurple),
        ),
      ),
    );
  }
}
