import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/cell/data_category.dart';
import 'package:flutter_smart_genome/cell/point_axis_painter.dart';
import 'package:flutter_smart_genome/cell/point_data_matrix.dart';
import 'package:flutter_smart_genome/chart/base/interactive_viewport.dart';
import 'package:flutter_smart_genome/chart/scale/point.dart';
import 'package:flutter_smart_genome/extensions/rect_extension.dart';
import 'package:flutter_smart_genome/network/core/http_error.dart';
import 'package:flutter_smart_genome/page/cell/cell_page/cell_page_logic.dart';
import 'package:flutter_smart_genome/page/cell/cell_scatter_chart/cell_plot_chart_painter.dart';
import 'package:flutter_smart_genome/page/cell/cell_scatter_chart/cell_scatter_chart_logic.dart';
import 'package:flutter_smart_genome/page/cell/cell_scatter_chart/density_data.dart';
import 'package:flutter_smart_genome/page/cell/cell_scatter_chart/density_plot_matrix.dart';
import 'package:flutter_smart_genome/page/cell/cell_scatter_chart/gene_plot_matrix.dart';
import 'package:flutter_smart_genome/page/cell/cell_scatter_chart/legend_colors.dart';
import 'package:flutter_smart_genome/page/cell/cell_scatter_chart/plot_states.dart';
import 'package:flutter_smart_genome/page/cell/cell_scatter_chart/scatter_front_controller.dart';
import 'package:flutter_smart_genome/page/cell/cell_scatter_chart/scatter_label_position.dart';
import 'package:flutter_smart_genome/page/cell/quick_scatter/canvas_controller.dart';
import 'package:flutter_smart_genome/util/debouncer.dart';
import 'package:flutter_smart_genome/util/logger.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/base/types.dart';
import 'package:flutter_smart_genome/widget/upload/platform_entry.dart';
import 'package:get/get.dart';

import 'l_rect.dart';

class CellScatterChartState {
  late TransformationController _transformationController;

  TransformationController get transformationController => _transformationController;

  late CanvasController _canvasController;

  CanvasController get canvasController => _canvasController;

  late ScatterFrontController _scatterFrontController;

  ScatterFrontController get scatterFrontController => _scatterFrontController;

  DensityGroupPlotMatrix? _groupPlotMatrix;

  DensityGroupPlotMatrix? get groupDataMatrix => _groupPlotMatrix;

  Map<String, ScatterLabel>? get groupLabelMap => _groupPlotMatrix?.groupLabelMap;

  //单个feature的分布
  GenePlotMatrix? _featurePlotMatrix;

  GenePlotMatrix? get featureDataMatrix => _featurePlotMatrix;

  DensityPlot? _densityPlot;

  CellPlotChartPainter? _plotPainter;

  CellPlotChartPainter? get plotPainter => _plotPainter;

  PointAxisPainter? _scatterFontPainter;

  PointAxisPainter? get scatterFontPainter => _scatterFontPainter;
  late ValueNotifier<Offset> _hoverPointNotifier;

  ValueNotifier<Offset> get hoverOffsetNotifier => _hoverPointNotifier;

  late PlotDrawState _plotDrawState;

  PlotDrawState get plotDrawState => _plotDrawState;

  String? _tapCluster;

  DensityCords<List>? _dataMatrix;
  Offset? _interactionStart;

  bool _selectionMode = false;

  bool get selectionMode => _selectionMode;

  bool loading = false;
  bool finishLoading = false;

  HttpError? error = null;
  String? loadingMessage = 'Loading cords...';

  Uint8List? _spatialBg;

  Uint8List? get spatialBg => _spatialBg;

  void set spatialBg(Uint8List? bg) => _spatialBg = bg;

  MatrixBean? mod;

  Spatial? spatial;

  String? _plotType;

  String? get plotType => _plotType;

  void set plotType(String? plot) {
    _plotType = plot;
  }

  bool get isInvalidSpatial => _plotType == Spatial.SPATIAL_PLOT && null == spatial;

  bool get isValidSpatial => _plotType == Spatial.SPATIAL_PLOT && null != spatial;

  UploadFileItem? _plotFile;

  // Size? _containerSize;
  Size? _canvasSize;
  Size? _viewportSize;

  Size? get viewportSize => _viewportSize;

  Size? get canvasSize => _canvasSize;

  double _dotSize = 4.0;
  double _pointOpacity = 1.0;

  double get pointOpacity => _pointOpacity;

  double get pointSize => _dotSize;

  // bool _splitMode = false;

