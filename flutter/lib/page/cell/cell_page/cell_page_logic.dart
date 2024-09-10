import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/app_layout.dart';
import 'package:flutter_smart_genome/bloc/track_config/bloc.dart';
import 'package:flutter_smart_genome/cell/data_category.dart';
import 'package:flutter_smart_genome/page/cell/cell_data_table/cell_data_table_logic.dart';
import 'package:flutter_smart_genome/page/cell/cell_page/cell_layers.dart';
import 'package:flutter_smart_genome/page/cell/cell_scatter_chart/cell_scatter_chart_logic.dart';
import 'package:flutter_smart_genome/page/cell/cell_scatter_chart/legend_colors.dart';
import 'package:flutter_smart_genome/page/cell/cell_tool_bar/cell_track_selector_widget.dart';
import 'package:flutter_smart_genome/platform/platform_adapter.dart';
import 'package:flutter_smart_genome/service/sgs_app_service.dart';
import 'package:flutter_smart_genome/service/sgs_config_service.dart';
import 'package:flutter_smart_genome/util/file_util.dart';
import 'package:flutter_smart_genome/util/widget_util.dart';
import 'package:flutter_smart_genome/widget/basic/checkbox_list_view.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/cell_expression/cell_exp_logic.dart';
import 'package:flutter_smart_genome/widget/track/group_coverage/group_coverage_logic.dart';
import 'package:flutter_smart_genome/widget/upload/platform_entry.dart';
import 'package:get/get.dart';

class CellPageLogic extends GetxController {
  static final String CHART_TAG_1 = 'chart-tag-1';
  static final String CHART_TAG_2 = 'chart-tag-2';

  CellPageLogic() {
    _logic1 = Get.put(CellScatterChartLogic(tag: CHART_TAG_1), tag: CHART_TAG_1);
    _logic2 = Get.put(CellScatterChartLogic(tag: CHART_TAG_2), tag: CHART_TAG_2);
  }

  late CellScatterChartLogic _logic1;
  late CellScatterChartLogic _logic2;

  CellScatterChartLogic chartLogic(String tag) => tag == CHART_TAG_1 ? _logic1 : _logic2;

  CellScatterChartLogic getChartLogic(bool secondary) => secondary ? _logic2 : _logic1;

  GlobalKey _repaintBoundaryKey = GlobalKey();

  GlobalKey get chartRepaintBoundaryKey => _repaintBoundaryKey;

  bool splitMode = false;

  bool _allFontLayerHide = false;

  bool get allFontLayerHide => _allFontLayerHide;

  bool _showDataTable = false;

  bool get showDataTable => _showDataTable;

  bool _showLegend = true;

  bool get showLegend => _showLegend;

  bool _selectionMode = false;

  bool get isSelectionMode => _selectionMode;

  bool _searchFieldExpanded = false;

  bool get searchFieldExpanded => _searchFieldExpanded;

  void toggleSearchFieldExpanded() {
    _searchFieldExpanded = !_searchFieldExpanded;
    update([CellLayer.modeLayer]);
  }

  collapseSearchField() {
    _searchFieldExpanded = false;
    update([CellLayer.modeLayer]);
  }

  void setSelectionMode(bool selectionMode) {
    _selectionMode = selectionMode;
    update([CellLayer.controlBar]);
    _logic1.setSelectionMode(_selectionMode);
    _logic2.setSelectionMode(_selectionMode);
    // currentChartLogic.setSelectionMode(_selectionMode);
  }

  void toggleDataTable() {
    _showDataTable = !_showDataTable;
    update([CellLayer.dataTableLayer, CellLayer.controlBar]);
  }

  bool _screenshotMode = false;

  bool get screenshotMode => _screenshotMode;

  void setScreenshotMod(bool screenshot) {
    _screenshotMode = screenshot;
    updateFontLayer();
  }

  double _dataTableHeight = 300;

  double get dataTableHeight => _dataTableHeight;

  void saveDataTableHeight(double height) {
    _dataTableHeight = height;
  }

  bool _showLabel = false;

  bool get showLabel => _showLabel;

