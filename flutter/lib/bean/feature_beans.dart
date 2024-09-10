import 'package:dartx/dartx.dart' as dx;
import 'package:flutter/material.dart' show Rect, Color, Offset, Path;
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';
import 'package:pretty_json/pretty_json.dart';
import 'package:uuid/uuid.dart';

abstract class MapBean {
  Map _source;

  MapBean(this._source);

  operator [](key) {
    return _source[key];
  }

  Map get source => _source;
}

const _uuid = Uuid();

class Feature {
  List toListMap(List list, featureType) {
    List? header = findMeta(featureType);
    return list.map<Map>((_list) {
      return header!.asMap().map((index, key) => MapEntry(key, _list[index]));
    }).toList();
  }

  List? findMeta(String? type, [Map? metaHeader]) {
    if (type == null) return null;
    var _metaHeader = (metaHeader ?? this.metaHeader);
    if (null == _metaHeader) return [];
    return _metaHeader[type];
  }

  Map get json {
    Map _json = toJson();
    return _json;
  }

  List<Feature>? _children;
  List<Feature>? _subFeatures;

  String? trackType;
  String? featureType;
  String? _uniqueId;

  String get uniqueId => _uniqueId ?? featureId;

  List? __dataSource;
  Map? _dataSource;
  Rect? _groupRect;
  Rect? _rect;
  late double _labelWidth;

  int get childrenCount => (_children ?? []).length;

  int get childrenCountFlat {
    return _childCount(this);
  }

  int _childCount(Feature feature) {
    int count = 0;
    for (Feature child in (feature.children ?? [])) {
      if (child.hasChildren) {
        count += _childCount(child);
      } else {
        count += 1;
      }
    }
    return count;
  }

  List<Feature> get flatChildren {
    return _flatChildren(this);
  }

  List<Feature> _flatChildren(Feature feature) {
    List<Feature> _children = [feature];
    for (Feature child in (feature.children ?? [])) {
      if (child.hasChildren) {
        _children.addAll(_flatChildren(child));
      } else {
        _children.add(child);
      }
    }
    return _children;
  }

  Feature.fromMap(Map map, String trackType, [String featureType = 'feature']) {
    _dataSource = map;
    range = Range(start: -1, end: -1);
    // if (this.id == null) {
    //   _dataSource['id'] = UniqueKey().toString();
    // }
    // _uniqueId = _uuid.v5(null, trackType);
    _uniqueId = '${map.toString().hashCode}';
    this.trackType = trackType;
    parseChildrenAndSubFeature(featureType: featureType);
  }

  void parseChildrenAndSubFeature({String featureType = 'feature'}) {
    List list = this['children'] ?? [];
    _children = list.map<Feature>((e) => Feature.fromMap(e, trackType!)).toList();

    List _subFeature = this['sub_feature'] ?? this['sub_features'] ?? this['child_features'] ?? this['subfeature'] ?? [];
    List? _subFeatureMeta = findMeta('sub_feature') ?? findMeta('sub_features');
    String _featureType = null == _subFeatureMeta ? 'feature' : 'sub_feature';
    _subFeatures = _subFeature.map<Feature>((e) => Feature.fromMap(e, trackType!, _featureType)).toList();
  }

  Feature.empty() {
    range = Range(start: -1, end: -1);
  }

  int? index;
  int? row;
  late Range range;

  // Range get toZeroStartRange => Range(start: range.start - 1, end: range.end);
  Range get toZeroStartRange => range;

  Map? get metaHeader => FeatureMetaHeaderManager()[trackType];

  double get labelWidth => _labelWidth;

  void set labelWidth(double labelWidth) => _labelWidth = labelWidth;

  Rect? get rect => _rect;

  Rect? get groupRect => _groupRect;

  void set rect(Rect? rect) {
    _rect = rect;
  }

  void set groupRect(Rect? groupRect) => _groupRect = groupRect;

  Map get attributes => this['attributes'] ?? {};

  String get name => originName ?? '';

  String? get originName => this['feature_name'] ?? this['name'] ?? this['gene_name'] ?? attributes['Name']?.toString() ?? attributes['external_name']?.toString();

  String get featureId {
    String? id = this['feature_id'] ?? this['id'] ?? attributes['ID']?.toString();
    if (id == null || id.length == 0) {
      id = name;
    }
    return id;
  }

  String get type => this['type'] ?? this['feature_type'];

  int get strand {
    var _strand = this['strand'];
    if (_strand is num) return _strand as int;
    if (_strand == '+') return 1;
    if (_strand == '-' || _strand == '_') return -1;
    return 0;
  }

  bool get hasStrand => strand != 0;

  String get strandStr {
    int _strand = strand;
    if (_strand == 0) return '.';
    return _strand > 0 ? '+' : '-';
  }

  dynamic operator [](var k) {
    return _dataSource![k];
  }

  String printValue(String key) {
    var val = this[key];
    if (val is Map) {
      return val.keys.map((e) => '$e: ${val[e]}').join(' ');
    }
    return val;
  }

  bool get hasSubFeature => (_subFeatures?.length ?? 0) > 0;

  bool get hasChildren => (_children?.length ?? 0) > 0;

  List<Feature>? get children => _children;

  List<Feature>? get subFeatures => _subFeatures;

  Map toJson() {
    return _dataSource!;
  }

  String pretty() {
    return prettyJson(toJson(), indent: 4);
  }

