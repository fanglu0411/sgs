import 'dart:async';
import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:flutter_smart_genome/base/app_layout.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/bloc/sgs_context/sgs_browse_logic.dart';
import 'package:flutter_smart_genome/network/http_response.dart';
import 'package:flutter_smart_genome/page/cell/cell_data_table/table_data_state.dart';
import 'package:flutter_smart_genome/page/compare/compare_window_manager.dart';
import 'package:flutter_smart_genome/platform/platform_adapter.dart';
import 'package:flutter_smart_genome/service/sgs_config_service.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:flutter_smart_genome/widget/basic/download_button.dart';
import 'package:flutter_smart_genome/page/cell/cell_page/cell_page_logic.dart';
import 'package:flutter_smart_genome/page/cell/cell_scatter_chart/cell_scatter_chart_logic.dart';
import 'package:flutter_smart_genome/service/sgs_app_service.dart';
import 'package:flutter_smart_genome/service/single_cell_service.dart';
import 'package:flutter_smart_genome/util/debouncer.dart';
import 'package:flutter_smart_genome/widget/basic/svg_icons.dart';
import 'package:flutter_smart_genome/widget/table/simple_data_table_source.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';

import 'package:flutter_smart_genome/widget/track/common.dart';
import 'package:flutter_smart_genome/widget/track/cross_overlay/cross_overlay_logic.dart';
import 'package:flutter_smart_genome/widget/track/eqtl/eqtl_track_logic.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:dartx/dartx.dart' as dx;

enum TableSourceType {
  marker_feature,
  cluster_meta,
  cluster_meta_chart,
  spatial_slice,
  selected_feature,
  feature_expression,
  // selected_feature2,
}

class CellDataTableLogic extends GetxController {
  final markerFeatureState = CellMarkerFeatureState();
  final clusterMetaState = CellClusterMetaState();
  final selectedFeatureState = SelectedFeatureState();
  final spatialSliceState = SpatialSliceState();
  final featureExpressionState = FeatureExpressionState();

  CancelToken? _cancelToken;

  late NumberFormat _numberFormat;
  bool _imageLoading = false;
  Map _images = {};

  List _imageIds = [];

  Map get imageMap => _images;

  late Debounce _imageLoadDebounce;

  Widget getTabIcon(TableSourceType tab, Color? color) {
    return switch (tab) {
      TableSourceType.marker_feature => SvgIcon(iconMarkerFeature, size: Size(30, 18), color: color),
      TableSourceType.cluster_meta => SvgIcon(iconMeta, size: Size(30, 18), color: color),
      TableSourceType.cluster_meta_chart => Icon(Icons.stacked_bar_chart, size: 16),
      TableSourceType.spatial_slice => SvgIcon(iconSlice, size: Size(36, 36), color: color),
      TableSourceType.selected_feature => SvgIcon(iconSelection, size: Size(24, 18), color: color),
      TableSourceType.feature_expression => Icon(Icons.scatter_plot, size: 16, color: color),
    };
  }

  Map<TableSourceType, String> tabNameMap = <TableSourceType, String>{
    TableSourceType.marker_feature: 'Marker Features',
    TableSourceType.cluster_meta: 'Meta List',
    TableSourceType.cluster_meta_chart: 'Meta Statics',
    TableSourceType.selected_feature: 'Selected Cells',
    TableSourceType.spatial_slice: 'Spatial Slice',
    TableSourceType.feature_expression: 'Feature Expression',
  };

  // String get imageBaseUrl {
  //   Uri uri = Uri.parse(SgsAppService.get()!.site!.url);
  //   return 'http://${uri.host}:6102';
  // }

  bool albumMode = false;

  bool metaChart = false;

  TableSourceType? _tableSourceType;

  TableSourceType? get tableSourceType => _tableSourceType;

  int get dataSourceIndex => dataSourceMap.keys.toList().indexOf(_tableSourceType!);

  Map<TableSourceType, String> _dataSourceMap = {};

  Map<TableSourceType, String> get dataSourceMap => _dataSourceMap;

  late String tag;

  CellDataTableLogic(String tag) {
    this.tag = tag;
    _numberFormat = NumberFormat.scientificPattern();
    _imageLoadDebounce = Debounce(milliseconds: 100);
  }

