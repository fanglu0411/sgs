import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/track_param.dart';
import 'package:flutter_smart_genome/components/setting_config_widget.dart';
import 'package:flutter_smart_genome/mixin/track_data_mixin.dart';
import 'package:flutter_smart_genome/service/abs_platform_service.dart';
import 'package:flutter_smart_genome/service/beans.dart';
import 'package:flutter_smart_genome/widget/track/base/base_track_widget.dart';
import 'package:flutter_smart_genome/widget/track/base/empty_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/base/style_config.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/base/abstract_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/base/track_menu_config.dart';
import 'package:flutter_smart_genome/widget/track/base/zoom_see_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';
import 'package:flutter_smart_genome/widget/track/sequence/sequence_data.dart';
import 'package:flutter_smart_genome/widget/track/sequence/sequence_style_config.dart';
import 'package:flutter_smart_genome/widget/track/sequence/sequence_track_painter.dart';
import 'package:flutter_smart_genome/extensions/common_extensions.dart';

class SequenceTrackWidget extends BaseTrackWidget {
  const SequenceTrackWidget({
    super.key,
    required super.site,
    required super.scale,
    required super.trackParams,
    required super.range,
    super.background,
    super.orientation,
    super.onZoomToRange,
    super.onRemoveTrack,
    super.gestureBuilder,
    super.eventCallback,
    super.touchScaling,
    super.touchScale,
    super.fixTitle,
    double? maxHeight,
  }) : super(
          containerHeight: maxHeight,
        );

  @override
  State<SequenceTrackWidget> createState() => _SequenceTrackWidgetState();
}

class _SequenceTrackWidgetState extends State<SequenceTrackWidget> with TrackDataMixin {
  bool _showProtein = false;
  MapEntry<Range, List<Range>>? _seqRangeFileEntry;

  @override
  void initState() {
    trackTotalHeight = 24;
    trackData = [];
    _showProtein = false;
    super.initState();
  }

  @override
  void initVisibleScale(TrackParams trackParams) {
    //do nothing
  }

  @override
  bool needLoadData() {
    var needLoad = trackParams.bpPerPixel < 2;
    return needLoad;
  }

  @override
  Future<bool> checkNeedReloadData(SequenceTrackWidget oldWidget) async {
    if (!needLoadData()) return false;

    if (trackData == null || trackData!.isEmpty) return true;
    MapEntry<Range, List<Range>> seqRangeFileEntry = AbsPlatformService.get()!.findSequenceFilesInRange(
      host: widget.site.url,
      range: widget.range,
      fileSequenceLength: trackParams.chr.blockLength!,
      chr: trackParams.chrId,
    );
    if (!listEquals(_seqRangeFileEntry?.value.toList(), seqRangeFileEntry.value.toList())) {
      _seqRangeFileEntry = seqRangeFileEntry;
      return true;
    }
    return false;
  }

  @override
  Future loadTrackData([bool isRefresh = false]) async {
    if (!needLoadData()) return;
    if (isRefresh) {
      setState(() {
        loading = true;
      });
    }
    RangeSequence rangeSequence = await AbsPlatformService.get()!.loadSequence(
      host: widget.site.url,
      scale: trackParams.bpPerPixel,
      range: widget.range,
      species: trackParams.speciesId,
//      track: trackParams.track,
      chr: trackParams.chrId,
      blockLength: 10000,
    );
    await Future.delayed(Duration(milliseconds: 100));
    if (mounted)
      setState(() {
        loading = false;
        error = null;
        trackData = [rangeSequence];
        viewType = getTrackViewType();
      });
  }

  @override
  List<SettingItem> getContextMenuList(var hitItem) {
    List<SettingItem> settings = TrackMenuConfig.refTrackSettings;
    SettingItem seqItem = settings.firstWhere((element) => element.key == TrackContextMenuKey.ref_seq);
    Map colorMap = trackStyle.colorMap!;
    seqItem.children!.forEach((s) {
      s.value = colorMap[s.key];
    });

    SettingItem proteinItem = settings.firstWhere((element) => element.key == TrackContextMenuKey.ref_protein);
    proteinItem.value = _showProtein;

    SettingItem fontItem = settings.firstWhere((element) => element.key == TrackContextMenuKey.label_font_size);
    fontItem.value = trackStyle.fontSize;
    return settings;
  }

  @override
  bool onContextMenuItemChanged(SettingItem? p, SettingItem item) {
    if (['A', 'T', 'C', 'G'].contains(item.key)) {
      Map _cm = trackStyle['colorMap'];
      Color _color = item.value;
      _cm[item.key] = _color.hexString;
      setState(() {});
    } else if (item.key == TrackContextMenuKey.ref_protein) {
      _showProtein = item.value;
      setState(() {});
    } else if (item.key == TrackContextMenuKey.label_font_size) {
      trackStyle.fontSize = item.value;
      setState(() {});
    } else {
      return super.onContextMenuItemChanged(p, item);
    }
    return true;
  }

  @override
  AbstractTrackPainter<TrackData, StyleConfig> getTrackPainter() {
    if (trackParams.bpPerPixel > 1) {
      // 一个pixel代表一个size
      return ZoomSeeTrackPainter(
        visibleRange: widget.range,
        scale: widget.scale,
        orientation: widget.orientation,
        style: Theme.of(context).textTheme.bodySmall!,
      );
    } else if (trackData?.isNotEmpty ?? false) {
//      String _data = trackData[0] as String;
      RangeSequence _data = trackData![0] as RangeSequence;
      return SequenceTrackPainter(
        visibleRange: widget.range,
        orientation: widget.orientation,
        pixelOfSeq: trackParams.pixelPerBp,
        trackData: SequenceData(sequence: _data.sequence!, range: widget.range, sequenceRange: _data.range),
        styleConfig: SequenceStyleConfig(
          backgroundColor: widget.background ?? Colors.white,
          blockBgColor: Colors.lightBlue[100]!.withOpacity(.5),
          proteinColor1: Colors.cyan[200]!,
          proteinColor2: Colors.cyan[400]!,
          seqColor: trackStyle.colorMap!,
          seqFontSize: trackStyle.fontSize,
          brightness: Theme.of(context).brightness,
        ),
        linearScale: widget.scale,
        track: trackParams.track,
        translateProtein: _showProtein,
      );
    }

    return EmptyTrackPainter(
      orientation: widget.orientation,
      brightness: Theme.of(context).brightness,
      visibleRange: widget.range,
      scale: widget.scale,
    );
  }

//  @override
//  List<double> transformData<double>(List data) {
//    return data.map<double>((e) => e * 1.0).toList();
//  }

  @override
  D dataItemMapper<D>(item) {
    return item as D;
  }
}
