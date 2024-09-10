import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:flutter_smart_genome/page/cell/cell_base.dart';
import 'package:flutter_smart_genome/page/cell/cell_page/cell_page_logic.dart';
import 'package:flutter_smart_genome/page/cell/cell_scatter_chart/legend_colors.dart';
import 'package:flutter_smart_genome/service/sgs_app_service.dart';
import 'package:flutter_smart_genome/service/single_cell_service.dart';
import 'package:flutter_smart_genome/storage/base_store_provider.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:flutter_smart_genome/widget/basic/svg_icons.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class CompareElement {
  SCViewType type;
  bool checked = false;

  bool get isFeature => type == SCViewType.feature;

  String matrix;
  String? plotType;
  String category;
  Spatial? spatial;

  Color color = Color.fromARGB(255, 234, 78, 14);
  LegendColor legendColor = expressionLegendColors.first.copyWith();
  double pointSize = 3;
  double opacity = 1.0;
  bool transposed = false;

  @override
  String toString() {
    return 'CompareElement{type: $type, checked: $checked, matrix: $matrix, plotType: $plotType, category: $category, spatial: $spatial, color: $color, legendColor: $legendColor, pointSize: $pointSize, opacity: $opacity, transposed: $transposed}';
  }

  CompareElement({
    required this.type,
    required this.matrix,
    required this.category,
    this.checked = false,
    this.plotType,
    this.spatial,
  });
}

class CompareElementState<T> {
  SCViewType type;
  late bool loading = false;
  String? error = null;
  T? data = null;

  bool get isTitle => type == SCViewType.feature;

  CompareElementState({required this.type, this.loading = false, this.error, this.data});
}

class CompareLogic extends GetxController {
  static CompareLogic? get() {
    if (Get.isRegistered<CompareLogic>()) {
      return Get.find<CompareLogic>();
    }
    return null;
  }

  List<Map> _features = [];

  List<String> get featureNames => _features.map<String>((e) => e['feature_name']).toList();

  List<Map> get genes => _features;
  late String _matrix, _group;

  String get matrix => _matrix;

  String get group => _group;

  // Map<SCViewType, CompareElementState> _elementStateMap;

  // CompareElementState _titleGroup;
  // CompareElementState get titleGroup => _titleGroup;

  // Map<SCViewType, CompareElementState> get elementStateMap => _elementStateMap;

  List<SCViewType> _viewTypes = [
    // SCViewType.feature,
    SCViewType.scatter,
    // SCViewType.box,
    SCViewType.violin,
    SCViewType.motif,
    SCViewType.heatmap,
    SCViewType.dotplot,
  ];

  List<SCViewType> get viewTypes => _viewTypes;

  List<CompareElement> _elements = [
    // CompareElement(type: SCViewType.feature, checked: true),
    // CompareElement(type: SCViewType.scatter, checked: true),
    // CompareElement(type: SCViewType.bar, checked: true),
    // CompareElement(type: SCViewType.box, checked: false),
    // CompareElement(type: SCViewType.violin, checked: false),
    // CompareElement(type: SCViewType.coverage, checked: false),
    // CompareElement(type: SCViewType.motif, checked: false),
    // CompareElement(type: SCViewType.heatmap, checked: false),
  ];

  List<CompareElement> get elements => _elements;

  List<CompareElement> get checkedElements => _elements.where((e) => e.checked).toList();

  void orderViewTypes(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;
    final element = _elements.removeAt(oldIndex);
    _elements.insert(newIndex, element);
    update();
  }

  void onOrderViewTypesChange(List<CompareElement> value) {
    _elements = value;
    update();
  }

  void onCompareElementCheckedChange(CompareElement element) {
    if (element.checked) {
      // _getGenesImages(element.type);
    } else {
      // _elementStateMap.remove(element.type);
      // update();
    }
    update();
  }

  void onDeleteCompareItem(CompareElement element) {
    _elements.remove(element);
    update();
  }

  List<List<String>> getFeatureHistories() {
    Track? track = CellPageLogic.safe()!.track;
    if (track == null) return [];
    return BaseStoreProvider.get().getCompareHistory('${track.scId!}-${_matrix}').reversed.toList();
  }

  void addFeatureHistories(List<String> list) {
    Track? track = CellPageLogic.safe()!.track;
    if (track == null || list.isEmpty) return;
    BaseStoreProvider.get().addCompareHistory('${track.scId!}-${_matrix}', list);
  }

  void onDeleteHistoryItem(List<String> list) {
    Track? track = CellPageLogic.safe()!.track;
    if (track == null) return;
    BaseStoreProvider.get().deleteCompareHistory('${track.scId!}-${_matrix}', list);
  }

  void onAddCompareElement(CompareElement element) {
    String key = element.toString();
    if (_elements.any((e) => e.toString() == key)) {
      showToast(text: '${element.type.name} with mod ${element.matrix} already added!', duration: Duration(milliseconds: 5000));
      return;
    }
    _elements.add(element);
    update();
  }

  void onGeneDelete(String feature) {
    if (_features.length == 1) return;
    _features.removeWhere((e) => e['feature_name'] == feature);
    update();
  }

  void onFeatureChange(List<String> features, {bool isHistory = false}) {
    _features = features.map((e) => ({'feature_name': e})).toList();
    update();
    if (!isHistory) addFeatureHistories(featureNames);
  }

  void onViewDispose() {
    addFeatureHistories(featureNames);
  }