  CellScatterChartLogic get chartLogic => CellPageLogic.safe()!.chartLogic(tag);

  String? get group => CellPageLogic.safe()?.chartLogic(tag).currentGroup;

  _initDataSourceMap(MatrixBean matrix, [bool isNativeSource = false]) {
    if (matrix.isPeakMatrix) {
      _dataSourceMap = {
        TableSourceType.marker_feature: 'Marker Peak',
        // TableSourceType.marker_peak: 'Marker Peak',
        TableSourceType.cluster_meta: 'Meta',
        TableSourceType.cluster_meta_chart: 'Meta Chart',
        TableSourceType.spatial_slice: 'Spatial',
        TableSourceType.feature_expression: 'Feature Expression',
        TableSourceType.selected_feature: 'Selection',
      };
    } else if (matrix.isMotifMatrix) {
      _dataSourceMap = {
        TableSourceType.marker_feature: 'Marker Motif',
        // TableSourceType.marker_motif: 'Marker Motif',
        TableSourceType.cluster_meta: 'Meta',
        TableSourceType.cluster_meta_chart: 'Meta Chart',
        TableSourceType.spatial_slice: 'Spatial',
        TableSourceType.feature_expression: 'Feature Expression',
        TableSourceType.selected_feature: 'Selection',
      };
    } else {
      _dataSourceMap = {
        TableSourceType.marker_feature: 'Feature',
        // TableSourceType.marker_gene: 'Marker Gene',
        TableSourceType.cluster_meta: 'Meta',
        TableSourceType.cluster_meta_chart: 'Meta Chart',
        TableSourceType.spatial_slice: 'Spatial',
        TableSourceType.feature_expression: 'Feature Expression',
        TableSourceType.selected_feature: 'Selection',
      };
    }
    if (!matrix.hasSpatials) {
      _dataSourceMap.remove(TableSourceType.spatial_slice);
    }
    _tableSourceType = isNativeSource ? TableSourceType.cluster_meta : dataSourceMap.keys.first;
  }

  AbsTableDataState get currentTableDataState {
    switch (_tableSourceType!) {
      case TableSourceType.marker_feature:
        return markerFeatureState;
      case TableSourceType.cluster_meta:
        return clusterMetaState;
      case TableSourceType.cluster_meta_chart:
        return clusterMetaState;
      case TableSourceType.selected_feature:
        return selectedFeatureState;
      case TableSourceType.spatial_slice:
        return spatialSliceState;
      case TableSourceType.feature_expression:
        return featureExpressionState;
    }
    // return null;
  }

  void toggleAlbumMode() {
    albumMode = !albumMode;
    update();
  }

  void toggleMetaChart() {
    metaChart = !metaChart;

    update();
  }

  @override
  void onReady() {
    super.onReady();
    Future.delayed(Duration(milliseconds: 120)).then((value) {
      onChangeMatrix(CellPageLogic.safe()!.chartLogic(tag).state.mod!);
    });
  }

  ///@Deprecated
  Future<HttpResponseBean?> pageDataLoader(int startIndex, int pageSize) async {
    final pageLogic = CellPageLogic.safe()!;
    int page = startIndex ~/ pageSize;
    SiteItem site = SgsAppService.get()!.site!;
    // List<DataCategory> checkedList = _clusters!.where((e) => e.checked).toList();
    CellScatterChartLogic chartLogic = pageLogic.chartLogic(tag);
    HttpResponseBean? resp;
    String dataKey;
    switch (_tableSourceType) {
      case TableSourceType.marker_feature:
        dataKey = 'data';
        resp = await loadCellMarkerFeatures(
          host: site.url,
          track: pageLogic.track!,
          matrixId: chartLogic.state.mod!.id,
          groupName: markerFeatureState.filterColumnKey,
          groupValue: markerFeatureState.filterColumnValue,
          orderBy: markerFeatureState.orderByColumnKey,
          order: markerFeatureState.order,
          plotType: chartLogic.state.plotType!,
          pageNumber: page,
          pageSize: pageSize,
        );
        break;
      default:
        return null;
    }

    if (resp.success) {
      Map body = resp.body is String ? json.decode(resp.body) : resp.body;
      List dataSource = body[dataKey] ?? [];
      List header = body['header'] ?? [];
      List<Map> _dataSource = _parseData(dataSource, header)!;
      return Future.value(HttpResponseBean.fromBody({
        'total': body['rec_count'],
        'data': _dataSource.map<RowDataItem>((e) => RowDataItem(e, id: '${e.toString().hashCode}')).toList(),
      }));
    }
    return Future.value(resp);
  }

