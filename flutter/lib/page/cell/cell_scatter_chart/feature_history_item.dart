import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';

class FeatureHistoryItem {
  final List<String> features;
  final String plotType;
  final String modId;
  final String group;
  final Spatial? spatial;
  late Color color;

  FeatureHistoryItem({
    required this.features,
    required this.plotType,
    required this.modId,
    required this.group,
    required this.spatial,
    required this.color,
  }) {
    features.sort();
  }

  int get featuresHashCode => this.features.join(',').hashCode;

  @override
  String toString() {
    return 'FeatureHistoryItem{features: $features}';
  }
}
