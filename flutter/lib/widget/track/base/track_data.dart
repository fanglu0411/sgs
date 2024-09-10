import 'dart:math' show Random, max, min;
import 'package:dartx/dartx.dart' as dx;
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/d3/color/schemes.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_smart_genome/widget/track/common.dart';

import 'types.dart';

enum TrackType {
  ref_seq,
  eqtl,
  gff,
  vcf,
  vcf_coverage,
  vcf_sample,
  bigwig,
  bam,
  bam_coverage,
  bam_reads,
  bed,
  hic,
  interactive,
  methylation,
  peak,
  sc_exp,
  sc_co_access,
  sc_transcript,
  sc_group_coverage,
  sc_atac,
  sc,
  // combine,
  unknown,
}

List<Color> trackColorsDark = schemeRainbowDark(TrackType.values.length);
// rc.RandomColor().randomColors(
//   count: TrackType.values.length,
//   colorSaturation: rc.ColorSaturation.highSaturation,
//   colorBrightness: rc.ColorBrightness.primary,
// );
List<Color> trackColorsLight = schemeRainbowLight(TrackType.values.length);
//     rc.RandomColor().randomColors(
//   count: TrackType.values.length,
//   colorSaturation: rc.ColorSaturation.mediumSaturation,
//   colorBrightness: rc.ColorBrightness.primary,
// );

Map<TrackType, Color> get trackTypeColorMapper => Map.fromIterables(TrackType.values, Get.isDarkMode ? trackColorsLight : trackColorsDark);

TrackType getTrackTypeByIndex(int index) {
  if (index < TrackType.values.length) {
    return TrackType.values[index];
  }
  return TrackType.unknown;
}

String trackTypeString(TrackType trackType) {
  return '${trackType}'.split('\.')[1];
}

TrackType parseTrackType(String? type) {
  if (type == null) return TrackType.unknown;
  if (type.contains('gff')) {
    return TrackType.gff;
  }
  if (type.contains('ref_seq')) {
    return TrackType.ref_seq;
  }
  if (type.contains('vcf_sample')) {
    return TrackType.vcf_sample;
  }
  if (type.contains('vcf_coverage')) {
    return TrackType.vcf_coverage;
  }
  if (type == 'vcf') {
    return TrackType.vcf;
  }
  if (type.contains('big') || type.contains('wig')) {
    return TrackType.bigwig;
  }
  if (type == 'bam') {
    return TrackType.bam;
  }
  if (type.contains('bam_coverage')) {
    return TrackType.bam_coverage;
  }
  if (type.contains('bam_reads')) {
    return TrackType.bam_reads;
  }
  if (type.contains('methy')) {
    return TrackType.methylation;
  }
  if (type.contains('interactive')) {
    return TrackType.interactive;
  }
  if (type.contains('hic')) {
    return TrackType.hic;
  }
  if (type.contains('sc_cluster_histo') || type.contains('sc_exp') || type.contains('single_cell_exp')) {
    return TrackType.sc_exp;
  }
  if (type.contains('peak')) {
    return TrackType.peak;
  }
  if (type.contains('sc_co_access')) {
    return TrackType.sc_co_access;
  }
  if (type.contains('sc_group_coverage')) {
    return TrackType.sc_group_coverage;
  }
  if (type.contains('sc_transcript')) {
    return TrackType.sc_transcript;
  }
  if (type == 'sc_atac') {
    return TrackType.sc_atac;
  }
  if (type.contains('bed')) {
    return TrackType.bed;
  }
  if (type.contains('eqtl')) {
    return TrackType.eqtl;
  }
  if (type == 'sc') {
    return TrackType.sc;
  }
  // if (type.contains('combine')) {
  //   return TrackType.combine;
  // }

  return TrackType.unknown;
}

TrackType getTrackType(String filename) {
  String ext = path.extension(filename);
  if (['gff', 'gff3'].contains(ext)) {
    return TrackType.gff;
  }
  if (['fasta'].contains(ext)) {
    return TrackType.ref_seq;
  }
  if (['vcf'].contains(ext)) {
    return TrackType.vcf_coverage;
  }
  if (['bigwig'].contains(ext)) {
    return TrackType.bigwig;
  }
  if (['bam'].contains(ext)) {
    return TrackType.bam;
  }
  return TrackType.unknown;
}

/// the track data
abstract class TrackData {
  Track? track;

  String? get trackName => track?.trackName;

  String? get type => track?.bioType;
  String? message;

  Range? dataRange;

  TrackData({this.track, this.dataRange, this.message = ''});

