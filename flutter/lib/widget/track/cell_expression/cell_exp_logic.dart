import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/bean/track_param.dart';
import 'package:flutter_smart_genome/cell/data_category.dart';
import 'package:flutter_smart_genome/d3/color/schemes.dart';
import 'package:flutter_smart_genome/util/logger.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/painter/feature_data.dart';
import 'package:get/get.dart';

class CellExpLogic extends GetxController {
  List<CellExpFeature>? _data;
  FeatureData<CellExpFeature> _featureData = FeatureData([]);

  double _featureVisibleScale = 0.05;
  late String _currentGroup;

  double get featureVisibleScale => _featureVisibleScale;

  String get currentGroup => _currentGroup;

  late ValueNotifier<String> groupObs;

  bool hideNone = false;

  void set currentGroup(String group) {
    _currentGroup = group;
    _initColorMap();
  }

  FeatureData<CellExpFeature> get featureData => _featureData;

  List<CellExpFeature>? get data {
    if (hideNone) return _data?.where((e) => e.values!.any((v) => v != 0)).toList();
    return _data;
  }

  void set data(List<CellExpFeature>? data) => _data = data;

  bool get dataEmpty => _data == null || _data!.isEmpty;

  CellExpLogic() {}

  late Track _track;
  MatrixBean? matrix;

  void init(TrackParams trackParams) {
    _track = trackParams.track;
    Map statics = _track.getStatic(trackParams.chrId);
    // print('------------');
    // print(_track.cellGroup);
    // print(_track.scId);
    // print(_track.scName);

    matrix = _track.matrixList?.first;

    if (matrix != null) _currentGroup = matrix!.groups.first;
    groupObs = ValueNotifier<String>(_currentGroup);
    // final avgSize = trackParams.chr.size / statics['feature_count'];
    var _avgFeatureLength = statics['average_f_length'] ?? 12000.0;
    _featureVisibleScale = (1 / (_avgFeatureLength * 10 / 1000.0)).clamp(0.001, 0.05);
    logger.d('${trackParams.track.trackName} ${_featureVisibleScale}  => $statics');
    _initColorMap();
  }

  void _initColorMap() {
    //todo
    List categories = matrix!.getClusters(_currentGroup);
    List<Color> colors = safeSchemeColor(categories.length, s: .8, v: .65);
    _colorMap = categories.asMap().map<String, Color>((idx, key) {
      return MapEntry('${key}', colors[idx]);
    });
  }

  //todo
  List get categories {
    MatrixBean matrix = _track.matrixList!.first;
    return matrix.getClusters(_currentGroup);
    // _track.cellGroup[_currentGroup] ?? [];
  }

  // void onColorByGroupChange(String group, [bool fromCellToolbar = false]) {
  //   _currentGroup = group;
  //   update();
  //   _data?.clear();
  //   _data = null;
  //
  //   if (!fromCellToolbar) {
  //     CellToolBarLogic.safe()?.onChangeGroup(group);
  //   }
  // }

  Map<String, Color>? _colorMap;

  Map<String, Color>? get colorMap => _colorMap;

  void onColorChange(List<DataCategory> cats) {
    _colorMap = Map.fromIterables(cats.map((e) => '${e.name}'), cats.map((e) => e.color));
    update();
  }

  void clearData() {
    _data?.clear();
    _data = null;
  }

  @override
  void onClose() {
    super.onClose();
    clearData();
    groupObs.dispose();
    // groupObs = null;
  }

  static CellExpLogic? safe({String? tag}) {
    if (Get.isRegistered<CellExpLogic>(tag: tag)) {
      return Get.find<CellExpLogic>(tag: tag);
    }
    return null;
  }
}