  Future<(List<Map>?, String?, int)> quickPageDataLoader(int page, int pageSize) async {
    final pageLogic = CellPageLogic.safe()!;
    // int page = startIndex ~/ pageSize;
    SiteItem site = SgsAppService.get()!.site!;
    // List<DataCategory> checkedList = _clusters!.where((e) => e.checked).toList();
    CellScatterChartLogic chartLogic = pageLogic.chartLogic(tag);
    HttpResponseBean? resp;
    String dataKey;

    switch (_tableSourceType) {
      case TableSourceType.marker_feature:
        var cancelToken = await markerFeatureState.newCancelToken();
        dataKey = 'data';
        resp = await loadCellMarkerFeatures(
          host: site.url,
          track: pageLogic.track!,
          matrixId: chartLogic.state.mod!.id,
          groupName: markerFeatureState.filterColumnKey,
          groupValue: markerFeatureState.filterColumnValue,
          orderBy: markerFeatureState.orderByColumnKey,
          order: markerFeatureState.order,
          plotType: chartLogic.state.plotType!,
          pageNumber: page - 1,
          pageSize: pageSize,
          cancelToken: cancelToken,
        );
        break;
      case TableSourceType.cluster_meta:
        dataKey = 'data';
        var cancelToken = await clusterMetaState.newCancelToken();
        resp = await loadClusterMetaList(
          host: site.url,
          track: pageLogic.track!,
          matrixId: chartLogic.state.mod!.id,
          groupName: clusterMetaState.filterColumnKey!,
          groupValue: clusterMetaState.filterColumnValue,
          page: page - 1,
          pageSize: pageSize,
          cancelToken: cancelToken,
        );
      default:
        return Future.error('un known state');
    }

    if (resp.success) {
      Map body = resp.body is String ? json.decode(resp.body) : resp.body;
      List dataSource = body[dataKey] ?? [];
      List header = body['header'] ?? [];

      var a = (_parseData(dataSource, header), null, (body['rec_count'] ?? 0) as int);
      currentTableDataState.dataSource = a.$1;
      return Future.value(a);
      // return Future.value(HttpResponseBean.fromBody({
      //   'total': body['rec_count'],
      //   'data': dataSource.map<RowDataItem>((e) => RowDataItem(e, id: '${e.toString().hashCode}')).toList(),
      // }));
    }

    return Future.value((null, resp.error!.message, 0));
  }

  List<Map>? _parseData(List dataSource, List header) {
    if (dataSource.length > 0) {
      var item = dataSource.first;
      if (header.isEmpty) {
        if (item is Map) header = item.keys.toList();
      }
      if (item is List) {
        return dataSource.map<Map>((list) => toMapItem(header, list)).toList();
      } else if (item is Map) {
        return dataSource.cast<Map>();
      }
    }
    return [];
  }

  MatrixBean? _matrix;

  String? get modId => _matrix?.id;

  void onChangeMatrix(MatrixBean matrix) {
    _matrix = matrix;
    final pageLogic = CellPageLogic.safe()!;
    _initDataSourceMap(matrix, pageLogic.nativeSource);

    changeData();
  }

  void changeData() {
    reset();

    /// default not filter meta
    // final pageLogic = CellPageLogic.safe()!;
    // var cats = pageLogic.chartLogic(tag).categories;
    // var currentGroup = pageLogic.chartLogic(tag).currentGroup;
    // if (cats.length > 0) {
    //   var cat = cats.keys.firstOrNullWhere((e) => e == currentGroup) ?? cats.keys.first;
    //   clusterMetaState.filterColumnKey = cat;
    //   if (cats[cat] != null && cats[cat]!.length > 0) {
    //     clusterMetaState.filterColumnValue = cats[cat]![0];
    //   }
    // }
    clusterMetaState.filterColumnKey = null;
    clusterMetaState.filterColumnValue = null;

    markerFeatureState.filterColumnKey = null;
    markerFeatureState.filterColumnValue = null;

    loadData();
  }

