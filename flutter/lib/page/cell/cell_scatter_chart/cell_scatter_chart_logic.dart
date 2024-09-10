import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:dartx/dartx.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/cell/data_category.dart';
import 'package:flutter_smart_genome/cell/point_data_matrix.dart';
import 'package:flutter_smart_genome/components/setting_config_widget.dart';
import 'package:flutter_smart_genome/extensions/d4_extension.dart';
import 'package:flutter_smart_genome/network/core/http_error.dart';
import 'package:flutter_smart_genome/network/http_response.dart';
import 'package:flutter_smart_genome/page/cell/cell_data_table/cell_data_table_logic.dart';
import 'package:flutter_smart_genome/page/cell/cell_page/cell_layers.dart';
import 'package:flutter_smart_genome/page/cell/cell_page/cell_page_logic.dart';
import 'package:flutter_smart_genome/page/cell/cell_scatter_chart/feature_history_item.dart';
import 'package:flutter_smart_genome/page/cell/cell_scatter_chart/legend_colors.dart';
import 'package:flutter_smart_genome/page/cell/cell_scatter_chart/plot_states.dart';
import 'package:flutter_smart_genome/page/cell/spatial/rbg_image.dart' as rgbImg;
import 'package:flutter_smart_genome/service/sgs_app_service.dart';
import 'package:flutter_smart_genome/service/sgs_config_service.dart';
import 'package:flutter_smart_genome/service/single_cell_service.dart';
import 'package:flutter_smart_genome/util/debouncer.dart';
import 'package:flutter_smart_genome/util/logger.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:flutter_smart_genome/widget/quick_data_grid/quick_data_grid.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/base/types.dart';
import 'package:flutter_smart_genome/widget/track/cell_expression/cell_exp_logic.dart';
import 'package:flutter_smart_genome/widget/upload/platform_entry.dart';
import 'package:get/get.dart';
import 'cell_scatter_chart_state.dart';

class CellScatterChartLogic extends GetxController {
  final state = CellScatterChartState(tag: 'plot1');

  CancelToken? _cordFetchCancelToken;
  CancelToken? _featureFetchCancelToken;

  final double AXIS_WIDTH = 0;

  copyFrom(CellScatterChartLogic logic) {
    changeMatrix(mod: logic.state.mod!, plotType: logic.state.plotType, group: logic.currentGroup, legendMap: logic.legendMap);
  }

  bool get isEmpty => state.groupDataMatrix == null;

  bool _selectionMode = false;
  Debounce? _debounce;

  // GroupPlotMatrix _groupPlotMatrix;
  // GroupPlotMatrix get groupDataMatrix => _groupPlotMatrix;

  @Deprecated('use DensityGroupPlotMatrix instead')
  DensityCords<List>? _dataMatrix;

  @Deprecated('use DensityGroupPlotMatrix instead')
  DensityCords<List>? get dataMatrix => _dataMatrix;

  GlobalKey _secondRepaintBoundaryKey = GlobalKey();

  GlobalKey get secondRepaintBoundaryKey => _secondRepaintBoundaryKey;

  ui.Image? _backgroundImage;

  ui.Image? get backgroundImage => _backgroundImage;

  String? _currentGroup;

  String? get currentGroup => _currentGroup;

  bool get isCurrentGroupCategory => state.mod?.isCategory(_currentGroup!) ?? false;

  bool get isCartesianData => state.mod?.isCartesian(_currentGroup) ?? false;

  Map<String, List> get groupMap => state.mod?.groupMap ?? {};

  Map<String, List> get categories => state.mod?.categories ?? {};

  List<FeatureHistoryItem> featureHistory = [];

  late LegendColor _legendColor;
  late LegendColor _featureLegendColor;

  LegendColor get legendColor => _legendColor;

  LegendColor get featureLegendColor => _featureLegendColor;

  List<String> get currentClusters {
    List list = groupMap[_currentGroup]!;
    return list.map((e) => '$e').toList();
  }

  void set currentClusters(List<String> clusters) {
    state.mod!.setGroupClusters(_currentGroup!, clusters);
  }

  // Spatial? _spatial;

  void setDotSize(double size) {
    state.setPointSize(size);
  }

  void setPointOpacity(double opacity) {
    state.setOpacity(opacity);
  }

  void setMaxDrawCount(int count) {
    state.setMaxDrawCount(count);
  }

  double _backgroundOpacity = 1.0;

