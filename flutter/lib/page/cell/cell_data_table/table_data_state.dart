import 'package:dartx/dartx.dart';
import 'package:dio/dio.dart';
import 'package:flutter_smart_genome/page/cell/cell_scatter_chart/feature_history_item.dart';
import 'package:flutter_smart_genome/widget/table/simple_data_table_source.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:get/get.dart';

abstract class AbsTableDataState {
  bool loading = false;
  List<String>? _headers;
  List<Map>? _dataSource;
  String? error;

  List<Map>? get dataSource => _dataSource;
  Map<int, bool>? selections;

  Map? _columnFilters = {};

  Map? get columnFilters => _columnFilters;

  void set columnFilters(Map? filters) => _columnFilters = filters;

  String? filterColumnKey;
  String? _filterColumnValue;

  String? get filterColumnValue => _filterColumnValue;

  void set filterColumnValue(value) => _filterColumnValue = value?.toString();

  String? orderByColumnKey;
  String? order = 'desc';

  String get emptyMsg;

  String? searchBy;
  String? searchKeyword;

  void cancelSearch() {
    searchBy = null;
    searchKeyword = null;
  }

  bool get needSearch => searchBy != null && searchKeyword != null && searchKeyword!.length > 0;

  bool paginated = false;
  int currentPage = 1;
  int pageSize = 20;
  int totalCount = 0;

  List<Map> selectionsForPaginated = [];

  List<String>? get headers => _headers;

  void set headers(List<String>? hs) => _headers = hs;

  var rowSelectionsObs = false.obs;

  List<Map> get selectedFeatures;

  String nameKey = 'feature_name';

  List<Map> _getSelectedFeatures(String nameKey) {
    if (paginated) {
      return selectionsForPaginated.map<Map>((e) {
        return {...e, 'feature_name': e[nameKey]};
      }).toList();
    }
    return _dataSource!.whereIndexed((element, index) => selections![index] ?? false).map<Map>((e) {
      return {...e, 'feature_name': e[nameKey]};
    }).toList();
  }

  void set dataSource(List<Map>? data) {
    _dataSource = data ?? []; //!.map<RowDataItem>((e) => RowDataItem(e, id: e[nameKey] ?? '')).toList();
    selectionsForPaginated.clear();
    selections = {};
  }

  bool get isColumnFilterEmpty => columnFilters == null || columnFilters!.length == 0;

  bool get isEmpty => count == 0;

  int get count => dataSource?.length ?? 0;

  void clear() {
    _dataSource?.clear();
    columnFilters?.clear();
    // _dataSource = null;
    selections?.clear();
    selectionsForPaginated.clear();
    filterColumnKey = null;
    filterColumnValue = null;
    searchBy = null;
    searchKeyword = null;
  }

  void paginatedSelectChange(Map rowItem, bool checked) {
    var find = selectionsForPaginated.firstWhereOrNull((e) => e == rowItem);
    if (find != null && !checked) {
      selectionsForPaginated.remove(find);
    } else if (checked && find == null) {
      selectionsForPaginated.add(rowItem);
    }
    rowSelectionsObs.value = selectionsForPaginated.length > 0;
  }
}

class CellMarkerFeatureState extends AbsTableDataState {
  CellMarkerFeatureState() {
    nameKey = 'feature';
    paginated = true;
  }

  CancelToken? _cancelToken;

  Future<CancelToken> newCancelToken() async {
    _cancelToken?.cancel();
    return Future.delayed(Duration(milliseconds: 100), () => CancelToken());
  }

  void cancelSearch() {
    super.cancelSearch();
    _cancelToken?.cancel();
  }

  void cancelRequest() {
    _cancelToken?.cancel();
  }

  List<Map> get selectedFeatures {
    return _getSelectedFeatures(nameKey);
  }

  void set headers(List<String>? hs) {
    if (hs != null && hs.length > 0) {
      hs.remove('image_url');
      hs.remove('image_id');
      if (hs.contains('thumb_image_url')) {
        hs.remove('thumb_image_url');
        hs.add('thumb_image_url');
      }
    }
    _headers = hs;
    _autoLoadNameKey();
  }