  void clearMarkerFeatureSearch() {
    markerFeatureState
      ..searchBy = null
      ..searchKeyword = null;
    loadData();
  }

  void clearMarkerTableFilter() {
    markerFeatureState
      ..filterColumnKey = null
      ..filterColumnValue = null;
    loadData();
  }

  void onMarkerTableFilterChange(String group, String cluster) {
    markerFeatureState.filterColumnKey = group;
    markerFeatureState.filterColumnValue = cluster;
    // _selectedCluster = cluster;
    loadData();
  }

  void clearMetaTableFilter() {
    clusterMetaState
      ..filterColumnKey = null
      ..filterColumnValue = null;
    loadData();
  }

  void onMetaTableFilterChange(String group, String cluster) {
    clusterMetaState.filterColumnKey = group;
    clusterMetaState.filterColumnValue = cluster;
    // _selectedCluster = cluster;
    loadData();
  }

  void loadData() {
    _loadData(forceReload: true);
  }

  _loadMarkerFeatures() async {
    final pageLogic = CellPageLogic.safe()!;
    if (pageLogic.nativeSource) {
      return;
    }

    CellScatterChartLogic chartLogic = pageLogic.chartLogic(tag);
    SiteItem site = SgsAppService.get()!.site!;
    // List<DataCategory> checkedList = _clusters!.where((e) => e.checked).toList();
    var cancelToken = await markerFeatureState.newCancelToken();
    var fetcher = markerFeatureState.needSearch
        ? searchMarkerFeature(
            host: site.url,
            track: pageLogic.track!,
            matrixId: chartLogic.state.mod!.id,
            column: markerFeatureState.searchBy!,
            keyword: markerFeatureState.searchKeyword!,
          )
        : loadCellMarkerFeatures(
            host: site.url,
            track: pageLogic.track!,
            matrixId: chartLogic.state.mod!.id,
            groupName: markerFeatureState.filterColumnKey,
            groupValue: markerFeatureState.filterColumnValue,
            orderBy: markerFeatureState.orderByColumnKey,
            order: markerFeatureState.order,
            plotType: chartLogic.state.plotType!,
            pageNumber: markerFeatureState.currentPage - 1,
            pageSize: markerFeatureState.pageSize,
            cancelToken: cancelToken,
          );
    __loadTableData(
      fetcher: fetcher,
      tableSourceType: TableSourceType.marker_feature,
      tableDataState: markerFeatureState,
      rootDataKey: markerFeatureState.needSearch ? 'match_features' : null,
      dataKey: 'data',
    );
  }

  Future _loadMarkerFeatureColumnFilters() async {
    final pageLogic = CellPageLogic.safe()!;
    if (pageLogic.nativeSource) {
      return;
    }
    SiteItem site = SgsAppService.get()!.site!;
    var resp = await loadMarkerFeatureFilters(host: site.url, track: pageLogic.track!, matrixId: chartLogic.state.mod!.id);
    if (resp.success) {
      Map body = resp.body is String ? json.decode(resp.body) : resp.body;
      markerFeatureState.columnFilters = body;
    } else {
      markerFeatureState.columnFilters = {};
    }

    // 默认不筛选
    // if (body.isNotEmpty) {
    //   var f = body.entries.first;
    //   markerFeatureState.filterColumnKey = f.key;
    //   markerFeatureState.filterColumnValue = f.value[0];
    // } else {
    //   markerFeatureState.filterColumnKey = null;
    //   markerFeatureState.filterColumnValue = null;
    // }
  }

  Map toMapItem(List header, List item) {
    return Map.fromIterables(header, item);
  }

  _loadClusterMetas() async {
    final pageLogic = CellPageLogic.safe();
    if (pageLogic!.nativeSource) {
      _loadNativeMeta();
      return;
    }

    SiteItem site = SgsAppService.get()!.site!;
    // List<DataCategory> checkedList = _clusters!.where((e) => e.focused).toList();
    var fetcher = loadClusterMetaList(
      host: site.url,
      track: pageLogic.track!,
      matrixId: chartLogic.state.mod!.id,
      groupName: clusterMetaState.filterColumnKey,
      groupValue: clusterMetaState.filterColumnValue,
      pageSize: clusterMetaState.pageSize,
      page: clusterMetaState.currentPage - 1,
    );
    __loadTableData(
      fetcher: fetcher,
      tableSourceType: TableSourceType.cluster_meta,
      tableDataState: clusterMetaState,
      dataKey: 'data',
    );
  }