  void setBackgroundOpacity(double opacity) {
    _backgroundOpacity = opacity;
    update(['label-layer']);
  }

  void changeMatrix({required MatrixBean mod, String? plotType, String? group, Map<String, DataCategory>? legendMap}) {
    init(mod: mod, plotType: plotType, group: group, legendMap: legendMap);
    if (state.viewportSize != null) {
      fetchData();
    }
  }

  void init({required MatrixBean mod, String? plotType, String? group, Map<String, DataCategory>? legendMap}) {
    clear();
    reset();

    state.mod = mod;
    state.plotType = plotType ?? mod.firstPlot;

    var cats = mod.categories.keys.toList();
    _currentGroup = group ?? (cats.length > 0 ? _getDefaultGroup(cats) : _getDefaultGroup(mod.groups));

    if (plotType == Spatial.SPATIAL_PLOT) {
      state.spatial = mod.hasSpatials ? mod.spatials!.first : null;
    }

    var colors = legendMap?.values.map((e) => e.color).toList();
    initLegends(colors: colors);
    if (mod.hasSpatials) {
      Future.wait(mod.spatials!.map(cacheSliceImage)).then((v) {});
    }
  }

  String _getDefaultGroup(List cats) {
    return cats.sorted().firstOrNullWhere((f) => '$f'.toLowerCase().contains('cluster')) ?? cats.first;
  }

  double _labelSize = 14;

  double get labelSize => _labelSize;

  double get backgroundOpacity => _backgroundOpacity;

  Uint8List? _plotImageCache;

  Uint8List? get plotImageCache => _plotImageCache;

  bool _showLabel = false;

  bool get showLabel => _showLabel;

  Duration finishDuration = Duration(milliseconds: 800);

  void setShowLabel(bool s) {
    _showLabel = s;
    update(['label-layer']);
  }

  void changeGroup(String group) {
    _currentGroup = group;
    initLegends();
    fetchData();
  }

  void updatePlotType(String? plotType, {Spatial? spatial}) {
    state.resetState();
    state.plotType = plotType;
    var matrix = state.mod;
    if (plotType == Spatial.SPATIAL_PLOT) {
      if (spatial != null) {
        state.spatial = spatial;
      } else if (matrix!.hasSpatials && !matrix.spatials!.contains(state.spatial)) {
        state.spatial = matrix.spatials!.first;
      }
      // state.canvasController.pointSize = 8;
    } else {
      state.spatial = null;
      state.spatialBg = null;
    }
  }

  Map<String, DataCategory>? _legendMap;

  void changeLegends(LegendColor legendColor) {
    _legendColor = legendColor;
    if (_legendMap == null) return;

    List<Color> colors = generateColors(_legendMap!.length, legendColor.interpolate);
    int i = 0;
    _legendMap?.forEach((key, cat) {
      cat.color = colors[i++];
    });
  }

  void initLegends({List<Color>? colors}) {
    var categories = currentClusters;
    List<Color> _colors = ((colors?.length ?? 0) == categories.length) ? colors! : generateColors(categories.length, _legendColor.interpolate);
    var _clusters = List.generate(_colors.length, (i) => DataCategory(name: categories[i], value: categories[i], color: _colors[i], count: 0));
    _legendMap = _clusters.asMap().map((key, category) => MapEntry(category.value, category));
  }

  void setSelectionMode(bool selectionMode) {
    _selectionMode = selectionMode;
    update(['scatter-chart-root']);
  }

  bool get isSelectionMode => _selectionMode;

  bool _showAxis = false;

  bool get showAxis => _showAxis;

  void toggleShowAxis(bool? checked) {
    _showAxis = checked ?? !_showAxis;
    update(['scatter-chart-root']);
  }

  double _dataTableHeight = 300;

  double get dataTableHeight => _dataTableHeight;

  void saveDataTableHeight(double height) {
    _dataTableHeight = height;
  }

  // late Size _containerSize;

  Map<String, Color> get categoryLegendColorMap => _legendMap!.map<String, Color>((key, le) => MapEntry(key, le.color));

  Map<String, DataCategory> get legendMap => state.featureDataMatrix?.legendMap ?? _legendMap!;

  Map<String, Color> get legendColorMap => legendMap.map<String, Color>((key, le) => MapEntry(key, le.color));

  List<DataCategory> get legends => state.featureDataMatrix?.legends ?? _legendMap?.values.toList() ?? [];

  List<DataCategory> get noneZeroLegends => legends.where((l) => (l.count ?? 0) > 0).toList();