  void toggleLabel() {
    _showLabel = !_showLabel;
    update([CellLayer.controlBar]);
    _logic1.setShowLabel(_showLabel);
    _logic2.setShowLabel(_showLabel);
    // currentChartLogic.setShowLabel(_showLabel);
  }

  double _pointSize = 4.0;

  double get pointSize => _pointSize;

  void setPointSize(double v) {
    _pointSize = v;
    currentChartLogic.setDotSize(v);
  }

  double _opacity = 1.0;

  double get opacity => _opacity;

  void setOpacity(double v) {
    _opacity = opacity;
    currentChartLogic.setPointOpacity(v);
  }

  double _backgroundOpacity = 1.0;

  double get backgroundOpacity => _opacity;

  void setBackgroundOpacity(double opacity) {
    _backgroundOpacity = opacity;
    currentChartLogic.setBackgroundOpacity(opacity);
  }

  void zoomIn() {
    _logic1.zoomIn();
    _logic2.zoomIn();
    // currentChartLogic.zoomIn();
  }

  void zoomOut() {
    _logic1.zoomOut();
    _logic2.zoomOut();
    // currentChartLogic.zoomOut();
  }

  String _currentChartTag = CHART_TAG_1;

  String get currentChartTag => _currentChartTag;

  CellScatterChartLogic get currentChartLogic => currentChartTag == CHART_TAG_1 ? _logic1 : _logic2;

  void updateCurrentChart(String tag, {bool force = false}) {
    if (!splitMode && !force) return;
    _currentChartTag = tag;
    updateFontLayer();
    update([CellLayer.dataTableLayer]);
    // CellDataTableLogic.safe(currentChartTag)?.changeData();
  }

  int _maxPointCount = 200000;

  int get maxPointCount => _maxPointCount;

  void setMaxPointCount(double count) {
    _maxPointCount = count.toInt();
    currentChartLogic.setMaxDrawCount(_maxPointCount);
  }

  bool _loading = false;

  bool get loading => _loading;
  String? _error = null;

  String? get error => _error;

  UploadFileItem? metaFile, cordFile;

  Track? _track;

  Track? get track => _track;

  bool _nativeSource = false;

  bool get nativeSource => _nativeSource;
  List<MatrixBean> _nativeMatrixList = [];

  List get plotTypes => currentChartLogic.state.mod?.plots ?? [];

  List<String> get orderedGroupList => currentChartLogic.state.mod!.orderedGroupList;

  Map<String, List> get groupMap => currentChartLogic.groupMap;

  Map<String, List> get categories => currentChartLogic.categories;

  List<MatrixBean> get matrixList => nativeSource ? _nativeMatrixList : track?.matrixList ?? [];

  void set matrix(MatrixBean matrix) {
    _logic1.init(mod: matrix, plotType: matrix.plots.first);
  }

  bool get isCurrentGroupCategory => currentChartLogic.isCurrentGroupCategory;

  void changeGroup(String group, {String? trackId}) {
    if (trackId != null && trackId != track!.id) return;
    if (currentChartLogic.currentGroup == group) return;

    currentChartLogic.changeGroup(group);
    update([CellLayer.legendLayer]);

    CellExpLogic.safe(tag: track!.id!)?.groupObs.value = group;
    GroupCoverageLogic.safe(tag: track!.id!)?.groupObs.value = group;

    CellDataTableLogic.safe(currentChartTag)?.changeData();
  }

  bool get isCartesianData => currentChartLogic.isCartesianData;

  String? _labelByGroup;

  String? get labelByGroup => _labelByGroup;

  void set labelByGroup(String? group) => _labelByGroup = group;

  List<String> get currentClusters => currentChartLogic.currentClusters;

  void set currentClusters(List<String> clusters) {
    currentChartLogic.currentClusters = clusters;
  }

  String? _trackFilterKey;

  String? get trackFilterKey => _trackFilterKey;

  LegendColor get legendColor => _logic1.legendColor;

  LegendColor get featureLegendColor => _logic1.featureLegendColor;

