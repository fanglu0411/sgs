import 'package:flutter_smart_genome/widget/track/base/track_session.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';

class PositionInfo {
  String? name;
  String chrId;
  String chrName;
  String species;
  String speciesId;
  late Range range;
  dynamic strand;

  PositionInfo({
    this.name,
    required this.species,
    required this.speciesId,
    required this.chrId,
    required this.chrName,
    required this.range,
    this.strand,
  });

  String print() {
    return '$species, $chrName';
  }

  PositionInfo copy({String? name, String? chrId, String? chrName, String? species, String? speciesId, Range? range}) {
    return PositionInfo(
      name: name ?? this.name,
      chrId: chrId ?? this.chrId,
      chrName: chrName ?? this.chrName,
      species: species ?? this.species,
      speciesId: speciesId ?? this.speciesId,
      range: range ?? this.range,
      strand: this.strand,
    );
  }

  static PositionInfo? fromSession(TrackSession? session) {
    if (session == null) return null;
    return PositionInfo(
      chrId: session.chrId!,
      chrName: session.chrName!,
      species: session.speciesName!,
      speciesId: session.speciesId,
      range: session.range!,
    );
  }

  @override
  String toString() {
    return 'PositionInfo{chrId: $chrId, chrName: $chrName, speciesId: $speciesId, species: $species, range: $range}';
  }
}

class GeneInfo extends PositionInfo {
  String? gid;

  GeneInfo({
    this.gid,
    dynamic strand = '+',
    required Range range,
    String? name,
    required String species,
    required String speciesId,
    required String chrName,
    required String chrId,
  }) : super(
          name: name = gid,
          species: species,
          speciesId: speciesId,
          chrName: chrName,
          chrId: chrId,
          range: range,
        );

  String print() {
    return '$species $chrName: ${range.start} to ${range.end}, $strand';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeneInfo &&
//          runtimeType == other.runtimeType &&
//          name == other.name &&
          gid == other.gid &&
          chrName == other.chrName
//          species == other.species &&
//          range == other.range &&
//          strand == other.strand
      ;

  @override
  int get hashCode => name.hashCode ^ gid.hashCode ^ chrName.hashCode ^ species.hashCode ^ range.hashCode ^ strand.hashCode;
}

class GeneInfoDetail extends GeneInfo {
  GeneInfoDetail({required Range range, required String species, required String speciesId, required String chrName, required String chrId}) : super(range: range, species: species, speciesId: speciesId, chrName: chrName, chrId: chrId);
}