  // LegendColor? get legendColor => state.featureDataMatrix?.legendColor;

  // Map<String, Color> get colorMap => state.groupDataMatrix!.legendMap!.map((key, value) => MapEntry(key, value.drawColor));

  late PlotDrawState _plotDrawState;

  PlotDrawState get plotDrawState => _plotDrawState;

  late Debounce _resizeDebounce;

  String tag;

  CellScatterChartLogic({required this.tag}) {
    state.tag = tag;
    _debounce = Debounce(milliseconds: 30);
    _plotDrawState = PlotDrawState();
    _resizeDebounce = Debounce(milliseconds: 100);
    _legendColor = legendColors.first;
    _featureLegendColor = expressionLegendColors.first;
  }

  // void setContainerSize(Size size) {
  //   _containerSize = size;
  // }

  void debounceSetViewportSize(Size size) {
    _resizeDebounce.run(() {
      setViewportSize(size);
    }, milliseconds: 100);
  }

  void setViewportSize(Size viewportSize) async {
    // var viewSizeScale = state.size != null ? size.width / state.size!.width : 1.0;
    // await Future.delayed(Duration(milliseconds: 150));
    state.setSize(viewportSize, splitMode: CellPageLogic.safe()?.splitMode ?? false);
  }

  void changeSpatial(Spatial spatial) {
    // not spatial plot , ignore
    if (state.plotType == Spatial.SPATIAL_PLOT) {
      state.spatial = spatial;
      fetchData();
    }
  }

  /// from context menu
  void changeSlice(Spatial spatial) {
    state.resetState();
    state.spatial = spatial;
    fetchData();
  }

  loadFromFile(UploadFileItem cord, UploadFileItem meta, String group) async {
    state.loading = true;
    update();

    String currentCluster = group;

    int metaLineIndex = -1;
    List? metaColumns;
    Map<String, String> cellClusterMap = {};
    late int clusterIndex;
    // List<String> clusters = List.empty(growable: true);
    Set<String> _clusterSet = Set();

    void _parseMetaLine(String line) {
      metaLineIndex++;
      List arr = line.split(RegExp('	|\t'));
      if (metaLineIndex == 0) {
        metaColumns = arr;
        clusterIndex = metaColumns!.indexOf(currentCluster);
      } else {
        cellClusterMap[arr[0]] = arr[clusterIndex];
        _clusterSet.add(arr[clusterIndex]);
        // if (clusters.indexOf(arr[clusterIndex]) < 0) clusters.add(arr[clusterIndex]);
      }
    }

    meta
        .openStream()
        .transform(utf8.decoder) // Decode bytes to UTF-8.
        .transform(LineSplitter()) // Convert stream to individual lines.
        .listen(
      _parseMetaLine,
      onDone: () {
        List<String> clusters = <String>[..._clusterSet];
        CellPageLogic.safe()!.currentClusters = clusters;
        _parseCordFile(cord, cellClusterMap, clusters);
      },
      onError: (e) {
        print(e.toString());
      },
    );
  }

  void _parseCordFile(UploadFileItem cord, Map<String, String> cellClusterMap, List<String> clusters) {
    Map<String, List> groupedCords = Map.fromIterables(clusters, List.generate(clusters.length, (index) => List.empty(growable: true)));

    void _parseCordLine(String line) {
      List arr = line.split(RegExp('	|\t'));
      groupedCords[cellClusterMap[arr[0]]]?.add([arr[0], double.parse(arr[1]), double.parse(arr[2])]);
    }

    cord
        .openStream()
        .transform(utf8.decoder) // Decode bytes to UTF-8.
        .transform(LineSplitter()) // Convert stream to individual lines.
        .listen(
      _parseCordLine,
      onDone: () {
        state.loading = false;
        // print(groupedCords);
        // print(clusters);
        state.setData(groupedCords, clusters, legendMap);
        update();
      },
      onError: (e) {
        print(e.toString());
        state.error = HttpError(-1, e.toString());
        state.loading = false;
        update();
      },
    );
  }

  bool get loading => state.loading;

  HttpError? get error => state.error;

  CellPageLogic? get pageLogic => CellPageLogic.safe();

  String info() {
    return '${pageLogic?.track?.name ?? ''}, ${state.info}';
  }

