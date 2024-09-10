import 'package:d4_scale/d4_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/bean/track_param.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';

typedef GestureWrapper = Widget Function(Widget child);
typedef TrackWidgetEventCallback = void Function<T, P>(T type, P params);

abstract class BaseTrackWidget extends StatefulWidget {
  final ScaleLinear<num> scale;
  final TrackParams trackParams;
  final Range range;
  final Color? background;
  final Axis? orientation;
  final ValueChanged<Track>? onRemoveTrack;
  final SiteItem site;
  final GestureDetector? gestureBuilder;
  final TrackWidgetEventCallback? eventCallback;
  final bool touchScaling;
  final double? touchScale;
  final bool fixTitle;
  final double? containerHeight;
  final ValueChanged<Feature>? onZoomToRange;

  const BaseTrackWidget({
    Key? key,
    required this.range,
    required this.scale,
    required this.trackParams,
    required this.site,
    this.background,
    this.orientation = Axis.horizontal,
    this.onRemoveTrack,
    this.gestureBuilder,
    this.eventCallback,
    this.touchScaling = false,
    this.touchScale,
    this.fixTitle = false,
    this.containerHeight,
    this.onZoomToRange,
  }) : super(key: key);
}