  bool get isEmpty;

  void clear();
}

class BaseTrackData extends TrackData {
  @override
  bool get isEmpty => true;

  @override
  void clear() {}
}

class FeatureMetaHeaderManager {
  static FeatureMetaHeaderManager _instance = FeatureMetaHeaderManager._init();

  FeatureMetaHeaderManager._init() {}

  factory FeatureMetaHeaderManager() {
    return _instance;
  }

  Map metaHeaderCache = {};

  Map? operator [](trackType) => metaHeaderCache[trackType];

  void operator []=(trackType, Map headerMap) {
    metaHeaderCache[trackType] = headerMap;
  }
}

const List orderedFeatureTypes = [
  'intron',
  'exon',
  'five_prime_utr',
  'three_prime_utr',
  'cds',
  'thick',
  'block',
];

int featureSortFunction(Feature a, Feature b) {
  return orderedFeatureTypes.indexOf(a.type.toLowerCase()) - orderedFeatureTypes.indexOf(b.type.toLowerCase());
}

enum TrackViewType {
  cartesian,
  block,
  feature,
}

const childrenTrackOrder = {
  TrackType.sc_group_coverage: 0,
  TrackType.peak: 1,
  TrackType.sc_co_access: 2,
  TrackType.sc_exp: 3,
  TrackType.vcf_coverage: 4,
  TrackType.vcf_sample: 5,
  TrackType.bam_coverage: 6,
  TrackType.bam_reads: 7,
};

int _trackSortFun(Track a, Track b) {
  return (childrenTrackOrder[a.trackType] ?? 0) - (childrenTrackOrder[b.trackType] ?? 0);
}

class Track {
  int? dbId;
  String? id;
  late String trackName;
  late String bioType;
  String? category;
  String? description;
  String? status;
  String? parentId;

  bool isCustom = false;
  bool pinTop = false;

  bool subTrack = false;

  List<Track>? children;

  int? progress;

  List<Track> get checkedChildren => (children ?? []).where((t) => t.checked).toList();

  Track? parent;

  List? statics;

  bool checked = true;

  void set checkWithChildren(bool check) {
    checked = check;
    if (children == null) return;
    children!.forEach((c) => c.checked = check);
  }

  late TrackType trackType;

  bool get statusDone => status == 'done';

  bool get statusError => status == 'error';

  bool get hasChildren => (children?.length ?? 0) > 0;

  bool paired = false;

  String get key => '${bioType}-$id-${paired}';

  bool get isSubTrack => parentId != null && parentId!.length > 0 && !hasChildren;

  String get name => ((trackName.length == 0) ? null : trackName) ?? _scName ?? bioType;

  bool expanded = true;

  //sc props
  // Map? _cellGroup;
  String? _scId;
  String? _scName;

  // List? _plots;
  List<MatrixBean>? _matrixList;

  // Map get cellGroup => _cellGroup ?? parent?._cellGroup ?? {};

  String? get scId => _scId ?? parent?._scId;

  String? get scName => _scName ?? parent?._scName;

  // List? get plots => _plots ?? parent?._plots;

  List<MatrixBean>? get matrixList => _matrixList ?? parent?._matrixList;

  bool get childrenCheckedAll => children == null ? checked : children!.every((t) => t.checked);

  bool get childrenHasChecked => children == null ? checked : children!.any((t) => t.checked);

  // bool get isScTrack => scId != null;

  factory Track.fromMap(Map e, [bool subTrack = false]) {
    List? children = e['children'];
    List<Track> _children = (children ?? []).map((e) => Track.fromMap(e, true)).toList();
    _children.sort(_trackSortFun);
    // Map cellData = e['single_cell'] ?? {};
    // List? __matrixList = cellData['matrix_list'];
    List? __matrixList = e['mod'];
    return Track(
      id: e['track_id'] ?? e['sc_id'],
      trackName: e['track_name'] ?? e['label'] ?? e['name'] ?? '',
      bioType: e['bio_type'],
      category: e['view_type'],
      isCustom: e['isCustom'] ?? false,
      description: e['description'],
      children: _children,
      statics: e['statistic'],
      status: e['status'],
    )
      ..progress = e['progress']
      ..subTrack = subTrack
      ..dbId = e['id']
      ..parentId = e['parent_id']
      // .._cellGroup = cellData['cell_groups'] // cell props
      // .._plots = cellData['plots'] ?? []
      // .._scId = cellData['sc_id']
      // .._scName = cellData['sc_name']
      .._scId = e['sc_id']
      .._scName = e['sc_name']
      .._matrixList = __matrixList?.map<MatrixBean>((e) => MatrixBean(e)).where((m) => m.valid).toList();
  }