  Future<bool> fetchData({bool refresh = false}) async {
    SiteItem site = SgsAppService.get()!.site!;

    _cordFetchCancelToken?.cancel('user cancel');
    await Future.delayed(Duration(milliseconds: 100));

    // if (state.isInvalidSpatial) {
    //   state.loading = false;
    //   state.error = HttpError(-1, 'No spatial slice for mod  ${state.mod?.name}');
    //   update(['scatter-chart-root']);
    //   return false;
    // }

    _cordFetchCancelToken = CancelToken();

    if (state.isValidSpatial) await loadSpatialBackgroundImage(state);
    state.loading = true;
    state.finishLoading = false;
    state.error = null;
    state.loadingMessage = '   Loading cords...';
    update(['scatter-chart-root']);

    var fetch = state.isValidSpatial
        ? loadSpatialPlotData(
            host: site.url,
            track: pageLogic!.track!,
            matrixId: state.mod!.id,
            groupName: _currentGroup!,
            spatialKey: state.spatial!.key,
            cancelToken: _cordFetchCancelToken,
            refresh: refresh,
            // onReceiveProgress: _cordLoadProgress,
          )
        : loadCellPlotData(
            host: site.url,
            track: pageLogic!.track!,
            groupName: _currentGroup!,
            plotType: state.plotType!,
            matrixId: state.mod!.id,
            refresh: refresh,
            cancelToken: _cordFetchCancelToken,
            // onReceiveProgress: _cordLoadProgress,
          );
    var resp = await fetch.catchError((e) => HttpResponseBean.error(e));
    // state.loading = false;
    if (resp.error?.type == DioExceptionType.cancel) {
      return false;
    }
    state.error = resp.success ? null : resp.error;
    if (resp.success) {
      Map _data = resp.body;
      if (pageLogic!.isCartesianData || _data['scope'] != null) {
        // cartesian data, set cluster manually,
        List scope = _data['scope'];
        List plots = _data['coord'];

        List<String> _clusters = pageLogic!.currentClusters;
        double avg = state.mod!.getGroupAvg(_currentGroup!);

        Map<String, List> _largeDataHandle(List args) {
          var [List plots, double avg, List<String> _clusters] = args;
          // Map<String, List> _largeDataHandle(List plots, double avg, List<String> _clusters) {
          Map<String, List> groupedCord = Map.fromIterables(_clusters, List.generate(_clusters.length, (index) => []));
          int rangeIndex;
          String __cluster;
          for (List item in plots) {
            // cell, value , x, y
            rangeIndex = (item[1] - scope[0]) ~/ avg;
            __cluster = _clusters[rangeIndex.clamp(0, _clusters.length - 1)];
            groupedCord[__cluster]!.add([item[0], item[2], item[3], item[1]]);
          }
          return groupedCord;
        }

        // workerManager.execute<Map<String, List>>(() => _largeDataHandle(plots, avg, _clusters)).then((groupedCord) {
        //   state.setData(groupedCord, _clusters, legendMap);
        // });

        Map<String, List> groupedCord = await compute<List, Map<String, List>>(_largeDataHandle, [plots, avg, _clusters]);

        // if (state.canvasSize == null) state.setSize(this.state.canvasSize!);
        state.finishLoading = true;
        update(['scatter-chart-root']);
        await Future.delayed(finishDuration);

        state.setData(groupedCord, _clusters, legendMap);
      } else {
        state.finishLoading = true;
        update(['scatter-chart-root']);
        await Future.delayed(finishDuration);

        List<String> clusters = _data.keys.map((e) => '$e').toList();
        pageLogic!.currentClusters = clusters;
        // if (state.canvasSize == null) state.setSize(this.state.canvasSize!);
        state.setData(resp.body, clusters, legendMap);
      }
      CellPageLogic.safe()?.update([CellLayer.legendLayer]);
      // update();
    } else {
      state.loading = false;
      // if (clearLabel) _densityPlot = null;
      // update();
    }

    update(['scatter-chart-root']);
    return resp.success;
  }

  void _cordLoadProgress(int a, int b) {
    // state.loadingMessage = 'Loading cords... ${(a / b * 100 / 2.25).toInt()}%\n${a} / ${b}';
    // _debounce?.run(() {
    //   update(['scatter-chart-root']);
    // }, milliseconds: 100);
  }

  Map<String, Uint8List> _cacheSpatialImage = {};

  loadSpatialBackgroundImage(CellScatterChartState state) async {
    SpatialSlice safeSlice = state.spatial!.currentSlice;
    if (!safeSlice.size.isEmpty) {
      update(['label-layer']);
      return;
    }
    await cacheSliceImage(state.spatial!);
    update(['label-layer']);
  }

