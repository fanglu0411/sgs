import 'dart:convert';
import 'dart:math';

import 'package:dartx/dartx.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/cell/data_category.dart';
import 'package:flutter_smart_genome/chart/graphic/plot/grouped_scatter_plot.dart';
import 'package:d4_scale/d4_scale.dart';
import 'package:flutter_smart_genome/chart/scale/point.dart';
import 'package:flutter_smart_genome/d3/d3_mixin.dart';
import 'package:flutter_smart_genome/extensions/d4_extension.dart';
import 'package:flutter_smart_genome/mixin/async_data_loader_mixin.dart';
import 'package:flutter_smart_genome/mixin/text_painter_mixin.dart';
import 'package:flutter_smart_genome/network/http_response.dart';
import 'package:flutter_smart_genome/page/cell/cell_page/cell_page_logic.dart';
import 'package:flutter_smart_genome/page/cell/cell_plot_legend/linear_legend_view.dart';
import 'package:flutter_smart_genome/page/cell/cell_scatter_chart/cell_scatter_chart_state.dart';
import 'package:flutter_smart_genome/page/cell/cell_scatter_chart/circular_progress_view.dart';
import 'package:flutter_smart_genome/page/cell/cell_scatter_chart/density_plot_matrix.dart';
import 'package:flutter_smart_genome/page/cell/cell_scatter_chart/gene_plot_matrix.dart';
import 'package:flutter_smart_genome/page/cell/cell_scatter_chart/l_rect.dart';
import 'package:flutter_smart_genome/page/cell/cell_scatter_chart/legend_colors.dart';
import 'package:flutter_smart_genome/service/sgs_app_service.dart';
import 'package:flutter_smart_genome/service/single_cell_service.dart';
import 'package:flutter_smart_genome/util/logger.dart';
import 'package:flutter_smart_genome/util/random_color/random_file.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/base/types.dart';
import 'package:get/get.dart';

class AsyncScatterWidget extends StatefulWidget {
  final Track track;
  final String modId;
  final List<String> features;
  final String plotType;
  final String group;
  final double width;
  final double height;
  final Spatial? spatial;
  final LegendColor? legendColor;
  final double pointSize;
  final double opacity;
  final int index;

  final Function2<GenePlotMatrix, List<Color>, void>? onTap;

  const AsyncScatterWidget({
    super.key,
    required this.track,
    required this.plotType,
    required this.modId,
    required this.features,
    required this.group,
    required this.index,
    this.onTap,
    required this.width,
    required this.height,
    this.legendColor,
    this.spatial,
    this.pointSize = 3,
    this.opacity = 1.0,
  });

  @override
  State<AsyncScatterWidget> createState() => _AsyncScatterWidgetState();
}

class _AsyncScatterWidgetState extends State<AsyncScatterWidget> with AsyncDataLoaderMixin<AsyncScatterWidget, List> {
  bool _hover = false;

  GenePlotMatrix? _featurePlotMatrix;
  List<Color>? _colors;

  // MaterialColor mc = RandomColor().randomMaterialColor(colorHue: ColorHue.random, colorSaturation: ColorSaturation.highSaturation);
  late LegendColor _legendColor;

  CancelToken? _cancelToken;

  @override
  Duration get loadDelay => Duration(milliseconds: widget.index * 2000);

  @override
  void initState() {
    super.initState();
    // MaterialColor mc = RandomColor().randomMaterialColor(colorHue: ColorHue.random, colorSaturation: ColorSaturation.highSaturation);
    _legendColor = (widget.legendColor ?? expressionLegendColors.first).copyWith();
  }