  @override
  void onInit() {
    super.onInit();
    final pageLogic = CellPageLogic.safe()!;
    _matrix = pageLogic.currentChartLogic.state.mod!.id;
    _group = pageLogic.isCurrentGroupCategory ? pageLogic.currentChartLogic.currentGroup! : pageLogic.categories.keys.first;
    // _elementStateMap = {};
  }

  void setFeatures(List<Map> features, MatrixBean matrix) {
    final pageLogic = CellPageLogic.safe()!;
    _viewTypes = [
      // SCViewType.feature,
      SCViewType.scatter,
      // SCViewType.box,
      SCViewType.violin,
      // if (matrix.isPeakMatrix) SCViewType.coverage,
      // if (matrix.isMotifMatrix) SCViewType.motif,
      SCViewType.motif,
      SCViewType.heatmap,
      SCViewType.dotplot,
    ];
    _matrix = matrix.id;
    _group = pageLogic.isCurrentGroupCategory ? pageLogic.currentChartLogic.currentGroup! : pageLogic.categories.keys.first;
    _features = features;
    final spatial = pageLogic.currentChartLogic.state.spatial;
    var plotType = pageLogic.currentChartLogic.state.plotType;
    _elements = [
      // CompareElement(type: SCViewType.feature, checked: true, matrix: matrix.id, plotType: plotType, category: _group, spatial: spatial),
      CompareElement(type: SCViewType.scatter, checked: true, matrix: matrix.id, plotType: plotType, category: _group, spatial: spatial),
      // CompareElement(type: SCViewType.dotplot, checked: true, matrix: matrix.id, plotType: pageLogic.plotType, category: _group, spatial: spatial),
      // CompareElement(type: SCViewType.box, checked: true, matrix: matrix.id, plotType: CellPageLogic.safe()!.plotType, category: _group, spatial: spatial),
      CompareElement(type: SCViewType.violin, checked: true, matrix: matrix.id, plotType: plotType, category: _group, spatial: spatial),
      // if (matrix.isPeakMatrix) CompareElement(type: SCViewType.coverage, checked: true, matrix: matrix.id, plotType: pageLogic.plotType, category: _group, spatial: spatial),
      if (matrix.isMotifMatrix) CompareElement(type: SCViewType.motif, checked: true, matrix: matrix.id, plotType: plotType, category: _group, spatial: spatial),
      CompareElement(type: SCViewType.dotplot, checked: true, matrix: matrix.id, plotType: plotType, category: _group, spatial: spatial),
    ];
    // _titleGroup = CompareElementState(type: SCViewType.feature, data: _genes, loading: false);
    update();
    // _reloadData();
  }

  void _reloadData() {
    _elements.where((e) => e.checked).forEach((e) {
      if (e != SCViewType.coverage) {
        _getGenesImages(e.type);
      }
    });
  }

  void _getGenesImages(SCViewType type) async {
    var site = SgsAppService.get()!.site!;
    final pageLogic = CellPageLogic.safe();

    CompareElementState<List<String>> _state = CompareElementState(type: type, loading: true, data: null);
    // _elementStateMap[type] = _state;
    update();

    // await Future.delayed(Duration(seconds: 5));

    var resp = await loadCompareFeatureImages(
      host: site.url,
      scId: CellPageLogic.safe()!.track!.scId!,
      genes: _features.map<String>((e) => e['feature_names']).toList(),
      matrix: _matrix,
      group: pageLogic!.currentChartLogic.currentGroup!,
      plotType: pageLogic.currentChartLogic.state.plotType,
      chartType: chartTypeString(type),
    );
    _state.loading = false;
    if (resp.success) {
      List images = resp.body;
      List<String> _images = images.map((e) => '${site.url}${e['thumb_image_url']}').toList();
      _state.data = _images;
    } else {
      _state.error = resp.error?.message;
    }
    update();
  }

  String chartTypeString(SCViewType type) {
    return type.name;
  }

  SvgPicture? svgIcon(SCViewType type, {Color? color}) {
    switch (type) {
      case SCViewType.violin:
        return SvgPicture.string(iconViolin, width: 42, height: 24, colorFilter: color == null ? null : ColorFilter.mode(color, BlendMode.srcATop));
      case SCViewType.heatmap:
        return SvgPicture.string(iconHeatmap, width: 28, height: 28, colorFilter: color == null ? null : ColorFilter.mode(color, BlendMode.srcATop));
      case SCViewType.dotplot:
        return SvgPicture.string(iconDotplot, width: 30, height: 30, colorFilter: color == null ? null : ColorFilter.mode(color, BlendMode.srcATop));
      case SCViewType.motif:
        return SvgPicture.string(iconMotifLogo, height: 34, colorFilter: color == null ? null : ColorFilter.mode(color, BlendMode.srcATop));
      default:
        return null;
    }
  }

  IconData chartTypeIcon(SCViewType type) {
    switch (type) {
      case SCViewType.scatter:
        return MaterialCommunityIcons.scatter_plot;
        break;
      case SCViewType.violin:
        return MaterialCommunityIcons.violin;
        break;
      case SCViewType.heatmap:
        return Icons.heat_pump;
        break;
      case SCViewType.coverage:
        return Icons.bar_chart;
      case SCViewType.dotplot:
        return AntDesign.dotchart;
      case SCViewType.feature:
        return MaterialCommunityIcons.chart_timeline;
      default:
        return Icons.pie_chart_rounded;
    }
  }
}
