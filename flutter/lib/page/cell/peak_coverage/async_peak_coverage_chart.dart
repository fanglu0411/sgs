import 'package:d4_scale/d4_scale.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/chart/scale/value_sale_type.dart';
import 'package:flutter_smart_genome/d3/color/schemes.dart';
import 'package:flutter_smart_genome/mixin/async_data_loader_mixin.dart';
import 'package:flutter_smart_genome/network/http_response.dart';
import 'package:flutter_smart_genome/page/cell/cell_page/cell_page_logic.dart';
import 'package:flutter_smart_genome/page/compare/compare_logic.dart';
import 'package:flutter_smart_genome/service/sgs_app_service.dart';
import 'package:flutter_smart_genome/service/single_cell_service.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/base/xy_plot_style_config.dart';
import 'package:flutter_smart_genome/widget/track/chromosome/chromosome_data.dart';
import 'package:flutter_smart_genome/widget/track/group_coverage/group_coverage_track_data.dart';
import 'package:flutter_smart_genome/widget/track/group_coverage/group_coverage_track_painter.dart';

import '../../../widget/track/common.dart';

typedef DataLoader = Future<HttpResponseBean<List<Map>>> Function(String peak);

class AsyncPeakCoverageChart extends StatefulWidget {
  // final DataLoader dataLoader;
  final String peak;
  final Track? track;
  final bool showLabel;
  final String? matrix;
  final String? group;
  final bool showAxis;
  final CompareElement compareElement;
  final Brightness? brightness;
  final ValueChanged<double>? onGetMaxValue;
  final double? customMaxValue;

  const AsyncPeakCoverageChart({
    Key? key,
    // required this.dataLoader,
    required this.peak,
    required this.track,
    required this.compareElement,
    this.showLabel = false,
    this.matrix,
    this.group,
    this.showAxis = true,
    this.brightness = null,
    this.onGetMaxValue,
    this.customMaxValue,
  }) : super(key: key);

  @override
  _AsyncPeakCoverageChartState createState() => _AsyncPeakCoverageChartState();
}

class _AsyncPeakCoverageChartState extends State<AsyncPeakCoverageChart> with AsyncDataLoaderMixin<AsyncPeakCoverageChart, GroupCoverageTrackData> {
  // GroupCoverageTrackData _featureData = GroupCoverageTrackData(<Map>[]);

  Map<String, Color>? _colorMap;
  num? _start, _end;
  ChromosomeData? _chr;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(AsyncPeakCoverageChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.matrix != widget.matrix || oldWidget.group != widget.group) {
      this.reloadData();
    }
  }

  Widget _builder(BuildContext context, BoxConstraints constraints) {
    Brightness _brightness = widget.brightness ?? Theme.of(context).brightness;
    bool _dark = _brightness == Brightness.dark;
    Color _primaryColor = Theme.of(context).colorScheme.primary;
    // var _trackStyle = SgsBrowseLogic.safe().getTrackStyle(widget.track.trackType).copy();
    Size size = constraints.biggest;
    return ClipRect(
      child: CustomPaint(
        size: Size(size.width, size.height),
        painter: GroupCoverageTrackPainter(
          orientation: Axis.horizontal,
          visibleRange: Range(start: _start!, end: _end!),
          trackHeight: size.height,
          trackData: data!,
          styleConfig: XYPlotStyleConfig(
            padding: EdgeInsets.symmetric(vertical: 10),
            backgroundColor: _dark ? Colors.grey[800]! : Colors.white,
            blockBgColor: _dark ? Colors.grey.withAlpha(50) : Colors.white,
            brightness: _brightness,
            selectedColor: _primaryColor.withAlpha(50),
            primaryColor: _primaryColor,
            colorMap: _colorMap!,
          ),
          splitMode: true,
          scale: ScaleLinear.number(domain: [_start!, _end!], range: [0, size.width]),
          track: widget.track,
          showSubFeature: false,
          // size of pixel < 1000
          selectedItem: null,
          cartesianType: false,
          valueScaleType: ValueScaleType.LINEAR,
          customMaxValue: widget.customMaxValue,
          showLabel: widget.showLabel,
          showAxis: widget.showAxis,
          onGetMaxValue: widget.onGetMaxValue,
        ),
      ),
    );
  }

  @override
  Widget buildContent() {
    return LayoutBuilder(builder: _builder);
  }

  @override
  Future<HttpResponseBean<List<Map>>> loadData(CancelToken cancelToken) async {
    if (widget.track == null) {
      return HttpResponseBean.error('No peak track found');
    }

    var site = SgsAppService.get()!.site!;
    var cellPageLogic = CellPageLogic.safe()!;

    HttpResponseBean featureLocationResp = await searchGene(host: site.url, speciesId: site.currentSpeciesId!, feature: widget.peak, track: cellPageLogic.track!);
    if (featureLocationResp.success) {
      var body = featureLocationResp.body;
      _chr = SgsAppService.get()!.chromosomes?.firstWhere((c) => c.id == body['chr_id'], orElse: null);
      _start = body['start'];
      _end = body['end'];
      if (_start != null && _end != null && _chr != null) {
        return loadMarkerPeakGroupCoverage(
          host: site.url,
          track: cellPageLogic.track!,
          matrixId: widget.compareElement.matrix,
          groupName: widget.compareElement.category,
          chrName: _chr!.chrName,
          featureName: widget.peak,
          start: _start!,
          end: _end!,
          cancelToken: cancelToken,
        );
      }
    }
    return HttpResponseBean<List<Map>>.error("load feature error");
  }

  @override
  Future<GroupCoverageTrackData> parseData(HttpResponseBean resp) async {
    List<Map> data = resp.body!;
    var stackGroup = data.map<String>((e) => e['group']).toList();
    List<Color> colors = safeSchemeColor(stackGroup.length, s: .8, v: .65);
    _colorMap = stackGroup.asMap().map<String, Color>((idx, key) {
      return MapEntry(key, colors[idx]);
    });
    return GroupCoverageTrackData(data);
  }
}
