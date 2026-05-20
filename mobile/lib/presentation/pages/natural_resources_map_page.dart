import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/theme/colors.dart';

/// Tabiiy zaxiralar xaritasi — [PhotoView] orqali to‘liq ekranda zoom/pan.
class NaturalResourcesMapPage extends StatefulWidget {
  static const String assetPath = 'assets/images/tzx.jpg';

  const NaturalResourcesMapPage({super.key});

  @override
  State<NaturalResourcesMapPage> createState() => _NaturalResourcesMapPageState();
}

class _NaturalResourcesMapPageState extends State<NaturalResourcesMapPage> {
  late final PhotoViewController _photoController;
  bool _hintVisible = true;

  static const double _zoomStep = 1.35;

  @override
  void initState() {
    super.initState();
    _photoController = PhotoViewController();
  }

  @override
  void dispose() {
    _photoController.dispose();
    super.dispose();
  }

  void _fitToScreen() {
    _photoController.reset();
  }

  void _zoomBy(double factor) {
    final current = _photoController.scale;
    if (current == null) return;
    _photoController.scale = current * factor;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mapBg = isDark ? AppColors.cardDark : Colors.white;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.scaffoldBackgroundDark : AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          context.tr('menu_natural_resources_map'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _fitToScreen,
            icon: const Icon(Icons.fit_screen_rounded),
            tooltip: context.tr('natural_resources_map_fit_tooltip'),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_hintVisible)
            Material(
              color: isDark ? AppColors.cardDark : AppColors.iconBackground,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 4, 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.touch_app_rounded,
                      size: 20,
                      color: AppColors.primaryPurple.withValues(alpha: 0.9),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        context.tr('natural_resources_map_pinch_hint'),
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                          height: 1.35,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _hintVisible = false),
                      icon: Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: isDark ? Colors.white54 : AppColors.textSecondary,
                      ),
                      tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
              child: Material(
                color: mapBg,
                borderRadius: BorderRadius.circular(16),
                elevation: isDark ? 0 : 1,
                shadowColor: Colors.black.withValues(alpha: 0.08),
                clipBehavior: Clip.antiAlias,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isDark ? Colors.white12 : AppColors.iconBackground,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      PhotoView(
                        controller: _photoController,
                        imageProvider: const AssetImage(NaturalResourcesMapPage.assetPath),
                        initialScale: PhotoViewComputedScale.contained,
                        minScale: PhotoViewComputedScale.contained * 0.85,
                        maxScale: PhotoViewComputedScale.contained * 8,
                        basePosition: Alignment.center,
                        enableRotation: false,
                        filterQuality: FilterQuality.high,
                        backgroundDecoration: BoxDecoration(color: mapBg),
                        loadingBuilder: (context, event) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              context.tr('natural_resources_map_load_error'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isDark ? Colors.white70 : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 10,
                        bottom: 10,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _MapZoomControl(
                              isDark: isDark,
                              icon: Icons.add_rounded,
                              tooltip: context.tr('natural_resources_map_zoom_in'),
                              onPressed: () => _zoomBy(_zoomStep),
                            ),
                            const SizedBox(height: 6),
                            _MapZoomControl(
                              isDark: isDark,
                              icon: Icons.remove_rounded,
                              tooltip: context.tr('natural_resources_map_zoom_out'),
                              onPressed: () => _zoomBy(1 / _zoomStep),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapZoomControl extends StatelessWidget {
  const _MapZoomControl({
    required this.isDark,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final bool isDark;
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
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
      ),
    );
  }
}
