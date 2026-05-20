import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/colors.dart';
import '../widgets/geography_topic_complete_bar.dart';

/// Markaziy Osiyo / O'zbekiston atrofida siyosiy xarita.
class GeographyPoliticalMapPage extends StatelessWidget {
  const GeographyPoliticalMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('geo_map')),
        backgroundColor: AppColors.primaryCyan,
        foregroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(41.8, 64.0),
                initialZoom: 5.2,
                minZoom: 3.5,
                maxZoom: 12,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: GeographyTopicCompleteBar(
              topicId: 'geo_political_map',
              titleTrKey: 'geo_map',
            ),
          ),
        ],
      ),
    );
  }
}