  /// cache slice image
  Future<bool> cacheSliceImage(Spatial spatial) async {
    final safeSlice = spatial.currentSlice;
    int fileNameHash = '${state.mod!.id}-${spatial.key}-${safeSlice.resolution}'.hashCode;

    if (safeSlice.hasSize) {
      return true;
    }

    if (kIsWeb) return _cacheSliceImageWeb(spatial);

    var image;
    String? imageUrl = safeSlice.image ?? '';
    var extStart = imageUrl.lastIndexOf('.');
    String ext = extStart >= 0 ? imageUrl.substring(extStart) : '.jpg';
    String filePath = '${SgsConfigService.get()!.applicationDocumentsPath}/sc/spatial/${fileNameHash}${ext}';

    if (File(filePath).existsSync()) {
      image = await rgbImg.fromFile(filePath).catchError((e, s) {
        logger.e(e);
        logger.e(s);
        showToast(text: 'Spatial image ${spatial.key} ${safeSlice.resolution} parse error!\n$e');
        return null;
      });
    } else {
      var resp = await download(savePath: filePath, url: '${SgsAppService.get()!.staticBaseUrl}${imageUrl}');
      if (resp.success) {
        image = await rgbImg.fromFile(filePath).catchError((e, s) {
          logger.e(e);
          logger.e(s);
          showToast(text: 'Spatial image ${spatial.key} ${safeSlice.resolution} parse error!\n$e');
          return null;
        });
      } else {
        logger.e(resp.error);
      }
    }
    if (image != null) {
      Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
      safeSlice.size = imageSize;
      // logger.i(safeSlice.size);
      return true;
    }
    return false;
  }

  Future<bool> _cacheSliceImageWeb(Spatial spatial) async {
    final safeSlice = spatial.currentSlice;
    String? safeUrl = safeSlice.image;
    var imageUrl = '${SgsAppService.get()!.staticBaseUrl}${safeUrl}';
    var response = await getStream(url: imageUrl);
    var image;
    if (response.success) {
      Uint8List bytes = response.body;
      image = await rgbImg.fromImage(bytes);
      if (image != null) {
        Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
        safeSlice.size = imageSize;
        return true;
      }
    }
    return false;
  }

  fetchFeatureExpressionFromGff(String gene) async {
    var site = SgsAppService.get()!.site;
    var resp = await searchGeneByKeyword(
      host: site!.url,
      track: CellPageLogic.safe()!.track!,
      matrixId: CellPageLogic.safe()!.currentChartLogic.state.mod!.id,
      keyword: gene,
    );
    if (resp.success) {
      Map body = resp.body;
      List _features = body['match_features'] ?? {};
      if (_features.length > 0) {
        Map first = _features.first;
        loadSingleFeaturePlotData([first.entries.first.value]);
      } else {
        showErrorToast(text: 'feature ${gene} not found in sc!');
      }
    } else {
      showErrorToast(text: 'search ${gene} error in sc!');
    }
  }

  /// 单个feature 的表达情况
  loadSingleFeaturePlotData(List<String> features) async {
    state.loading = true;
    update(['scatter-chart-root']);
    await Future.wait([
      _loadFeatureExpressionPlotData(features, state),
    ]);
    update(['scatter-chart-root']);
    CellPageLogic.safe()!.update([CellLayer.legendLayer]);
  }

  void cacheFeatureHistory() {}