  bool get isReference => trackType == TrackType.ref_seq || bioType == 'ref_seq';

  bool get isBamCoverage => trackType == TrackType.bam_coverage || bioType.contains('bam_coverage');

  bool get isBamReads => trackType == TrackType.bam_reads || bioType.contains('bam_reads');

  bool get isBed => trackType == TrackType.bed || bioType.contains('bed');

  bool get isVcfCoverage => trackType == TrackType.vcf_coverage || bioType.contains('vcf_coverage');

  bool get isVcfSample => trackType == TrackType.vcf_sample || bioType.contains('vcf_sample');

  bool get isBigWig => trackType == TrackType.bigwig || bioType.contains('big') || bioType.contains('wig');

  bool get isGff => trackType == TrackType.gff || bioType.contains('gff');

  bool get isMethylation => trackType == TrackType.methylation || bioType.contains('methy');

  bool get isHic => trackType == TrackType.hic || bioType.contains('hic');

  bool get isInteractive => trackType == TrackType.interactive || bioType.contains('hic_interval');

  bool get isCellExp => trackType == TrackType.sc_exp || bioType.contains('sc_cluster_histo');

  bool get isPeak => trackType == TrackType.peak || bioType.contains('peak');

  bool get isCoAccess => trackType == TrackType.sc_co_access || bioType.contains('co_access');

  bool get isGroupCoverage => trackType == TrackType.sc_group_coverage;

  bool get isEqtl => trackType == TrackType.eqtl;

  bool get isCombineTrack => category == 'combine' || hasChildren;

  bool get isSCTrack => scId != null; // trackType == TrackType.sc_transcript || trackType == TrackType.sc_atac;

  double get defaultTrackHeight {
    if (isGff) return 200;
    if (isBigWig) return 80;
    if (isVcfSample) return 22;
    if (isVcfCoverage) return 100;
    if (isInteractive) return 120;
    if (isPeak) return 20;
    return 100;
  }

  Map getStatic(String chrId) {
    return (statics ?? []).firstWhere((e) => '${e['chr_id']}' == chrId, orElse: () => {});
  }

  Map toJson() {
    return {
      'track_id': id,
      'track_name': trackName,
      'track_type': bioType,
      'description': description,
    };
  }

  Track({
    this.id,
    required this.trackName,
    required this.bioType,
    this.category,
    this.isCustom = false,
    this.description,
    this.children = const [],
    this.statics,
    this.status,
  }) {
    trackType = parseTrackType(bioType);
    this.children?.forEach((t) => t.parent = this);
  }

  Track.refSeqTrack() {
    id = 'ref_seq';
    trackName = 'Reference sequence';
    bioType = 'ref_seq';
    isCustom = false;
    status = 'done';
    trackType = TrackType.ref_seq;
  }

  @override
  String toString() {
    return 'Track{id: $id, trackName: $trackName, type: $bioType, statistic: $statics}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Track &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          trackName == other.trackName &&
          bioType == other.bioType &&
          category == other.category &&
          description == other.description &&
          isCustom == other.isCustom;

  @override
  int get hashCode => id.hashCode ^ trackName.hashCode ^ bioType.hashCode ^ category.hashCode ^ description.hashCode ^ isCustom.hashCode;
}

// class CellTrack extends Track {
//   Map cellGroup;
//   String scId;
//   String scName;
//   List plots;
//
//   @override
//   String get name => scName != null && scName.length > 0 ? scName : trackName;
//
//   factory CellTrack.fromMap(Map e, [bool subTrack = false]) {
//     List children = e['children'];
//     List<Track> _children = (children ?? []).map((e) => Track.fromMap(e, true)).toList();
//     return CellTrack(
//       id: '${e['track_id']}',
//       trackName: e['track_name'] ?? e['label'] ?? e['name'],
//       type: e['track_type'] ?? '${e['track_id']}',
//       category: e['category'],
//       isCustom: e['isCustom'] ?? false,
//       description: e['description'],
//       children: _children,
//       statics: e['statistics'],
//       status: e['status'],
//     )
//       ..subTrack = subTrack
//       ..dbId = e['id']
//       ..parentId = e['parent_id']
//       ..cellGroup = e['cell_groups'] ?? {}
//       ..plots = e['plots'] ?? []
//       ..scId = e['sc_id']
//       ..scName = e['sc_name'];
//   }
//
//   CellTrack({
//     String id,
//     String trackName,
//     String type,
//     String category,
//     bool isCustom = false,
//     String description,
//     List<Track> children = const [],
//     List statics,
//     String status,
//   }) : super(
//           id: id,
//           trackName: trackName,
//           type: type,
//           category: category,
//           isCustom: isCustom,
//           description: description,
//           children: children,
//           statics: statics,
//           status: status,
//         );
// }

class CustomTrack extends Track {
  String? url;
  String? file;
  String? indexFile;