  List<Track> get scTracks {
    List<Track> tracks = SgsAppService.get()!.scTracks;
    if (_trackFilterKey == null) return tracks;
    // var reg = _trackFilterKey!;
    // _trackFilterKey = _trackFilterKey!.replaceAll(spatialChars, '');

    var reg = RegExp.escape('${_trackFilterKey}');
    return tracks.where((t) => (t.scName!).isCaseInsensitiveContains(reg)).toList();
  }

  void clearFilter() {
    _trackFilterKey = null;
    update();
  }

  void filterTrack(String key) {
    _trackFilterKey = key.trim();
    update();
  }

  void changeTrack(Track? track) async {
    SgsAppService.get()?.session?.scId = track?.scId;
    if (track == null) {
      _loading = false;
      _error = null;
      _track = track;
      update();
      return;
    }

    _loading = false;
    _error = null;
    _nativeSource = false;
    bool reload = this._track != track;
    _track = track;
    splitMode = false;
    _currentChartTag = CHART_TAG_1;
    _searchFieldExpanded = false;
    var matrixList = track.matrixList ?? [];
    if (matrixList.length > 0) {
      changeMatrix(matrixList.first);
    } else {
      _error = 'No mod found in ${_track!.scName}';
    }
    update();

    Future.delayed(Duration(milliseconds: 100)).then((e) {
      CellTrackSelectorLogic.get()?.resetTracks();
    });
  }

  void updateStatus(bool loading, {String? error}) {
    _loading = loading;
    if (_loading) _track = null;
    _error = error;
    update();
  }

  ///
  /// change matrix
  ///
  void changeMatrix(MatrixBean? matrix) {
    currentChartLogic.changeMatrix(mod: matrix!);
    _searchFieldExpanded = false;
    update([CellLayer.modeLayer, CellLayer.dataTableLayer, CellLayer.legendLayer]);
    _cacheModSpatialImages(matrix);
    CellDataTableLogic.safe(currentChartTag)?.onChangeMatrix(matrix);
  }

  // when plot type change
  void changePlotType(String? type) {
    currentChartLogic.updatePlotType(type!);
    update([CellLayer.modeLayer]);
    currentChartLogic.fetchData();
  }

  void changeSpatial(Spatial spatial) {
    currentChartLogic.updatePlotType(Spatial.SPATIAL_PLOT, spatial: spatial);
    update([CellLayer.modeLayer]);
    currentChartLogic.fetchData();
  }

  void toggleSplitMod(bool split) {
    this.splitMode = split;
    update();
    if (split) {
      _logic2.copyFrom(_logic1);
      // CellDataTableLogic.safe(CHART_TAG_2)?.changeData();
      CellDataTableLogic.safe(CHART_TAG_2)?.onChangeMatrix(_logic1.state.mod!);
    } else {
      if (_currentChartTag != CHART_TAG_1) {
        // _currentChartTag = CHART_TAG_1;
        updateCurrentChart(CHART_TAG_1, force: true);
        // CellDataTableLogic.safe(CHART_TAG_1)?.changeData();
      }
    }
  }

  void updateFontLayer() {
    update([
      CellLayer.modeLayer,
      CellLayer.msgLayer,
      CellLayer.controlBar,
      CellLayer.legendLayer,
    ]);
  }

  void onNativeFileSelected(UploadFileItem? cordFile, UploadFileItem metaFile) async {
    this.cordFile = cordFile;
    this.metaFile = metaFile;
    update();

    parseFile();
  }

  void parseFile() async {
    _nativeSource = true;

    List<String> firstLine = await FileUtil.readFileLines(metaFile!.path);
    List<String> clusters = [];
    var result = await Get.defaultDialog<List<String>?>(
        title: 'Select cluster columns',
        content: Container(
          constraints: BoxConstraints(maxHeight: Get.height * .75, minWidth: 200, maxWidth: 450),
          child: CheckboxListView<String>(
            useListView: false,
            data: firstLine[0].split(RegExp('	|\t')),
            onSelectionChanged: (List<String> list) {
              clusters = list;
            },
          ),
        ),
        textConfirm: ' OK ',
        onConfirm: () {
          Get.back(result: clusters);
        });
    if (result == null || result.length == 0) return;

    List<String> _clusters = result;
    // currentGroup = _clusters[0];
    // _labelByGroup = _currentGroup;
    var _matrix = MatrixBean({
      'mod_id': '${'${metaFile!.path}-${cordFile!.path}'.hashCode}',
      'mod_name': '${metaFile!.name}',
      'type': 'gene',
      'cell_groups': Map.fromIterables(clusters, clusters.map((e) => ({'value': [], 'type': 'list'}))),
      'plots': [cordFile!.name],
    });
    _nativeMatrixList = [_matrix];
    // _plotType = cordFile!.name;

    currentChartLogic.loadFromFile(cordFile!, metaFile!, _clusters[0]);
  }