  Future _loadFeatureExpressionPlotData(List<String> features, CellScatterChartState state) async {
    final pageLogic = CellPageLogic.safe();
    SiteItem site = SgsAppService.get()!.site!;
    state.finishLoading = false;
    state.loadingMessage = 'Loading cords...';
    _featureFetchCancelToken?.cancel();
    await Future.delayed(Duration(milliseconds: 100));

    _featureFetchCancelToken = CancelToken();
    var fetch = state.isValidSpatial
        ? loadSpatialFeatureExpressions(
            track: pageLogic!.track!,
            matrixId: state.mod!.id,
            spatial: state.spatial!.key,
            features: features,
            cancelToken: _featureFetchCancelToken,
          )
        : loadFeaturePlotData(
            host: site.url,
            track: pageLogic!.track!,
            features: features,
            plotType: state.plotType!,
            matrixId: state.mod!.id,
            cancelToken: _featureFetchCancelToken,
          );
    var resp = await fetch;

    if (resp.error?.type == DioExceptionType.cancel) {
      state.loading = false;
      return;
    }
    state.error = resp.success ? null : resp.error;
    if (resp.success) {
      state.finishLoading = true;
      update(['scatter-chart-root']);
      await Future.delayed(finishDuration);

      state.loading = false;
      state.setFeatureMatrix(resp.body, features);

      if (featureHistory.where((e) => e.featuresHashCode == features.join(',').hashCode).length <= 0)
        featureHistory.add(FeatureHistoryItem(
          features: [...features],
          plotType: state.plotType!,
          modId: state.mod!.id,
          group: currentGroup!,
          spatial: state.spatial,
          color: state.featureDataMatrix!.legendColor.end,
        ));
      CellDataTableLogic.safe(tag)?.updateFeatureExpressionList();
    } else {
      showToast(text: resp.error!.message);
      // state.clearFeatureMatrix();
      // if(splitMode) secondaryState.clearFeatureMatrix();
    }
  }

  void zoomTest() {
    state.viewPortKey.currentState?.zoomToRect(Rect.fromLTWH(10, 50, 100, 100));
  }

  // int get selectedFeatureCount => (state.groupDataMatrix?.selectedPoints?.length ?? 0) ~/ 2;

  void interactionStart(ScaleStartDetails details) {
    state.interactionStart(details);
  }

  void selectionUpdate(Rect sectionRect, List<Offset> pathPoints) {
    state.selectionUpdate(sectionRect, pathPoints);
  }

  void onSelectionEnd() {
    state.onSelectionEnd();
    CellDataTableLogic.safe(tag)?.setSelectedFeature(allSelectedCells);
  }

  void pointHover(PointerHoverEvent event) {
    state.pointHover(event);
    if (state.groupDataMatrix != null && state.groupDataMatrix!.cellCount <= 60000) {
      state.findTargetCluster(event.localPosition);
      if (!showLabel && CellPageLogic.safe()!.splitMode) {
        var another = CellPageLogic.safe()!.chartLogic(tag == 'chart1' ? 'chart2' : 'chart1');
        another.state.showLinkedCluster(state.scatterFrontController.tapedCluster);
      }
    }

    // state.pointHover(event);
    // if (splitMode) secondaryState.pointHover(event);
  }

  void onPointerDown(PointerDownEvent event) {
    CellPageLogic.safe()!.updateCurrentChart(this.tag);
  }

  void onTap(PointerHoverEvent event) {
    // _selectRect = null;\
    var position = event.localPosition;

    if (state.groupDataMatrix != null && state.groupDataMatrix!.cellCount > 60000) {
      state.findTargetCluster(event.localPosition);
      if (!showLabel && CellPageLogic.safe()!.splitMode) {
        var another = CellPageLogic.safe()!.chartLogic(tag == CellPageLogic.CHART_TAG_1 ? CellPageLogic.CHART_TAG_2 : CellPageLogic.CHART_TAG_1);
        another.state.showLinkedCluster(state.scatterFrontController.tapedCluster);
      }
    }

    state.onTap(position);
  }

  void onInteractionUpdate(ScaleUpdateDetails details) {
    state.onInteractionUpdate(details);
  }

  void onInteractionEnd(ScaleEndDetails details) {
    state.onInteractionEnd(details);
  }

  // void cachePlotImage() async {
  //   RenderRepaintBoundary? ro = _repaintBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
  //   if (ro == null) return;
  //   var image = await ro.toImage(pixelRatio: 1.0);
  //   ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  //   _plotImageCache = byteData!.buffer.asUint8List();
  // }

  void zoomIn() {
    state.viewPortKey.currentState?.zoomIn();
  }

  void zoomOut() {
    state.viewPortKey.currentState?.zoomOut();
  }

  @override
  void onReady() {
    super.onReady();
    final pageLogic = CellPageLogic.safe();
    if (pageLogic?.track != null) {
      // fetchData();
    }
  }

  @override
  void onClose() {
    _featureFetchCancelToken?.cancel('disposed!');
    _cordFetchCancelToken?.cancel('disposed!');
    _resizeDebounce.dispose();
    super.onClose();
  }

  static CellScatterChartLogic? safe(String tag) {
    if (Get.isRegistered<CellScatterChartLogic>(tag: tag)) {
      CellScatterChartLogic logic = Get.find<CellScatterChartLogic>(tag: tag);
      return logic;
    }
    return null;
  }

