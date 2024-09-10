import 'package:flutter/foundation.dart';
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/network/core/http_error.dart';
import 'package:flutter_smart_genome/page/cell/cell_base.dart';
import 'package:flutter_smart_genome/page/cell/cell_page/cell_page_logic.dart';
import 'package:flutter_smart_genome/page/compare/compare_logic.dart' show CompareElement;
import 'package:flutter_smart_genome/service/sgs_app_service.dart';
import 'package:flutter_smart_genome/service/single_cell_service.dart';
import 'package:get/get.dart';
import 'package:dartx/dartx.dart' as dx;

import 'compare_group_view.dart';

class CompareGroupLogic extends GetxController {
  static CompareGroupLogic? find({String? tag}) {
    if (Get.isRegistered<CompareGroupLogic>(tag: tag)) return Get.find<CompareGroupLogic>(tag: tag);
    return null;
  }

  late CompareElement _compareElement;
  late List<Map> _features;

  List<Map> get features => _features;

  CompareGroupLogic({
    required CompareElement compareElement,
    required List<Map> features,
  }) {
    _compareElement = compareElement;
    _features = features;
  }

  void setFeatures(List<Map> features) {
    this._features = features;
    loadData();
  }

  bool _loading = true;
  HttpError? _error;
  List? _data;

  List? get data => _data;

  bool get loading => _loading;

  HttpError? get error => _error;

  CompareElement get compareElement => _compareElement;

  String get matrix => _compareElement.matrix;

  bool _scaleGrouped = false;

  bool get scaleGrouped => _scaleGrouped;

  void set matrix(String matrix) {
    _compareElement.matrix = matrix;
  }

  String get group => _compareElement.category;

  void set group(String group) {
    _compareElement.category = group;
  }

  D? findFeatureItem<D>(String gene) {
    return _data!.firstOrNullWhere((item) => (item is RangeFeature ? item.name : item['feature_name']) == gene);
  }

  @override
  void onReady() {
    super.onReady();
    loadData();
  }

  List<String> get featureNames => _features.map<String>((e) => e['feature_name']).toList();

  void _loadFeatureStructure() async {
    _loading = false;
    _error = null;
    _data = _features.map((e) {
      return {
        'name': e['feature_name'],
        ...e,
      };
    }).toList();
    update();

    var site = SgsAppService.get()!.site!;
    var pageLogic = CellPageLogic.safe();
    var resp = await loadGeneStructures(host: site.url, scId: pageLogic!.track!.scId!, features: featureNames);
    if (resp.success) {
      List<RangeFeature> structures = resp.body;
      if (structures.length == _features.length) {
        _data = structures;
        update();
      }
    } else {}
  }

  void loadData() async {
    if (_compareElement.type == SCViewType.feature) {
      _loadFeatureStructure();
      return;
    } else if (_compareElement.type == SCViewType.coverage) {
      //render by every item data
      _data = _features;
      _loading = false;
      update();
      return;
    } else if (_compareElement.type == SCViewType.motif || _compareElement.type == SCViewType.violin) {
      //render by every item data
      _data = _features;
      _loading = false;
      update();
      return;
    }
    // else if (_compareElement.type == SCViewType.dotplot) {
    //   _data = _features;
    //   _loading = false;
    //   update();
    //   return;
    // }

    var site = SgsAppService.get()!.site;
    final pageLogic = CellPageLogic.safe();

    _loading = true;
    _error = null;

    update();
    // await Future.delayed(Duration(seconds: 5));

    var resp = await loadCompareFeatureImages(
      host: site!.url,
      scId: CellPageLogic.safe()!.track!.scId!,
      genes: featureNames,
      matrix: _compareElement.matrix,
      group: _compareElement.category,
      plotType: _compareElement.plotType,
      chartType: chartTypeString(_compareElement.type),
    );
    _loading = false;
    if (resp.success) {
      List images = resp.body;
      // List<String> _images = images.map((e) => '${site.url}${e['thumb_image_url']}').toList();
      _data = images;
    } else {
      _error = resp.error;
    }
    update();
  }

  void didUpdateWidget(CompareGroupView oldWidget, CompareGroupView widget) {
    bool reload = widget.compareElement != _compareElement || (!listEquals(_features, widget.features));
    _compareElement = widget.compareElement;
    _features = widget.features;
    if (reload) {
      featureCoverageMaxValue.clear();
      _scaleGrouped = false;
      loadData();
    }
  }

  String chartTypeString(SCViewType type) {
    return type.name;
  }

  Map<String, double> featureCoverageMaxValue = {};

  double get featureGroupCoverageMaxValue => featureCoverageMaxValue.values.max()!;

  void onGetFeatureMaxValue(item, double v) {
    if (_scaleGrouped) return;
    featureCoverageMaxValue[item['feature_name']] = v;
    if (featureCoverageMaxValue.length == _features.length) {
      _scaleGrouped = true;
      Future.delayed(Duration(milliseconds: 300)).then((value) {
        update();
      });
    }
  }
}
