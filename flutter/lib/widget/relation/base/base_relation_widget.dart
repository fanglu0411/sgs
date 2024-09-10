import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/widget/relation/base/relation_params.dart';
import 'package:flutter_smart_genome/widget/track/base/base_track_widget.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';

abstract class BaseRelationWidget extends StatefulWidget {
  final Track track;

  // final LinearScale scale1;
  // final LinearScale scale2;
  final RelationParams relationParams;
  final Color? background;
  final Axis orientation;
  final SiteItem site;
  final TrackWidgetEventCallback? eventCallback;
  final bool touchScaling;

  // final double touchScale;
  final double? containerHeight;
  final ValueChanged<Feature>? onZoomToRange;
  final GestureDetector? gestureBuilder;
  final GestureDetector? gestureBuilder2;

  const BaseRelationWidget({
    Key? key,
    required this.track,
    // required this.scale1,
    // required this.scale2,
    required this.relationParams,
    required this.site,
    this.background,
    this.orientation = Axis.horizontal,
    this.eventCallback,
    this.touchScaling = false,
    // required this.touchScale,
    this.containerHeight,
    this.onZoomToRange,
    this.gestureBuilder,
    this.gestureBuilder2,
  }) : super(key: key);

  bool chrChanged(BaseRelationWidget newWidget) {
    return this.relationParams.chr1 != newWidget.relationParams.chr1 || //
        this.relationParams.chr2 != newWidget.relationParams.chr2;
  }
}