  @override
  void didUpdateWidget(covariant AsyncScatterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(widget.features, oldWidget.features)) {
      reloadData();
    } else if (widget.legendColor != oldWidget.legendColor) {
      var __legendColor = (widget.legendColor ?? expressionLegendColors.first).copyWith(
        min: _legendColor.min,
        max: _legendColor.max,
      );
      _legendColor = __legendColor;
      _featurePlotMatrix?.changeLegends(_legendColor);
      _setColors();
    }
    // else if (widget.legendColor != oldWidget.legendColor) {
    //   _featurePlotMatrix?.changeLegends(widget.legendColor);
    //   _setColors();
    // }
  }

  Size get canvasSize {
    Size viewport = Size(widget.width, widget.height);
    if (widget.spatial == null || !widget.spatial!.currentSlice.hasSize) {
      return Size.square(viewport.shortestSide);
    }
    return widget.spatial!.currentSlice.toCanvasSize(viewport);
  }

  @override
  Widget buildContent() {
    var _canvasSize = canvasSize;
    double left = (widget.width - _canvasSize.width) / 2, top = (widget.height - _canvasSize.height) / 2;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (widget.spatial != null)
          Positioned(
            left: left,
            top: top,
            child: Image.network(
              '${SgsAppService.get()!.staticBaseUrl}${widget.spatial!.currentSlice.image}',
              fit: BoxFit.contain,
              alignment: Alignment.topLeft,
              width: widget.width,
              height: widget.height,
            ),
          ),
        // Center(
        //   child: AspectRatio(
        //     aspectRatio: 1.0,
        //     child: GroupedScatterPlot(
        //       data: _featurePlotMatrix!.groupedData!,
        //       cordMax: _featurePlotMatrix!.domainScale.rangeMax,
        //       colors: _colors?.map((c) => c.withOpacity(widget.opacity)).toList(),
        //       dotSize: widget.pointSize,
        //       label: widget.features.join(', '),
        //       labelColor: Theme.of(context).textTheme.bodyMedium?.color,
        //       domainMapper: (v) => _featurePlotMatrix!.domainScale.call(v)!,
        //       revertY: widget.spatial != null,
        //     ),
        //   ),
        // ),
        Positioned(
          left: left,
          top: top,
          child: CustomPaint(
            size: _canvasSize,
            painter: SimpleScatterPlotPainter(
              _featurePlotMatrix!,
              pointSize: widget.pointSize,
              label: '${widget.features.join(', ')}${_emptyData ? '\n(no expression)' : ''}',
              dark: Theme.of(context).brightness == Brightness.dark,
              opacity: widget.opacity,
            ),
            isComplex: true,
            willChange: false,
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            margin: EdgeInsets.only(right: 10),
            child: LinearLegendView(
              color: _featurePlotMatrix!.legendColor,
              width: 18,
              height: 100,
            ),
            // CategoryLegendView(
            //   legends: _featurePlotMatrix!.legends!,
            //   editable: false,
            // ),
          ),
        ),
        if (widget.onTap != null)
          Positioned(
            right: 6,
            top: 6,
            child: IconButton(
                padding: EdgeInsets.zero,
                constraints: BoxConstraints.tightFor(width: 30, height: 30),
                iconSize: 20,
                onPressed: () {
                  if (_featurePlotMatrix?.groupedData == null) return;
                  widget.onTap?.call(_featurePlotMatrix!, _colors!);
                },
                icon: Icon(Icons.fullscreen)),
          ),
      ],
    );
  }

  @override
  Widget buildLoading() {
    return Center(
      child: CircularProgressView(
        width: 52,
        height: 52,
        strokeWidth: 4,
        finish: loadingFinish,
        finishDuration: Duration(milliseconds: 450),
        updatePeriod: 300 + widget.index * 50,
      ),
    );
  }

  @override
  Future onBeforeSetData() async {
    super.onBeforeSetData();
    setState(() {});
    await Future.delayed(Duration(milliseconds: 500));
  }

  @override
  Future<HttpResponseBean> loadData(CancelToken cancelToken) async {
    // await Future.delayed(Duration(milliseconds: Random().nextInt(4) * 100));
    if (widget.spatial != null) {
      return loadSpatialFeatureExpressions(
        track: widget.track,
        matrixId: widget.modId,
        spatial: widget.spatial!.key,
        features: widget.features,
        cancelToken: cancelToken,
      );
    }
    return loadFeaturePlotData(
      track: widget.track,
      matrixId: widget.modId,
      features: widget.features,
      plotType: widget.plotType,
      cancelToken: cancelToken,
    );
  }

  bool _emptyData = false;

  @override
  Future<List?> parseData(HttpResponseBean resp) async {
    List data = resp.body is String ? json.decode(resp.body) : resp.body;
    _emptyData = data.isEmpty;

    List bgCords = await _loadAllBgCords() ?? [];

    num _minX = 0, _maxX = 0, _minY = 0, _maxY = 0;
    for (var item in [...bgCords, ...data]) {
      _minX = min(_minX, item[2]);
      _maxX = max(_maxX, item[2]);
      _minY = min(_minY, item[3]);
      _maxY = max(_maxY, item[3]);
    }

    (int x, int y, SpatialCordScaleType cordScaleBy)? cordMaxValue = _cordMaxValue(widget.spatial);
    List<int> dataMax = _fixMaxValue([_minX, _maxX, _minY, _maxY]);

    List<int>? targetCordRange;
    if (cordMaxValue != null) {
      var (int x, int y, SpatialCordScaleType cordScaleBy) = cordMaxValue;
      switch (cordScaleBy) {
        case SpatialCordScaleType.width:
          if (dataMax[1] < x) {
            targetCordRange = [0, x, 0, x];
          } else {
            targetCordRange = [dataMax[0], dataMax[1], dataMax[0], dataMax[1]];
          }
          break;
        case SpatialCordScaleType.height:
          if (dataMax[3] < y) {
            targetCordRange = [0, y, 0, y];
          } else {
            targetCordRange = [dataMax[2], dataMax[3], dataMax[2], dataMax[3]];
          }
          break;
        case SpatialCordScaleType.both:
          targetCordRange = [
            0,
            dataMax[1] < x ? x : dataMax[1],
            0,
            dataMax[3] < y ? y : dataMax[3],
          ];
          break;
      }
    }
    targetCordRange ??= dataMax;
    List<int> _fitMax = targetCordRange;

    logger.d('---->>> dataMax: $dataMax, calculated: ${cordMaxValue} fit max: $_fitMax');
    Scale<num, num> _domainScaleX = ScaleLinear.number(domain: [_fitMax[0], _fitMax[1]], range: [.0, DensityGroupPlotMatrix.MAX_DOMAIN]);
    Scale<num, num> _domainScaleY = ScaleLinear.number(domain: [_fitMax[2], _fitMax[3]], range: [.0, DensityGroupPlotMatrix.MAX_DOMAIN]);

    var _canvasSize = canvasSize;
    _featurePlotMatrix = GenePlotMatrix(
      genePlotData: [...bgCords, ...data],
      domainRange: LRect.LTRB(0, 0, 65535.0, 65535.0),
      viewRect: LRect.LTWH(0, 0, _canvasSize.width, _canvasSize.height),
      legendColor: _legendColor,
      domainScale: _domainScaleX,
      domainScaleY: _domainScaleY,
      isSpatial: widget.spatial != null,
      computeCord: true,
    );
    _setColors();
    return data;
  }

  List<int> _fixMaxValue(List<num> value) {
    if (value[1] > 50000 || value[3] > 50000) return [0, DensityGroupPlotMatrix.MAX_DOMAIN, 0, DensityGroupPlotMatrix.MAX_DOMAIN];
    var xabs = max(value[0].abs(), value[1].abs()).ceil();
    var yabs = max(value[2].abs(), value[3].abs()).ceil();
    return [
      value[0] < 0 ? -xabs : 0,
      xabs, // value[1].ceil(),
      value[2] < 0 ? -yabs : 0,
      yabs, //value[3].ceil(),
    ];
  }

  ///usually use short side , some use long side
  (int x, int y, SpatialCordScaleType cordScaleBy)? _cordMaxValue(Spatial? spatial) {
    if (spatial == null || !spatial.currentSlice.hasSize) return null;
    List maxs = spatial.currentSlice.calculateCordRange();
    return (maxs[0], maxs[1], spatial.currentSlice.cordScaleBy);
    // return spatial.currentSlice.fixCord
    //     ? (spatial.currentSlice.calculateCordRange(), spatial.currentSlice.calculateCordRange())
    //     : (spatial.currentSlice.calculateCordRangeByShortSide(), spatial.currentSlice.calculateCordRangeByLongSide());
  }

  void _setColors() {
    if (_featurePlotMatrix == null) return;
    _colors = _featurePlotMatrix!.legends!.map((e) => e.drawColor).toList();
    if (_colors!.length < 2) {
      var __colors = RandomColor().randomColors(
        count: _featurePlotMatrix!.groupedData!.length.clamp(2, 1000),
        colorHue: ColorHue.red,
        colorBrightness: ColorBrightness.primary,
        colorSaturation: ColorSaturation.mediumSaturation,
      );
      _colors!.addAll(__colors);
    }
    // _colors = RandomColor().randomColors(
    //   count: _featurePlotMatrix!.groupedData!.length.clamp(2, 1000),
    //   colorHue: ColorHue.red,
    //   colorBrightness: ColorBrightness.primary,
    //   colorSaturation: ColorSaturation.mediumSaturation,
    // );
  }

  Future<List?> _loadAllBgCords() async {
    var url = SgsAppService.get()!.site!.url;
    _cancelToken = CancelToken();
    var fetch = widget.spatial != null
        ? loadSpatialPlotData(
            host: url,
            track: widget.track,
            matrixId: widget.modId,
            groupName: widget.group,
            spatialKey: widget.spatial!.key,
            cancelToken: _cancelToken,
          )
        : loadCellPlotData(
            host: url,
            track: widget.track,
            groupName: widget.group,
            plotType: widget.plotType,
            matrixId: widget.modId,
            cancelToken: _cancelToken,
          );
    var resp = await fetch;
    if (resp.success) {
      Map _data = resp.body;
      MatrixBean mod = CellPageLogic.safe()!.track!.matrixList!.firstWhere((e) => e.id == widget.modId);
      if (mod.isCartesian(widget.group) || _data['scope'] != null) {
        // cartesian data, set cluster manually,
        List scope = _data['scope'];
        List plots = _data['coord'];
        return plots.map((item) => [item[0], 0, item[2], item[3]]).toList();
      } else {
        Map<String, List> cords = resp.body;
        List _cords = cords.values.flatten().map((e) => [e[0], 0, e[1], e[2]]).toList();
        return _cords;
      }
    }
    return Future.value(null);
  }
}

class SimpleScatterPlotPainter extends CustomPainter with TextPainterMixin {
  GenePlotMatrix featurePlotMatrix;
  late Paint _paint;
  double? pointSize = 3;
  double opacity = 1.0;
  final String? label;
  bool dark;

  SimpleScatterPlotPainter(
    this.featurePlotMatrix, {
    this.pointSize,
    this.opacity = 1.0,
    this.label,
    this.dark = false,
  }) {
    _paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
  }

  @override
  void paint(Canvas canvas, Size size) {
    _paint..strokeWidth = pointSize!;
    featurePlotMatrix.transformAndDraw(canvas, _paint, Rect.zero, 3, samplingCount: 100000, opacity: opacity);

    if (label != null) {
      drawText(
        canvas,
        text: label!,
        offset: size.topCenter(Offset(0, 10)),
        width: 2,
        style: TextStyle(color: dark ? Colors.white70 : Colors.black87, fontSize: 12),
        textAlign: TextAlign.center,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SimpleScatterPlotPainter oldDelegate) {
    return featurePlotMatrix != oldDelegate.featurePlotMatrix || pointSize != oldDelegate.pointSize || opacity != oldDelegate.opacity;
  }
}