  __loadTableData({
    required Future<HttpResponseBean> fetcher,
    required AbsTableDataState tableDataState,
    required TableSourceType tableSourceType,
    String? rootDataKey,
    required String dataKey,
  }) async {
    bool needUpdate = _tableSourceType == tableSourceType;
    // List<DataCategory> checkedList = _clusters!.where((e) => e.focused).toList();
    // if (_selectedCluster == null) {
    //   tableDataState.dataSource = [];
    //   if (needUpdate) update();
    //   return;
    // }

    if (needUpdate) {
      tableDataState.loading = true;
      update();
    }
    // await Future.delayed(Duration(milliseconds: 100));

    final pageLogic = CellPageLogic.safe();
    // SiteItem site = SgsAppService.get().site;
    _cancelToken = CancelToken();
    var resp = await fetcher;
    tableDataState.loading = false;

    if (resp.success) {
      Map body = resp.body is String ? json.decode(resp.body) : resp.body;
      if (rootDataKey != null) body = body[rootDataKey] ?? body;
      List dataSource = body[dataKey] ?? [];
      List<String> header = body['header']?.map<String>((e) => e as String)?.toList() ?? [];
      List<Map> _dataSource = [];
      int total = body['rec_count'] ?? dataSource.length;
      if (dataSource.length > 0) {
        var item = dataSource.first;
        if (item is Map) {
          header = item.keys.map<String>((e) => e as String).toList();
          _dataSource = dataSource.cast<Map>();
        } else if (item is List) {
          if (header.isEmpty) header = List.generate(item.length, (i) => 'Column ${i + 1}');
          _dataSource = dataSource.map<Map>((list) => toMapItem(header, list)).toList();
        }
      }
      if (header.isEmpty) header = [pageLogic!.chartLogic(tag).currentGroup!];
      tableDataState.dataSource = _dataSource;
      tableDataState.headers = header;
      tableDataState.totalCount = total;
    } else {
      if (resp.error!.type != DioExceptionType.cancel) {
        tableDataState.error = resp.error!.message;
        tableDataState.dataSource = [];
        tableDataState.headers = <String>[pageLogic!.chartLogic(tag).currentGroup!];
        tableDataState.totalCount = 0;
      }
    }
    if (tableDataState.needSearch && tableDataState.isEmpty) {
      showToast(text: 'Search feature empty');
    }
    if (needUpdate) update();
  }

  void setSelectedFeature(Map<String, List>? features) {
    if (features == null) {
      selectedFeatureState.clear();
      update();
      return;
    }
    selectedFeatureState.dataSource = [];
    for (String group in features.keys) {
      Iterable<Map> _features = features[group]!.map<Map>((list) {
        if (list.length > 3) return {selectedFeatureState.nameKey: list[0], 'x': list[2], 'y': list[3]};
        return {selectedFeatureState.nameKey: list[0], 'x': list[1], 'y': list[2]};
      });
      selectedFeatureState.dataSource!.addAll(_features);
    }
    update();
  }

  int get getRowSelectionCount => (currentTableDataState.selections ?? {}).length;

  void changeSelection(int index, Map rowItem, bool checked) {
    if (currentTableDataState.paginated) {
      currentTableDataState.paginatedSelectChange(rowItem, checked);
    } else {
      if (checked) {
        currentTableDataState.selections?[index] = checked;
      } else {
        currentTableDataState.selections?.remove(index);
      }
      currentTableDataState.rowSelectionsObs.value = getRowSelectionCount > 0;
    }
  }

  String formatValue(value) {
    if (value is double) {
      int v = value.toInt();
      if ((v - value) == 0) {
        return '${v}';
      }
      if ((value.abs()) >= 0.0001) return value.toStringAsFixed(4);
      return _numberFormat.format(value);
    }
    return '${value}';
  }

  void updateImageStatus() {
    _imageLoadDebounce.run(() {
      _loadImages();
    });
  }