  @override
  String toString() {
    return _dataSource.toString();
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is Feature && runtimeType == other.runtimeType && _dataSource == other._dataSource;

  @override
  int get hashCode => __dataSource.hashCode ^ _dataSource.hashCode;
}

class RangeFeature extends Feature {
  RangeFeature.onlyRange(Range _range) : super.fromMap({'start': _range.start, 'end': _range.end}, '') {
    range = _range;
  }

  ///
  /// RangeFeature from a map
  ///
  RangeFeature.fromMap(Map map, String trackType, [String featureType = 'feature']) : super.fromMap(map, trackType) {
    var start = this['start'] ?? this['ref_start'], end = this['end'] ?? this['ref_end'];
    if (start != null && end != null) {
      range = Range(start: start, end: end);
    }
    parseChildrenAndSubFeature(featureType: featureType);
  }

  @override
  void parseChildrenAndSubFeature({String featureType = 'feature'}) {
    List list = this['children'] ?? [];
    _children = list.map<RangeFeature>((e) => RangeFeature.fromMap(e, trackType!)).toList();

    List _subFeature = this['sub_feature'] ?? this['sub_features'] ?? this['child_features'] ?? this['subfeature'] ?? [];
    List? _subFeatureMeta = findMeta('sub_feature') ?? findMeta('sub_features');
    String _featureType = null == _subFeatureMeta ? 'feature' : 'sub_feature';
    _subFeatures = _subFeature.map<RangeFeature>((e) => RangeFeature.fromMap(e, trackType!, _featureType)).toList();
  }

  @override
  bool get hasSubFeature => _subFeatures != null && _subFeatures!.isNotEmpty;

  @override
  bool get hasChildren => _children != null && _children!.isNotEmpty;

  @override
  List<RangeFeature>? get children => _children as List<RangeFeature>;

  @override
  List<RangeFeature>? get subFeatures => _subFeatures as List<RangeFeature>;
}

class BedFeature extends RangeFeature {
  static const String ENHANCE_BLOCK_TYPE = 'enhance-block';

  BedFeature.fromMap(Map map, String trackType, [String featureType = 'feature']) : super.fromMap(map, trackType, featureType);

  String get viewType => this['view_type'];

  String get type => this['bio_type'] ?? this['view_type'] ?? super.type;

  String? get colorHex => this['color'];

  Color? get color {
    String? c = colorHex;
    if (c != null && c.isNotEmpty) {
      return Color(int.tryParse(c.substring(1), radix: 16)!).withAlpha(255);
    }
    return null;
  }

  @override
  void parseChildrenAndSubFeature({String featureType = 'feature'}) {
    List list = this['children'] ?? [];
    _children = list.map<RangeFeature>((e) => BedFeature.fromMap(e, trackType!)).toList();

    List _subFeature = this['sub_features'] ?? this['sub_feature'] ?? [];
    List? _subFeatureMeta = findMeta('sub_feature') ?? findMeta('sub_features');
    String _featureType = null == _subFeatureMeta ? 'feature' : 'sub_feature';
    _subFeatures = _subFeature.map<BedFeature>((e) => BedFeature.fromMap(e, trackType!, _featureType)).toList();
  }

  @override
  String toString() {
    return this._dataSource.toString();
  }
}

class BamReadsFeature extends RangeFeature {
  BamReadsFeature.fromMap(Map map, String trackType, [String featureType = 'feature']) : super.fromMap(map, trackType) {}

  bool get isUpStream => this.name.endsWith('R1');

  bool get isDownStream => this.name.endsWith('R2');

  bool get hasPair => (pair ?? '').length > 0;

  String? get pair => this['pair'];

  bool get hasGap => hasSubFeature && subFeatures!.where((f) => f['alt_type'] == 'line').length > 0;

  Feature? get gap => subFeatures?.firstOrNullWhere((f) => f['alt_type'] == 'line');

  List<Feature>? get gaps => subFeatures?.where((f) => f['alt_type'] == 'line').toList();

  String get nameWithoutPair {
    if (!hasPair) return this.name;
    return this.name.substring(0, this.name.length - 2);
  }

  List<Rect>? rects;

  Offset? linkTo;
}

class GffFeature extends RangeFeature {
//  static List meta = [
//    "feature_id",
//    "parents_id",
//    "source",
//    "feature_type",
//    "start",
//    "end",
//    "score",
//    "strand",
//    "attributes",
//    "sub_feature",
//    "children",
//  ];

  GffFeature.fromMap(Map map, String trackType) : super.fromMap(map, trackType) {}

  String get uniqueId => this['sgs_id'];

  @override
  String get featureId => this['feature_id'] ?? this['target_id'] ?? this['match_id'] ?? super.featureId;

  // @override
  // int get strand => this['strand'] == '+' ? 1 : -1;

  @override
  bool get hasChildren {
    return childrenCount > 0;
  }

  @override
  bool get hasSubFeature => (_subFeatures?.length ?? 0) > 0;
}

class CellExpFeature extends RangeFeature {
  List? values;

  // CellExpFeature(List list, String trackType) : super(list, trackType);
  CellExpFeature.fromMap(Map map, String trackType) : super.fromMap(map, trackType) {
    // range = Range(start: this['start'], end: this['end']);
    values = map['exp_value'];
  }

  String get name => this['gene_name'];
}

class RelationFeature extends RangeFeature {
  Range? left;
  Range? right;
  Path? path;

  RelationFeature.fromMap(Map map, String trackType) : super.fromMap(map, trackType);
}