  CustomTrack({
    required String trackName,
    required String type,
    String? category,
    this.url,
  }) : super(
          trackName: trackName,
          bioType: type,
          category: category,
          isCustom: true,
        );

  CustomTrack.fromMap(Map map) : super(trackName: map['track_name'], bioType: map['track_type']) {
    String filePath = map['track_file'];
    id = filePath != null ? '${filePath.hashCode}' : '${Random().nextInt(10000) * Random().nextInt(10000)}';
    // trackName = map['track_name'];
    // bioType = map['track_type'];
    url = map['url'];
    category = map['category'];
    isCustom = true;
    description = map['description'];
    file = map['track_file'];
    indexFile = map['index_file'];
  }

  @override
  String toString() {
    return 'CustomTrack{id: ${id}, name: $trackName, url: $url, type: $bioType, description:$description}';
  }
}

class ClusterGroup {
  ClusterGroup(this.name, this.clusters, this.type);

  String name;
  String type;
  List clusters;
}

class SpatialSlice {
  Map _source;
  String resolution;

  SpatialCordScaleType? _fixType;

  SpatialCordScaleType get cordScaleBy {
    if (null == _fixType) initCordScale();
    return _fixType ?? SpatialCordScaleType.width;
  }

  bool get hasInitialCordScale => _fixType != null;

  void set cordScaleBy(SpatialCordScaleType cordScaleBy) {
    _fixType = cordScaleBy;
  }

  SpatialSlice(this._source, this.resolution) {
    _size = Size.zero;
  }

  String get image => _source['image_url'];

  num get scaleFactor => _source['scalef'];

  late Size _size;

  Size get size => _size;

  String? get sizeStr => _size.isEmpty ? null : '${_size.width.toStringAsFixed(0)}x${_size.height.toStringAsFixed(0)}';

  double get bigSize => max(_size.width, _size.height);

  double get smallSize => min(_size.width, _size.height);

  void set size(Size size) {
    this._size = size;
    initCordScale();
  }

  void initCordScale() {
    if (!hasSize) return;
    if (size.width / size.height < 1.25) {
      _fixType = SpatialCordScaleType.height;
    } else {
      _fixType = SpatialCordScaleType.width;
    }
  }

  bool get hasSize => !_size.isEmpty;

  //calculate canvas size by scale type and image
  Size toCanvasSize(Size viewport) {
    if (!hasSize) return Size.zero;
    Size destinationSize;
    if (viewport.width / viewport.height > _size.width / _size.height) {
      destinationSize = Size(_size.width * viewport.height / _size.height, viewport.height);
    } else {
      destinationSize = Size(viewport.width, _size.height * viewport.width / _size.width);
    }
    switch (_fixType!) {
      case SpatialCordScaleType.width:
        return Size(destinationSize.width, destinationSize.width);
      case SpatialCordScaleType.height:
        return Size(destinationSize.height, destinationSize.height);
      case SpatialCordScaleType.both:
        return Size(destinationSize.width, destinationSize.height);
    }
  }

  List<int> calculateCordRange() {
    return [
      size.width ~/ scaleFactor,
      size.height ~/ scaleFactor,
    ];
  }

  List<int> calculateCordRangeByShortSide() {
    return [
      size.shortestSide ~/ scaleFactor,
      size.shortestSide ~/ scaleFactor,
    ];
  }

  List<int> calculateCordRangeByLongSide() {
    return [
      size.longestSide ~/ scaleFactor,
      size.longestSide ~/ scaleFactor,
    ];
  }
}

class Spatial {
  static final String SPATIAL_PLOT = 'spatial';

  late String key;
  late Map resolutions;

  SpatialSlice? hi;
  SpatialSlice? low;

  late String _currentResolution;

  Spatial({required this.key, required Map resolutions}) {
    if (resolutions[hires] != null) hi = SpatialSlice(resolutions[hires], 'hires');
    if (resolutions[lowers] != null) low = SpatialSlice(resolutions[lowers], 'lowres');
    _currentResolution = safeSlice.resolution;
  }

  void changeCurrentResolution(String resolution) {
    _currentResolution = resolution;
  }