  void addImageId(String id) {
    if (!_imageIds.contains(id)) {
      _imageIds.add(id);
    }
    updateImageStatus();
  }

  void _loadImages() async {
    if (_imageLoading) return;

    var __imageIds = List.of(_imageIds, growable: false);
    final pageLogic = CellPageLogic.safe();
    SiteItem site = SgsAppService.get()!.site!;
    var resp = await loadMarkerGeneImages(host: site.url, imageIds: __imageIds, plotType: pageLogic!.chartLogic(tag).state.plotType!);
    if (resp.success) {
      List images = resp.body['result'];
      _images = Map.fromIterables(__imageIds, images);
      _imageLoading = false;
      update();
    }
  }

  @override
  void onClose() {
    _cancelToken?.cancel('disposed!');
    _imageLoadDebounce.dispose();
    super.onClose();
  }

  void onFeatureTap(item, Map rowData, BuildContext context) async {
    if (tableSourceType == TableSourceType.marker_feature) {
      _onGeneTap(item, rowData, context);
    }
    // else if (tableSourceType == TableSourceType.marker_gene) {
    //   _onGeneTap(item, rowData, context);
    // } else if (tableSourceType == TableSourceType.marker_peak) {
    //   chartLogic.loadSingleFeaturePlotData('${item}');
    //   Range range = Range(start: item['peak_start'], end: item['peak_end']);
    //   String chrName = item['chr_name'];
    //   SgsBrowseLogic.safe()?.jumpToPositionByChrName(chrName, range, context);
    // } else if (tableSourceType == TableSourceType.marker_motif) {
    //   showToast(text: 'no position to locate');
    // }
  }

  void _onGeneTap(item, Map rowData, BuildContext context) async {
    chartLogic.loadSingleFeaturePlotData(['${item}']);

    if (SgsConfigService.get()!.appLayout == AppLayout.SC) return;

    final cellPageLogic = CellPageLogic.safe();
    SiteItem site = SgsAppService.get()!.site!;
    HttpResponseBean resp = await searchGene(host: site.url, speciesId: site.currentSpeciesId!, feature: '${item}', track: cellPageLogic!.track!);
    if (resp.success && resp.body['start'] != null) {
      Range range = Range(start: resp.body['start'], end: resp.body['end']);
      CrossOverlayLogic.safe()?.setTarget(targetTrackId: null, targetId: item);
      await SgsBrowseLogic.safe()?.jumpToPosition(resp.body['chr_id'], range, Get.context!);
    } else {
      showToast(text: '${item} not found!');
    }
    if (chartLogic.state.mod!.isGeneMatrix) {
      EqtlTrackLogic.notifyTargetGene(item);
    }
  }

  void onImageTap(String title, String image) {
    // var dataSource = WindowDataSource.image(title: title, image: image);
    // if (!SocketServerManager().isClientConnected()) {
    //   Rect rect = IoUtils.instance.getWindowRect();
    //   Size size = Size(600, 400);
    //   Rect _rect = rect.deflateXY((rect.width - size.width) / 2, (rect.height - size.height) / 2);
    //   dataSource.windowConfig = {
    //     'rect': [_rect.left, _rect.top, _rect.right, _rect.bottom],
    //   };
    // }
    // PlatformAdapter.create().openWindow(dataSource);
    _showFrontCard(title, image);
  }

  void showMultiCompare() {
    CompareWindowManager.get().showOrUpdateCompareWindow(currentTableDataState.selectedFeatures, chartLogic.state.mod!);
  }

