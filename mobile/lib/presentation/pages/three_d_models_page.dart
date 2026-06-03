import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/theme/colors.dart';
import '../../domain/entities/three_d_model.dart';
import '../bloc/three_d_model_bloc.dart';
import '../bloc/three_d_model_event.dart';
import '../bloc/three_d_model_state.dart';
import 'three_d_model_detail_page.dart';

class ThreeDModelsPage extends StatefulWidget {
  const ThreeDModelsPage({super.key});

  @override
  State<ThreeDModelsPage> createState() => _ThreeDModelsPageState();
}

class _ThreeDModelsPageState extends State<ThreeDModelsPage> {
  List<ThreeDModelEntity>? _cached;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    final lang = Localizations.localeOf(context).languageCode;
    context.read<ThreeDModelBloc>().add(LoadThreeDModelsEvent(langCode: lang));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.scaffoldBackgroundDark : AppColors.scaffoldBackground,
      appBar: AppBar(title: Text(context.tr('menu_3d_models'))),
      body: BlocBuilder<ThreeDModelBloc, ThreeDModelState>(
        builder: (context, state) {
          if (state is ThreeDModelsLoaded) _cached = state.models;

          if (state is ThreeDModelLoading && _cached == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ThreeDModelError && _cached == null) {
            return _ErrorView(message: state.message, onRetry: _load);
          }

          final models = _cached ?? [];

          if (models.isEmpty) {
            return Center(child: Text(context.tr('three_d_models_empty')));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: models.length,
            itemBuilder: (_, i) => _ModelCard(model: models[i]),
          );
        },
      ),
    );
  }
}

class _ModelCard extends StatelessWidget {
  final ThreeDModelEntity model;
  const _ModelCard({required this.model});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<ThreeDModelBloc>(),
            child: ThreeDModelDetailPage(modelId: model.id, modelName: model.name),
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: model.hasModel
                    ? Icon(
                        Icons.view_in_ar_rounded,
                        size: 56,
                        color: AppColors.primaryPurple.withOpacity(0.8),
                      )
                    : Icon(
                        Icons.science_rounded,
                        size: 56,
                        color: Colors.grey.withOpacity(0.5),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              model.name ?? model.slug,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            if (model.element != null) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  model.element!.symbol,
                  style: const TextStyle(
                    color: AppColors.primaryPurple,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded,
                size: 56, color: isDark ? Colors.white38 : Colors.black26),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(context.tr('retry')),
            ),
          ],
        ),
      ),
    );
  }
}