  SpatialSlice get currentSlice {
    if (_currentResolution == lowers) {
      return low!;
    }
    if (_currentResolution == hires) {
      return hi!;
    }
    return safeSlice;
  }

  SpatialSlice get safeSlice => (hi ?? low)!;

  SpatialSlice get safeLowSlice => (low ?? hi)!;

  String get hires => 'hires';

  String get lowers => 'lowres';

  bool get hasHires => hi != null;

  List<SpatialSlice> get slices => [
        if (hi != null) hi!,
        if (low != null) low!,
      ];
}

class MatrixBean extends MapBean {
  /// {mod_id, cell_groups: { type,value } }
  MatrixBean(Map source) : super(source) {
    Map? spatial_res = this['spatial_images'];
    if (null != spatial_res) {
      spatials = spatial_res.keys.map((e) => Spatial(key: e, resolutions: spatial_res[e])).toList();
    }
    Map _groups = this['cell_groups'];
    _groups.removeWhere((key, value) => value['value'].length == 0 || (value['type'] == 'num' && value['value'].contains('NaN')));
    _groups.forEach((key, value) {
      if (value['value'].length == 0) {
        value['invalid'] = true;
      }
      if (value['type'] == 'num') {
        try {
          value['range'] = [...value['value']];
          var rst = _cartesian2category(value['range'], 5);
          value['value'] = rst[0];
          value['avg'] = rst[1];
        } catch (e) {
          value['invalid'] = true;
        }
      }
    });
    _valid = _groups.length > 0;
  }

  MatrixBean.fromFile(Map source) : super(source) {}

  List<Spatial>? spatials;

  bool _valid = true;

  bool get valid => _valid;

  bool get hasSpatials => spatials != null && spatials!.length > 0;

  Map<String, ClusterGroup> __groups = {};

  String get type => this['type'] ?? '-';

  bool get isPeakMatrix => type == 'peak' || name.toLowerCase().contains('peak');

  bool get isMotifMatrix => type == 'motif' || name.toLowerCase().contains('motif');

  bool get isGeneMatrix => type == 'gene' || !(isPeakMatrix || isMotifMatrix);

  String get id => this['mod_id'];

  String get name => this['mod_name'] ?? id;

  @override
  String toString() {
    return name;
  }

  List get plots => this['plots'] ?? [];

  String? get firstPlot => plots.length > 0 ? plots.first : null;

  Map<String, List> get groupMap {
    Map groups = this['cell_groups'];
    return groups.map((key, value) => MapEntry(key, value['value']));
  }

  List<String> get orderedGroupList {
    Map groups = this['cell_groups'];
    return groups.keys.sortedBy((g) => groups[g]['type']).thenBy((g) => g).map<String>((e) => '$e').toList();
  }

  double getGroupAvg(String group) {
    Map groups = this['cell_groups'];
    return groups[group]['avg'];
  }

  Map<String, List> get categories {
    Map groups = this['cell_groups'];
    var cats = groups.filter((entry) => entry.value['type'] == 'list');
    return cats.map((key, value) => MapEntry(key, value['value']));
  }

  void setGroupClusters(String group, List clusters) {
    Map groups = this['cell_groups'];
    groups[group]['value'] = clusters;
  }

  List get groups {
    Map groups = this['cell_groups'];
    return groups.keys.toList();
  }

  List getClusters(group) {
    Map groups = this['cell_groups'];
    return groups[group]?['value'] ?? [];
  }

  String getGroupType(group) {
    Map groups = this['cell_groups'];
    return groups[group]?['type'];
  }

  bool isCategory(String group) => getGroupType(group) == 'list';

  bool isCartesian(group) => getGroupType(group) == 'num';

  List _cartesian2category(List scope, int defCount) {
    Map<String, dx.DoubleRange> clusters = {};
    int count = scope[1] - scope[0] == 0 ? 1 : defCount;
    double avg = scope[1] - scope[0] == 0 ? scope[1].toDouble() : ((scope[1] - scope[0]) / count);
    if (avg > 1) avg = avg.ceilToDouble();
    // int nn = avg < .1 ? 3 : 2;
    for (int i = 0; i < count; i++) {
      double start = scope[0] + i * avg;
      dx.DoubleRange range = dx.DoubleRange(start, i < count - 1 ? (start + avg) : scope[1] * 1.0);
      clusters['[${start.toStringAsPrecision(3)}-${range.endInclusive.toStringAsPrecision(3)})'] = range;
    }
    return [clusters.keys.toList(), avg];
  }
}
