import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/track/base/feature_style_mixin.dart';
import 'package:flutter_smart_genome/widget/track/base/track_style.dart';
import 'package:flutter_smart_genome/widget/track/painter/feature_style_config.dart';
import '../track_ui_config_bean.dart';

class GffStyle extends TrackStyle with FeaturedStyleMixin {
  GffStyle(Map map, Brightness brightness) : super(map, brightness);

  GffStyle.empty(Brightness brightness) : super.empty(brightness);

  GffStyle.defaultTheme([String name = 'sgs-theme'])
      : super.from(lightStyleMap: {
          'name': name,
          'track_color': Color(0xffac4f48),
          'track_height': 300.0,
          'track_max_height': {'enabled': true, 'value': 500},
          'feature_height': 12.0,
          'show_label': true,
          'label_font_size': 12.0,
          'text_color': Colors.black54,
          'feature_group_color': Color(0x6dc8d3c9),
          'collapse_mode': TrackCollapseMode.expand.index,
          'featureStyles': {
            'gene': FeatureStyle(color: Colors.green, alpha: 200, name: 'gene', id: 'gene'),
            'cds': FeatureStyle(color: Colors.redAccent, alpha: 200, name: 'CDS', id: 'cds'),
            'exon': FeatureStyle(color: Colors.deepPurpleAccent, alpha: 200, name: 'exon', id: 'exon'),
            'intron': FeatureStyle(color: Colors.grey, alpha: 200, height: .1, name: 'intron', id: 'intron'),
            'five_prime_utr': FeatureStyle(color: Colors.blue, alpha: 80, height: .5, name: 'five_prime_UTR', id: 'five_prime_utr'),
            'three_prime_utr': FeatureStyle(color: Colors.blue, alpha: 80, height: .5, name: 'three_prime_UTR', id: 'three_prime_utr'),
            'promoter': FeatureStyle(color: Colors.teal, alpha: 200, name: 'promoter', id: 'promoter'),
            'others': FeatureStyle(color: Colors.lightGreen, alpha: 100, name: 'others', id: 'others'),
          }.map((key, value) => MapEntry(key, value.toPersistJson())),
        }, darkStyleMap: {
          'name': 'SGS-Light',
          'track_color': Colors.redAccent,
          'track_height': 300.0,
          'track_max_height': {'enabled': true, 'value': 500},
          'feature_height': 12.0,
          'show_label': true,
          'label_font_size': 12.0,
          'text_color': Colors.white70,
          'feature_group_color': Color(0xff393c3a),
          'collapse_mode': TrackCollapseMode.expand.index,
          'featureStyles': {
            'gene': FeatureStyle(color: Colors.lime, alpha: 200, name: 'gene', id: 'gene'),
            'cds': FeatureStyle(color: Colors.orange, alpha: 100, name: 'CDS', id: 'cds'),
            'exon': FeatureStyle(color: Colors.redAccent, alpha: 100, name: 'exon', id: 'exon'),
            'intron': FeatureStyle(color: Colors.grey, alpha: 200, height: .1, name: 'intron', id: 'intron'),
            'five_prime_utr': FeatureStyle(color: Colors.green, alpha: 80, height: .5, name: 'five_prime_UTR', id: 'five_prime_utr'),
            'three_prime_utr': FeatureStyle(color: Colors.greenAccent, alpha: 80, height: .5, name: 'three_prime_UTR', id: 'three_prime_utr'),
            'promoter': FeatureStyle(color: Colors.teal, alpha: 200, name: 'promoter', id: 'promoter'),
            'others': FeatureStyle(color: Colors.teal, alpha: 80, name: 'others', id: 'others'),
          }.map((key, value) => MapEntry(key, value.toPersistJson())),
        }) {}

  // List get featureList {
  //   Map _map = this['featureStyles'];
  //   return _map.keys.toList();
  // }
  //
  // Map<String, FeatureStyle> get featureStyles {
  //   Map _map = this['featureStyles'];
  //   return _map.map((key, value) => MapEntry(key, FeatureStyle.fromMap(value)));
  // }
  //
  // FeatureStyle getFeatureStyle(String featureId) {
  //   Map _map = this['featureStyles'][featureId];
  //   return FeatureStyle.fromMap(_map);
  // }
  //
  // void setFeatureStyle(String featureId, FeatureStyle featureStyle) {
  //   this['featureStyles'][featureId] = featureStyle.toPersistJson();
  // }
  //
  // void addFeatureStyle(String styleId, FeatureStyle featureStyle) {
  //   addItem('featureStyles.${styleId}', featureStyle.toPersistJson());
  // }
  //
  // void deleteFeatureStyle(String styleId) {
  //   deleteItem('featureStyles.${styleId}');
  // }

  @override
  String toString() {
    return '${json}';
  }

  @override
  GffStyle copy() {
    return GffStyle(copySourceMap(), brightness);
  }
}