  void changeNativeGroup(String group) {
    // currentGroup = group;
    // _labelByGroup = group;

    currentChartLogic.loadFromFile(cordFile!, metaFile!, group);
  }

  @override
  void onInit() {
    super.onInit();
    if (SgsConfigService.get()!.appLayout == AppLayout.SC) {
      SgsAppService.get()!.sendEvent(TrackBasicEvent());
    }
  }

  @override
  void onReady() {
    super.onReady();
    // if (_track == null) {
    //   var tracks = SgsAppService.get()!.tracks.where((e) => e.isSCTrack && e.checked);
    //   if (tracks.length == 1) {
    //     track = tracks.first;
    //   }
    // }
  }

  void onLabelByChange(String labelByGroup) {
    _labelByGroup = labelByGroup;
    currentChartLogic.onLabelByChange();
  }

  void _cacheModSpatialImages(MatrixBean matrix) async {
    if (matrix.spatials == null) return;
    await Future.wait(matrix.spatials!.map(currentChartLogic.cacheSliceImage));
  }

  static CellPageLogic? safe() {
    if (Get.isRegistered<CellPageLogic>()) {
      return Get.find<CellPageLogic>();
    }
    return null;
  }

  void openRStudio() {
    Uri uri = Uri.parse(SgsAppService.get()!.site!.url);
    var url = 'http://${uri.host}:18787';
    PlatformAdapter.create().openBrowser(url);
  }

  resetChart() {
    // currentChartLogic.reset();
    _logic1.reset();
    _logic2.reset();
    update([CellLayer.legendLayer]);
  }

  void saveImage() async {
    setScreenshotMod(true);

    var func = BotToast.showLoading();
    await Future.delayed(Duration(milliseconds: 100));

    try {
      final pageLogic = CellPageLogic.safe();
      await WidgetUtil.widget2Image(
        _repaintBoundaryKey,
        fileName: '${pageLogic!.track?.name}-${currentChartLogic.state.mod!.name}-${currentChartLogic.state.plotType}-${currentChartLogic.currentGroup}',
      );
    } catch (e) {
      showToast(text: 'save image error ${e}');
    } finally {
      await Future.delayed(Duration(milliseconds: 300));
      func.call();
      setScreenshotMod(false);
    }
  }

  void toggleAllLayer() {
    _allFontLayerHide = !_allFontLayerHide;
    updateFontLayer();
  }

  void toggleLegend() {
    _showLegend = !_showLegend;
    update([CellLayer.legendLayer, CellLayer.modeLayer]);
  }

  void onColorSchemaChange(LegendColor legendColor) {
    currentChartLogic.onColorSchemaChange(legendColor);
    update([CellLayer.legendLayer]);
  }

  void onColorChange(List<DataCategory> cats) {
    currentChartLogic.onColorChange(cats);
    update([CellLayer.legendLayer]);
  }

  void onChartResize(ui.Size size) {
    _logic1.debounceSetViewportSize(size);
    _logic2.debounceSetViewportSize(size);
  }

  void onTapFeature(String feature) {
    currentChartLogic.loadSingleFeaturePlotData([feature]);
  }

  void onTapFeatures(List<Map> features) {
    if (features.length > 0) {
      currentChartLogic.loadSingleFeaturePlotData(features.map<String>((e) => e['id']).toList());
    } else {
      currentChartLogic.reset();
      updateFontLayer();
    }
  }

  void searchFeatureFromGff(String gene) => currentChartLogic.fetchFeatureExpressionFromGff(gene);
}