  void _showFrontCard(String title, String image) {
    CompareWindowManager.get().showDraggableWindow(
      title: title,
      builder: (context, size, dragging, resizing, c) {
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.network(image),
            Align(
              alignment: Alignment.topRight,
              child: DownloadButton(url: image, name: '$title-scatter'),
            ),
          ],
        );
      },
    );
  }

  void onDataSourceTypeChange(int index) {
    _tableSourceType = dataSourceMap.keys.toList()[index];
    update();
    _loadData(forceReload: false);
  }

  _loadData({bool forceReload = false}) async {
    switch (_tableSourceType!) {
      case TableSourceType.marker_feature:
        if (markerFeatureState.isColumnFilterEmpty) await _loadMarkerFeatureColumnFilters();
        if (forceReload || markerFeatureState.isEmpty) _loadMarkerFeatures();
        break;
      case TableSourceType.cluster_meta_chart:
        update();
        break;
      case TableSourceType.cluster_meta:
        if (forceReload || clusterMetaState.isEmpty) _loadClusterMetas();
        break;
      case TableSourceType.selected_feature:
        break;
      case TableSourceType.spatial_slice:
        spatialSliceState.loading = false;
        spatialSliceState.data = chartLogic.state.mod?.spatials;
        update();
        break;
      case TableSourceType.feature_expression:
        featureExpressionState.setData(chartLogic.featureHistory);
        update();
        break;
    }
  }

  Future<HttpResponseBean<List<Map>>> loadPeakCoverage(String chrName, num start, num end, String peak) {
    var site = SgsAppService.get()!.site!;
    var cellPageLogic = CellPageLogic.safe()!;
    return loadMarkerPeakGroupCoverage(
      host: site.url,
      track: cellPageLogic.track!,
      matrixId: chartLogic.state.mod!.id,
      groupName: cellPageLogic.chartLogic(tag).currentGroup!,
      chrName: chrName,
      featureName: peak,
      start: start,
      end: end,
    );
  }

  _loadNativeMeta() async {
    final pageLogic = CellPageLogic.safe()!;
    final meta = pageLogic.metaFile;
    final currentCluster = pageLogic.chartLogic(tag).currentGroup;
    late int clusterIndex;
    late List<String> metaColumns;
    int metaLineIndex = -1;

    List<Map> filteredMeta = [];
    final groupValue = pageLogic.currentClusters.first;
    print('load meta: ${currentCluster}, ${groupValue}');

    void _parseMetaLine(String line) {
      metaLineIndex++;
      List<String> arr = line.split(RegExp('	|\t'));
      if (metaLineIndex == 0) {
        metaColumns = arr;
        clusterIndex = metaColumns.indexOf(currentCluster!);
      } else {
        if (arr[clusterIndex] == groupValue) ;
        filteredMeta.add(Map.fromIterables(metaColumns, arr));
      }
    }

    clusterMetaState.loading = true;
    update();

    meta!
        .openStream()
        .transform(utf8.decoder) // Decode bytes to UTF-8.
        .transform(LineSplitter()) // Convert stream to individual lines.
        .listen(
      _parseMetaLine,
      onDone: () {
        // CellPageLogic.safe()!.groupMap[currentCluster!] = clusters!;
        clusterMetaState.dataSource = filteredMeta;
        clusterMetaState.headers = metaColumns;
        clusterMetaState.loading = false;
        update();
      },
      onError: (e) {
        print(e.toString());
        clusterMetaState.loading = false;
        clusterMetaState.error = e.toString();
        update();
      },
    );
  }

  void exportSelectedCells(String groupName) async {
    if (selectedFeatureState.isEmpty) {
      showToast(text: 'selection is empty');
      return;
    }
    String cells = (selectedFeatureState).dataSource!.map((e) => '${e[selectedFeatureState.nameKey]}, ${e['x']}, ${e['y']}').join('\n');
    var state = CellPageLogic.safe()!.chartLogic(tag).state;
    String content = '# mod=${state.mod?.name}, plot=${state.plotType}, group=${groupName}\ncell, x, y\n${cells}';
    PlatformAdapter.create().saveFile(filename: '${groupName}.csv', content: content);
  }

  void clearSelection() {
    CellPageLogic.safe()!.chartLogic(tag).clearSelection();
  }

  void updateFeatureExpressionList() {
    if (tableSourceType == TableSourceType.feature_expression) {
      _loadData();
    }
  }

  reset() {
    markerFeatureState.clear();
    clusterMetaState.clear();
    selectedFeatureState.clear();
    spatialSliceState.clear();
    featureExpressionState.clear();
  }

  void onViewDispose() {
    markerFeatureState.cancelRequest();
    clusterMetaState.cancelRequest();
  }

  static CellDataTableLogic? safe(String tag) {
    if (Get.isRegistered<CellDataTableLogic>(tag: tag)) {
      return Get.find<CellDataTableLogic>(tag: tag);
    }
    return null;
  }
}
