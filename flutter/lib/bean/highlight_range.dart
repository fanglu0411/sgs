import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';

const defHighlightColor = Color(0x22ffbe3b);

class HighlightRange extends MapBean {
  HighlightRange.create({
    required int serverId,
    required String speciesId,
    required String speciesName,
    required String chrId,
    required String chrName,
    required num start,
    required num end,
    Color color = defHighlightColor,
    bool visible = true,
  }) : super({
          'serverId': serverId,
          'speciesId': speciesId,
          'speciesName': speciesName,
          'chrId': chrId,
          'chrName': chrName,
          'start': start,
          'end': end,
          'color': color.value,
          'visible': visible,
        });

  HighlightRange(Map source) : super(source);

  Range get range => Range(start: this['start'], end: this['end']);

  String get speciesId => this['speciesId'];

  String get speciesName => this['speciesName'];

  String get chrId => this['chrId'];

  String get chrName => this['chrName'];

  int get serverId => this['serverId'];

  Color get color => Color(this['color']);

  bool get visible => this['visible'] ?? true;

  void toggleVisible() {
    source['visible'] = !visible;
  }

  void setColor(Color color) {
    source['color'] = color.value;
  }

  String get storeKey => ('${serverId}/${speciesId}/${chrId}/${range.print('-')}'.hashCode).toString();
}
