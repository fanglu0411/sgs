import 'package:flutter_smart_genome/widget/track/base/track_style.dart';
import 'package:flutter_smart_genome/widget/track/painter/feature_style_config.dart';

mixin FeaturedStyleMixin on TrackStyle {
  List get featureList {
    Map _map = this['featureStyles'];
    return _map.keys.toList();
  }

  Map<String, FeatureStyle> get featureStyles {
    Map _map = this['featureStyles'] ?? {};
    return _map.map((key, value) => MapEntry(key, FeatureStyle.fromMap(value)));
  }

  FeatureStyle getFeatureStyle(String featureId) {
    Map _map = this['featureStyles'][featureId];
    return FeatureStyle.fromMap(_map);
  }

  void setFeatureStyle(String featureId, FeatureStyle featureStyle) {
    this['featureStyles'][featureId] = <String, Object>{
      ...featureStyle.toPersistJson(),
    };
  }

  void addFeatureStyle(String styleId, FeatureStyle featureStyle) {
    addItem('featureStyles.${styleId}', featureStyle.toPersistJson());
  }

  void deleteFeatureStyle(String styleId) {
    deleteItem('featureStyles.${styleId}');
  }
}