  void clear() {
    featureHistory.clear();
    state.clear();
  }

  void reset() {
    state.reset();
  }

  /// user manual circled and from legend selected
  Map<String, List> get allSelectedCells {
    var selectedCat = legendMap!.values.filter((e) => e.focused).map((e) => e.name);
    return {
      ...(state.groupDataMatrix?.selectedCells ?? {}),
      ...((state.featureDataMatrix?.groupedData ?? state.groupDataMatrix?.groupData)?.filter((en) => selectedCat.contains(en.key)) ?? {}),
    };
  }

  bool get hasSelectedCells {
    return (state.groupDataMatrix?.selectedCells?.length ?? 0) > 0 || legendMap.any((k, v) => v.focused);
  }

  void _clearSelection() {
    state.clearSelection();
    // CellPageLogic.safe()!.updateFontLayer();
    // CellDataTableLogic.safe(tag)?.setSelectedFeature(state.groupDataMatrix?.selectedCells);
    CellDataTableLogic.safe(tag)?.setSelectedFeature(allSelectedCells);
  }

  void clearSelection() {
    for (var e in legendMap.entries) {
      e.value.focused = false;
    }
    CellPageLogic.safe()?.update([CellLayer.legendLayer]);
    _clearSelection();
  }

  void onColorSchemaChange(LegendColor legendColor) {
    if (state.featureDataMatrix != null) {
      _featureLegendColor = legendColor;
      state.featureDataMatrix!.changeLegends(legendColor);
      state.canvasController.update();
      featureHistory.forEach((e) => e.color = legendColor.end);
      update(['label-layer']);
      CellPageLogic.safe()!.update([CellLayer.dataTableLayer]);
      return;
    }

    changeLegends(legendColor);
    state.canvasController.update(legendMap: legendMap);
    update(['label-layer']);
  }

  void onLegendSelectionChange(DataCategory? cat) {
    if (cat == null) {
      _clearSelection();
    } else {
      state.changeSelection(cat);
      CellDataTableLogic.safe(tag)?.setSelectedFeature(allSelectedCells);
    }
  }

  void onToggleLegend(DataCategory? cat) async {
    if (state.featureDataMatrix == null) {
      state.canvasController.update(legendMap: legendMap);
    } else {
      state.updateCords();
    }
    // state.updateCords();
  }

  void onColorChange(List<DataCategory> cats) {
    if (state.featureDataMatrix == null) {
      state.canvasController.update(legendMap: legendMap);
    } else {
      //feature color auto update by DataCategory just redraw
      state.updateCords();
    }
    CellExpLogic.safe(tag: pageLogic!.track!.id)?.onColorChange(cats);
  }

  /// label by change, reload data to calculate label position
  void onLabelByChange() async {
    final pageLogic = CellPageLogic.safe();
    String? labelByGroup = pageLogic!.labelByGroup;
    SiteItem site = SgsAppService.get()!.site!;

    var resp = await loadCellPlotData(
      host: site.url,
      track: pageLogic.track!,
      matrixId: state.mod!.id,
      groupName: labelByGroup!,
      plotType: state.plotType!,
      cancelToken: _cordFetchCancelToken,
    );

    if (resp.success) {
      // _densityPlot = DensityPlot(
      //   resp.body,
      //   viewRect: state.groupDataMatrix!.viewRect,
      //   valueScale: state.groupDataMatrix!.scale,
      //   domainScale: state.groupDataMatrix!.domainScale,
      // );
      update();
    }
  }

  void onContextMenuItemChange(SettingItem? parentItem, SettingItem item) {
    if (item.key == 'cursor-mode') {
      // CellPageLogic.safe()?.setSelectionMode(item.value == 'draw');
      setSelectionMode(item.value == 'draw');
    } else if (item.key == 'show-label') {
      this.setShowLabel(item.value);
    } else if (item.key == 'label-size') {
      _labelSize = item.value;
      update(['label-layer']);
    } else if (item.key == 'point-size') {
      state.setPointSize(item.value);
    } else if (item.key == 'slice-resolution') {
      state.spatial!.changeCurrentResolution(item.value);
      fetchData();
    } else if (item.key == 'fix-spatial-cord') {
      state.spatial?.currentSlice.cordScaleBy = item.value;
      fetchData();
    }
  }