  void _autoLoadNameKey() {
    if (_headers!.contains('feature_name'))
      nameKey = 'feature_name';
    else if (_headers!.contains('feature'))
      nameKey = 'feature';
    else if (_headers!.contains('gene'))
      nameKey = 'gene';
    else if (_headers!.contains('names'))
      nameKey = 'names';
    else if (_headers!.contains('name'))
      nameKey = 'name';
    else
      nameKey = _headers!.first;
  }

  @override
  String get emptyMsg => 'Empty Feature List';
}

class CellMarkerGeneState extends AbsTableDataState {
  CellMarkerGeneState() {
    nameKey = 'gene';
    paginated = true;
  }

  List<Map> get selectedFeatures {
    return _getSelectedFeatures('gene');
  }

  void set headers(List<String>? hs) {
    if (hs != null && hs.length > 0) {
      hs.remove('image_url');
      hs.remove('image_id');
      if (hs.contains('thumb_image_url')) {
        hs.remove('thumb_image_url');
        hs.add('thumb_image_url');
      }
    }
    _headers = hs;
  }

  @override
  String get emptyMsg => 'No marker gene';
}

class CellMarkerMotifState extends AbsTableDataState {
  CellMarkerMotifState() {
    nameKey = 'motif';
    paginated = true;
  }

  List<Map> get selectedFeatures {
    return _getSelectedFeatures('motif');
  }

  void set headers(List<String>? hs) {
    if (hs != null && hs.length > 0) {
      hs.remove('image_url');
      hs.remove('image_id');
      if (hs.contains('thumb_image_url')) {
        hs.remove('thumb_image_url');
        hs.add('thumb_image_url');
      }
    }
    _headers = hs;
  }

  @override
  String get emptyMsg => 'No marker motif';
}

class CellMarkerPeakState extends AbsTableDataState {
  CellMarkerPeakState() {
    nameKey = 'peak_name';
    paginated = true;
  }

  List<Map> get selectedFeatures {
    return _getSelectedFeatures('peak_name');
  }

  void set headers(List? hs) {
    _headers = List.from(hs!);
    _headers!
      ..remove('peak_start')
      ..remove('peak_end');
    _headers!.add('peak_coverage');
  }

  @override
  String get emptyMsg => 'No marker peak';
}

class CellClusterMetaState extends AbsTableDataState {
  CellClusterMetaState() {
    nameKey = 'cluster';
  }

  CancelToken? _cancelToken;

  Future<CancelToken> newCancelToken() async {
    _cancelToken?.cancel();
    return Future.delayed(Duration(milliseconds: 300), () => CancelToken());
  }

  void cancelRequest() {
    _cancelToken?.cancel();
  }

  List<Map> get selectedFeatures {
    return _getSelectedFeatures('_');
  }

  void set headers(List<String>? hs) {
    _headers = hs;
  }

  @override
  String get emptyMsg => 'No cluster meta';
}

class SelectedFeatureState extends AbsTableDataState {
  SelectedFeatureState() {
    nameKey = 'cell';
    _headers = ['cell', 'x', 'y'];
  }

  @override
  String get emptyMsg => 'No selected feature';

  @override
  List<Map> get selectedFeatures => _getSelectedFeatures(nameKey);
}

class SpatialSliceState extends AbsTableDataState {
  List<Spatial>? _data;

  List<Spatial>? get data => _data;

  void set data(List<Spatial>? data) {
    this._data = data;
  }

  Spatial? selectedSlice;

  @override
  String get emptyMsg => 'no spatial slice';

  @override
  List<Map> get selectedFeatures => [];
}

class FeatureExpressionState extends AbsTableDataState {
  List<FeatureHistoryItem> features = [];

  void setData(List<FeatureHistoryItem> features) {
    this.features.clear();
    this.features.addAll(features);
  }

  @override
  int get count => this.features.length;

  @override
  void clear() {
    super.clear();
    features.clear();
  }

  @override
  String get emptyMsg => 'Feature expression is empty';

  @override
  List<Map> get selectedFeatures => [];
}