  bool interacting = false;
  Rect? _selectRect;
  Rect? _targetRectStart;
  List<Offset> _viewportPathPoints = [];

  GlobalKey<InteractiveViewerState> _viewPortKey = GlobalKey<InteractiveViewerState>();

  GlobalKey<InteractiveViewerState> get viewPortKey => _viewPortKey;

  Debounce? _debounce;
  String tag;
  List<String>? features;

  bool get secondary => tag == CellPageLogic.CHART_TAG_2;

  CellScatterChartState({required this.tag}) {
    _hoverPointNotifier = ValueNotifier(Offset.zero);
    _transformationController = TransformationController();
    _canvasController = CanvasController(matrix4: _transformationController.value, pointSize: _dotSize);
    _scatterFrontController = ScatterFrontController(matrix: _transformationController.value);
    _plotDrawState = PlotDrawState();
    _debounce = Debounce(milliseconds: 30);
  }

  void setData(Map<String, List> groupedCords, List<String> clusters, Map<String, DataCategory> legendMap, {double? pointSize}) async {
    if (pointSize != null) _dotSize = pointSize;
    loading = false;
    error = null;
    _tapCluster = null;

    //use short side ,canvas size is square
    (int x, int y, SpatialCordScaleType cordScaleBy)? cordMaxValue = _cordMaxValue(spatial);
    // var h = spatial != null && !spatial!.currentSlice.size.isEmpty ? (spatial!.currentSlice.size.height / spatial!.currentSlice.size.width) * canvasSize!.width : canvasSize!.height;
    // double viewScale = spatial != null && !spatial!.currentSlice.size.isEmpty ? canvasSize!.width / spatial!.currentSlice.size.width : 1.0;
    _groupPlotMatrix?.dispose();
    _groupPlotMatrix = DensityGroupPlotMatrix(
      categories: clusters,
      groupData: groupedCords,
      legendMap: legendMap,
      domainRange: LRect.LTRB(0, 0, DensityGroupPlotMatrix.MAX_DOMAIN.toDouble(), DensityGroupPlotMatrix.MAX_DOMAIN.toDouble()),
      viewRect: LRect.LTWH(0, 0, canvasSize!.width, canvasSize!.height),
      domainBlockSize: Point(256, 256),
      isSpatial: spatial != null,
      // spatialScaleFactor: spatial?.currentSlice.scaleFactor,
      cordMaxValue: cordMaxValue,
      // viewScale: viewScale,
    );
    await _groupPlotMatrix!.init(legendMap);

    canvasController
      ..legendMap = legendMap
      ..isSpatial = isValidSpatial
      ..maxUserScale = _groupPlotMatrix!.maxScale!
      ..pointSize = _dotSize;

    _featurePlotMatrix?.clear();
    _featurePlotMatrix = null;
    features?.clear();
    features = null;
    _plotPainter = CellPlotChartPainter(
      controller: this.canvasController,
      matrixData: this.groupDataMatrix!,
      genePlotData: this.featureDataMatrix,
      maxScale: this.groupDataMatrix!.maxScale!,
      scale: this.groupDataMatrix!.scale,
      // plotImage: logic.backgroundImage,
    );
    _scatterFrontController
      ..isSpatial = isValidSpatial
      ..maxScale = groupDataMatrix!.maxScale!
      ..pointSize = _dotSize
      ..tapedCluster = null
      ..selectedPoints = null;
    _scatterFontPainter = PointAxisPainter(
      scale: groupDataMatrix!.scale,
      xAxisRect: Rect.fromLTWH(0, canvasSize!.height - 30, canvasSize!.width, 30),
      yAxisRect: Rect.fromLTWH(0, 0, 30, canvasSize!.height),
      //这里xy坐标在canvas外部
      controller: _scatterFrontController,
      primaryColor: Get.theme.primaryColor,
    );
    updateCords();
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

  void setSize(Size viewportSize, {bool splitMode = false}) {
    _viewportSize = viewportSize;
    // _canvasSize = Size.square(viewportSize.shortestSide);
    if (spatial != null && spatial!.currentSlice.hasSize) {
      _canvasSize = spatial!.currentSlice.toCanvasSize(viewportSize);
    } else {
      _canvasSize = Size.square(viewportSize.shortestSide);
    }
    // _canvasSize = splitMode ? Size.square(viewportSize.longestSide) : Size.square(viewportSize.shortestSide);
    _groupPlotMatrix?.changeViewSize(LRect.LTWH(0, 0, _canvasSize!.width, _canvasSize!.height));
    _featurePlotMatrix?.changeViewSize(_groupPlotMatrix!.viewRect);
    // _densityPlot?.setViewRect(_groupPlotMatrix!.viewRect, _groupPlotMatrix!.scale);

    _setInitialMatrix();
    updateCords();
  }

  double get initialCanvasScale => _viewportSize!.shortestSide < 900 ? .45 : .8;

  void _setInitialMatrix() {
    if (_viewportSize == null) return;
    double _scale = initialCanvasScale;
    Size _scaledCanvas = _canvasSize! * initialCanvasScale;
    // Size __containerSize = _splitMode ? Size(_containerSize!.width / 2, _containerSize!.height) : _containerSize!;

    _transformationController.value = Matrix4.identity()
      ..scale(_scale, _scale, _scale)
      ..translate((_viewportSize!.width - _scaledCanvas.width) / 2 / _scale, (_viewportSize!.height - _scaledCanvas.height) / 2 / _scale);
  }

  void clearFeatureMatrix() {
    _featurePlotMatrix?.clear();
    _featurePlotMatrix = null;
    features?.clear();
    features = null;
    _plotPainter!.genePlotData = null;
    updateCords();
  }

  void clearSelection() {
    groupDataMatrix?.clearSelectedCells();
    scatterFrontController.clear(selectedPoints: groupDataMatrix?.selectedPoints);
    canvasController.update();
  }

  void changeSelection(DataCategory cat) {
    if (_featurePlotMatrix != null) {
      _featurePlotMatrix!.changeSelection(cat);
    } else {
      _groupPlotMatrix!.changeSelection(cat);
    }
    canvasController.update();
  }

  void showLinkedCluster(String? group) {
    ScatterLabel? label = groupLabelMap?[group]; //.transform(transformationController.value);

    if (null != label)
      _scatterFrontController.update(
        linkedCluster: null == group ? null : ScatterLabel(group, label.position),
        tapedClusterColor: null == group ? null : canvasController.legendMap![group]?.color,
      );
  }

  void setFeatureMatrix(List featureCords, List<String> features) {
    LegendColor legendColor = _featurePlotMatrix?.legendColor ?? expressionLegendColors.first;
    _featurePlotMatrix = GenePlotMatrix(
      genePlotData: featureCords,
      domainRange: LRect.LTRB(0, 0, DensityGroupPlotMatrix.MAX_DOMAIN.toDouble(), DensityGroupPlotMatrix.MAX_DOMAIN.toDouble()),
      viewRect: LRect.LTWH(0, 0, canvasSize!.width, canvasSize!.height),
      legendColor: legendColor,
      domainScale: _groupPlotMatrix!.domainScale,
      domainScaleY: _groupPlotMatrix!.domainScaleY,
      isSpatial: spatial != null,
    );
    _plotPainter!.genePlotData = _featurePlotMatrix;
    this.features = features;
    updateCords();
  }

  void selectionUpdate(Rect sectionRect, List<Offset> pathPoints) {
    _selectRect = sectionRect;
    var scenePoint = _transformationController.toScene(pathPoints.last);
    _viewportPathPoints.add(scenePoint);
    Path path = Path()..addPolygon(pathPoints, false);
    _scatterFrontController.update(
      matrix: _transformationController.value,
      selectedRect: _selectRect,
      drawingPath: path,
    );
  }

  /// 手工选中只操作groupMatrix， 不操作featureMatrix
  void onSelectionEnd() {
    // _scatterFrontController.update(selectedRect: _selectRect);
    // _plotDrawState.update(visible: true, loading: true, msg: 'Finding target cell');
    // update(['msg-layer']);

    var path = Path()..addPolygon(_viewportPathPoints, true);
    groupDataMatrix?.findCellByPath(_transformationController.value, path);
    // _plotDrawState.update(visible: false);
    // update(['msg-layer']);

    _scatterFrontController.update(
      matrix: _transformationController.value,
      selectedPoints: groupDataMatrix?.selectedPoints,
      maxScale: _canvasController.maxUserScale,
      pointSize: _canvasController.pointSize,
      drawingPath: null,
    );
    _viewportPathPoints.clear();

    // CellDataTableLogic.safe()?.setSelectedFeature(groupDataMatrix?.selectedCells);
  }

  void pointHover(PointerHoverEvent event) {
    _hoverPointNotifier.value = event.localPosition;
    // var position = event.localPosition;
    // _scatterFrontController.update(cursor: position, tapedCluster: null); //这里不要更新matrix，否则会出现漂移现象；
  }

  void findTargetCluster(Offset position) {
    var scenePosition = _transformationController.toScene(position);

    var result = _groupPlotMatrix?.find(Point(scenePosition.dx, scenePosition.dy), _transformationController.value, _canvasController.currentPointSize);
    var cluster = result == null ? null : 'Group: ${result[0]}\n${result[2][0]}';
    if (cluster != null) {
      if (null != _featurePlotMatrix) {
        List? feature = _featurePlotMatrix?.searchInCords(scenePosition, _canvasController.currentPointSize);
        cluster += '\nvalue: ${feature?[1] ?? 0}';
      }
    }

    if (_tapCluster != cluster) {
      _tapCluster = cluster;
    }
    _scatterFrontController.update(
      matrix: _transformationController.value,
      tapedCluster: _tapCluster,
      cursor: position,
      tapedClusterColor: result != null ? canvasController.legendMap![result[0]]?.color : null,
      selectedRect: _selectRect,
    );
  }

  void onTap(Offset position) {
    // _selectRect = null;
  }

  void setMaxDrawCount(int count) {
    canvasController.update(maxDrawCount: count);
  }

  void setPointSize(double size) {
    _dotSize = size;
    canvasController.update(pointSize: size);
    scatterFrontController.update(pointSize: size);
  }

  void setOpacity(double opacity) {
    _pointOpacity = opacity;
    canvasController.update(pointOpacity: opacity);
  }

  void interactionStart(ScaleStartDetails details) {
    if (groupDataMatrix == null) return;
    var _rect = groupDataMatrix!.viewRect;
    var rect = Rect.fromLTRB(_rect.left, _rect.top, _rect.right, _rect.bottom);
    _targetRectStart = rect.translate(-rect.left, -rect.top).transform(_transformationController.value);
    _interactionStart = details.localFocalPoint;
    _hoverPointNotifier.value = details.localFocalPoint;
  }

  void onInteractionUpdate(ScaleUpdateDetails details) {
    // if (_selectionMode && details.scale != 1.0) return;
    var offset = details.localFocalPoint;
    var _point = offset;
    _hoverPointNotifier.value = _point;
    interacting = true;
    // _interactionStart = offset;
    updateCords(scale: details.scale, touching: true);
  }

  void onInteractionEnd(ScaleEndDetails details) {
    // if (_selectionMode) return;
    interacting = false;
    updateCords();
    // _debounce!.run(() {
    //   cachePlotImage();
    // }, milliseconds: 800);
  }

  /// reset plot to initial state
  void reset() {
    resetState();
    updateCords();
  }

  void resetState() {
    _featurePlotMatrix?.clear();
    _featurePlotMatrix = null;
    features?.clear();
    features = null;
    _plotPainter?.genePlotData = null;
    _setInitialMatrix();
  }

  void onColorSchemaChange(LegendColor value) {
    if (null != _featurePlotMatrix) {
      _featurePlotMatrix!.changeLegends(value);
    } else {
      // _groupPlotMatrix!.changeLegends(value);
    }
    _canvasController.update();
  }

  String get info {
    return featureDataMatrix != null
        ? '${features} ${featureDataMatrix?.cellCount} cells (${(featureDataMatrix!.cellCount * 100 / groupDataMatrix!.cellCount).toStringAsFixed(2)}%)'
        : '${groupDataMatrix?.cellCount} cells';
  }

  /// scale: interact zoom scale
  void updateCords({double scale = 1.1, bool touching = false}) {
    // if (groupDataMatrix == null) return;
    CellScatterChartLogic? logic = CellScatterChartLogic.safe(this.tag);
    logic?.update(['label-layer']);

    // if (!touching) {
    //   _plotDrawState.update(visible: true, loading: false, msg: 'Drawing...');
    //   logic.update(['msg-layer']);
    //
    //   _debounce!.run(() {
    //     _plotDrawState.update(visible: false);
    //     logic.update(['msg-layer']);
    //   }, milliseconds: 1200);
    // }
    canvasController.update(interacting: touching, matrix4: transformationController.value, isSpatial: isValidSpatial);
    scatterFrontController.update(
      tapedCluster: _tapCluster,
      selectedRect: _selectRect,
      showAxis: logic?.showAxis,
      cursor: _hoverPointNotifier.value,
      matrix: transformationController.value,
      selectedPoints: groupDataMatrix?.selectedPoints,
    );
  }

  void clear() {
    error = null;
    _plotType = null;
    _groupPlotMatrix?.dispose();
    _groupPlotMatrix = null;
    _featurePlotMatrix?.clear();
    _featurePlotMatrix = null;
    _plotPainter?.genePlotData = null;
    features?.clear();
    features = null;
    spatial = null;
    _spatialBg = null;
  }
}