  void onContextMenuItemTap(SettingItem item) {
    if (item.key == 'clear-selection') {
      clearSelection();
    } else if (item.key == 'sc-info') {
      _showInfoDialog();
    } else if (item.key == 'reset') {
      state.reset();
      update(['label-layer']);
      CellPageLogic.safe()!.updateFontLayer();
    } else if (item.key == 'export-image') {
      CellPageLogic.safe()!.saveImage();
    }
  }

  List<SettingItem> buildSettingItems() {
    return [
      SettingItem.checkGroup(
        title: 'Mode',
        key: 'cursor-mode',
        value: isSelectionMode ? 'draw' : 'hand',
        optionListType: OptionListType.row,
        prefix: Icon(Icons.gesture, size: 18),
        options: [
          OptionItem(
              'hand',
              'hand',
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Icon(Icons.pan_tool_rounded, size: 18),
              )),
          OptionItem(
              'draw',
              'draw',
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Icon(FontAwesome.pencil_square_o, size: 18),
              )),
        ],
      ),
      SettingItem.toggle(title: 'Show Label', key: 'show-label', value: showLabel, prefix: Icon(Icons.label_outline, size: 16)),
      SettingItem.range(title: 'Label Size', key: 'label-size', value: _labelSize, min: 6, max: 24, step: 1, prefix: Icon(FontAwesome.font, size: 16)),
      SettingItem.range(title: 'Point Size', key: 'point-size', value: state.canvasController.pointSize, min: 2, max: 16, step: 1, prefix: Icon(Icons.scatter_plot, size: 16)),
      SettingItem.button(title: 'Rest plot', key: 'reset', prefix: Icon(Icons.restore, size: 16)),
      if (hasSelectedCells) //
        SettingItem.button(title: 'Clear Selections', key: 'clear-selection', prefix: Icon(Icons.cleaning_services_rounded, size: 16)),
      if (state.isValidSpatial) ...[
        SettingItem.button(
          title: 'Spatial slice',
          key: 'slice',
          prefix: Icon(Icons.image, size: 16),
          suffix: Icon(Icons.arrow_forward_ios, size: 16),
          value: state.spatial!.key,
        ),
        SettingItem.checkGroup(
          key: 'fix-spatial-cord',
          title: 'Fix cord',
          prefix: Icon(Icons.auto_fix_normal, size: 16),
          value: state.spatial?.currentSlice.cordScaleBy,
          optionListType: OptionListType.row,
          options: SpatialCordScaleType.values.map<OptionItem>((e) => OptionItem(e.name, e)).toList(),
        ),
        SettingItem.checkGroup(
          key: 'slice-resolution',
          title: 'Resolution',
          prefix: Icon(Icons.image_aspect_ratio, size: 16),
          value: state.spatial!.currentSlice.resolution,
          optionListType: OptionListType.row,
          options: state.spatial!.slices.map<OptionItem>((e) => OptionItem(e.resolution, e.resolution)).toList(),
        ),
      ],
      SettingItem.button(title: 'Export Image', key: 'export-image', prefix: Icon(Icons.image, size: 16)),
      SettingItem.button(
        title: 'Info',
        key: 'sc-info',
        prefix: Icon(Icons.info, size: 16),
        suffix: Icon(Icons.arrow_forward_ios, size: 16),
      ),
    ];
  }

  void _showInfoDialog({bool secondary = false}) {
    showDialog(
      context: Get.context!,
      builder: (c) {
        var pageLogic = CellPageLogic.safe();
        List<Map> items = [
          {'name': 'Data Set', 'value': pageLogic!.track?.name},
          {'name': 'Mod', 'value': state.mod?.name},
          {'name': 'Plot', 'value': state.plotType},
          if (state.spatial != null) ...[
            {'name': 'Spatial', 'value': state.spatial?.key},
            {'name': 'hires scale factor', 'value': state.spatial!.hi?.scaleFactor},
            {'name': 'hires image', 'value': state.spatial!.hi?.sizeStr},
            {'name': 'low scale factor', 'value': state.spatial!.low?.scaleFactor},
            {'name': 'low image', 'value': state.spatial!.low?.sizeStr},
          ],
          {'name': 'Cell Count', 'value': state.groupDataMatrix?.cellCount},
        ];
        double height = (items.length + 1) * 36;
        return AlertDialog(
          title: Text('SC Data Info'),
          content: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 460, minWidth: 460, maxHeight: height, minHeight: height),
            child: QuickDataGrid(data: items, headers: ['name', 'value'], minWidth: 400, paginated: false, rowHeight: 36),
          ),
        );
      },
    );
  }
}
