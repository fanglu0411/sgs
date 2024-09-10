import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/bean/track_param.dart';
import 'package:d4_scale/d4_scale.dart';
import 'package:flutter_smart_genome/mixin/track_data_mixin.dart';
import 'package:flutter_smart_genome/widget/track/base/abstract_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/base/base_track_widget.dart';
import 'package:flutter_smart_genome/widget/track/base/empty_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/base/style_config.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';

class EmptyTrackWidget extends BaseTrackWidget {
  final String label;

  EmptyTrackWidget({
    Key? key,
    required SiteItem site,
    required ScaleLinear<num> scale,
    required TrackParams trackParams,
    required Range range,
    Color? background,
    Axis orientation = Axis.horizontal,
    ValueChanged<Track>? onRemoveTrack,
    GestureDetector? gestureBuilder,
    TrackWidgetEventCallback? trackEventCallback,
    required bool touchScaling,
    double? touchScale,
    required bool fixTitle,
    double? maxHeight,
    required this.label,
  }) : super(
          key: key,
          site: site,
          scale: scale,
          trackParams: trackParams,
          range: range,
          background: background,
          orientation: orientation,
          onRemoveTrack: onRemoveTrack,
          gestureBuilder: gestureBuilder,
          eventCallback: trackEventCallback,
          touchScaling: touchScaling,
          touchScale: touchScale,
          fixTitle: fixTitle,
          containerHeight: maxHeight,
        );

  @override
  _EmptyTrackWidgetState createState() => _EmptyTrackWidgetState();
}

class _EmptyTrackWidgetState extends State<EmptyTrackWidget> with TrackDataMixin, SingleTickerProviderStateMixin {
  @override
  void initState() {
    trackData = [];
    super.initState();
  }

  @override
  void initVisibleScale(TrackParams trackParams) {
    //do nothing
  }

  @override
  AbstractTrackPainter<TrackData, StyleConfig> getTrackPainter() {
    return EmptyTrackPainter(
      visibleRange: widget.range,
      scale: widget.scale,
      orientation: widget.orientation,
      label: widget.label,
      brightness: Theme.of(context).brightness,
    );
  }

  @override
  bool needLoadData() => false;

  @override
  Future<bool> checkNeedReloadData(EmptyTrackWidget oldWidget) => Future.value(false);

  @override
  void dispose() {
    super.dispose();
  }
}
