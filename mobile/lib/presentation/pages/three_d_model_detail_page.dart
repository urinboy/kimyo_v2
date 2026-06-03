import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/theme/colors.dart';
import '../bloc/three_d_model_bloc.dart';
import '../bloc/three_d_model_event.dart';
import '../bloc/three_d_model_state.dart';

class ThreeDModelDetailPage extends StatefulWidget {
  final int modelId;
  final String? modelName;

  const ThreeDModelDetailPage({
    super.key,
    required this.modelId,
    this.modelName,
  });

  @override
  State<ThreeDModelDetailPage> createState() => _ThreeDModelDetailPageState();
}

class _ThreeDModelDetailPageState extends State<ThreeDModelDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final lang = Localizations.localeOf(context).languageCode;
      context.read<ThreeDModelBloc>().add(
            LoadThreeDModelDetailEvent(widget.modelId, langCode: lang),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.scaffoldBackgroundDark : AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(widget.modelName ?? context.tr('three_d_model_detail')),
      ),
      body: BlocBuilder<ThreeDModelBloc, ThreeDModelState>(
        builder: (context, state) {
          if (state is ThreeDModelLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ThreeDModelError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(state.message, textAlign: TextAlign.center),
              ),
            );
          }

          if (state is ThreeDModelDetailLoaded) {
            final model = state.model;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (model.hasModel) ...[
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(isDark ? 0.15 : 0.4),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(23),
                            child: AspectRatio(
                              aspectRatio: 1.15,
                              child: ModelViewer(
                                src: model.modelUrl!,
                                autoRotate: true,
                                cameraControls: true,
                                ar: true,
                                arScale: ArScale.auto,
                                backgroundColor: isDark
                                    ? const Color(0xFF1E1E2F)
                                    : const Color(0xFFF3F4F6),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: (isDark ? Colors.black : Colors.white).withOpacity(0.75),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.view_in_ar_rounded,
                                  size: 16,
                                  color: AppColors.primaryPurple,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '3D Interactive',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.gesture_rounded,
                            size: 14,
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Aylantirish uchun suring · Kattalashtirish uchun chimdilang",
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ] else ...[
                    Container(
                      height: 240,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.view_in_ar_rounded,
                                size: 56, color: Colors.grey.withOpacity(0.5)),
                            const SizedBox(height: 12),
                            Text(
                              context.tr('three_d_model_no_file'),
                              style: TextStyle(
                                color: Colors.grey.withOpacity(0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (model.name != null) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            model.name!,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                          ),
                        ),
                        if (model.element != null) ...[
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primaryPurple.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.primaryPurple.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              '${model.element!.symbol} (Z=${model.element!.atomicNumber})',
                              style: const TextStyle(
                                color: AppColors.primaryPurple,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (model.description != null && model.description!.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(isDark ? 0.1 : 0.6),
                        ),
                        boxShadow: [
                          if (!isDark)
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                size: 18,
                                color: AppColors.primaryPurple.withOpacity(0.8),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Kimyoviy Tavsif",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppColors.primaryPurple.withOpacity(0.9),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 20, thickness: 0.8),
                          Text(
                            model.description!,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.6,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
