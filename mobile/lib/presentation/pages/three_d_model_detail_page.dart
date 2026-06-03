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
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: ModelViewer(
                          src: model.modelUrl!,
                          autoRotate: true,
                          cameraControls: true,
                          ar: true,
                          arScale: ArScale.auto,
                          backgroundColor: isDark
                              ? const Color(0xFF1A1A2E)
                              : const Color(0xFFF0F0F0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.view_in_ar_rounded,
                                size: 48, color: Colors.grey.withOpacity(0.5)),
                            const SizedBox(height: 8),
                            Text(
                              context.tr('three_d_model_no_file'),
                              style: TextStyle(color: Colors.grey.withOpacity(0.7)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (model.name != null) ...[
                    Text(
                      model.name!,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (model.element != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primaryPurple.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        '${model.element!.symbol} · Z=${model.element!.atomicNumber}',
                        style: const TextStyle(
                          color: AppColors.primaryPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (model.description != null && model.description!.isNotEmpty) ...[
                    Text(
                      model.description!,
                      style: Theme.of(context).textTheme.bodyMedium,
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
