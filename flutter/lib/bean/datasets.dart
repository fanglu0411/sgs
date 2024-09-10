import 'package:flutter_smart_genome/mixin/selectable_mixin.dart';

class DataSet {
  late dynamic id;
  String? name;
  String? description;
  String? status;

  bool get statusDone => status == 'done';

  bool get statusError => status == 'error';

  DataSet({this.name, this.description, this.id, this.status});
}

class SCSet extends DataSet with SelectableMixin {
  SCSet({
    dynamic id,
    String? name,
    String? description,
    String? status,
  }) : super(id: id, name: name, description: description, status: status);
}

class Species extends DataSet with SelectableMixin {
  // record id in table
  int? _id;
  dynamic id;
  String? iconUrl;
  String? fasta;
  String? indexFile;
  num? progress;
  String? msg;

  int? editType;

  SpeciesFiles? files;

  int? get dbId => _id;

  Species(String name, {this.iconUrl, String? status}) : super(name: name, status: status) {}

  Species.empty() : super(name: '') {}

  bool get isEmpty => name == null && files == null;

  Species.fromMap(Map map) : super() {
    _id = map['id'];
    name = map['species_name'];
    id = map['species_id'];
    iconUrl = map['iconUrl'];
    fasta = map['fasta_file'];
    indexFile = map['index_file'];
    status = map['species_status'];
    progress = map['progress'];
    msg = map['msg'];

    Map? _detail = map['details'];
    Map? _files = map['files'];
    files = _files != null ? SpeciesFiles.fromMap(_files) : null;
  }

  static List<Species> fromList(list) {
    List _list = list;
    return _list.map(fromJson).toList();
  }

  static Species fromJson(dynamic map) {
    return Species.fromMap(map);
  }

  copyWithBasic(Map map) {
    name = map['species_name'];
    id = map['species_id'];
    iconUrl = map['iconUrl'];
    fasta = map['fasta_file'];
  }

  copyWithFiles(Map? map) {
    if (map != null) {
      files = SpeciesFiles.fromMap(map);
    }
  }

  basicMap() {
    return {
      "species_name": name,
      'iconUrl': iconUrl,
      'fasta_file': fasta,
    };
  }


  fileMap() {
    return files?.asMap();
  }

  toJson() {
    Map map = basicMap();
    if (files != null) {
      map['files'] = files!.asMap();
    }
    return map;
  }

  @override
  String toString() {
    return 'Species{id: $id, name: $name, iconUrl: $iconUrl, fasta: $fasta, editType: $editType}';
  }
}

class SpeciesFiles {
  String? gff;
  String? fasta;
  String? annotation;
  String? expression;

  asMap() {
    return {
      'gff': gff,
      'fasta': fasta,
      'annotation': annotation,
      'expression': expression,
    };
  }

  SpeciesFiles.fromMap(Map map) {
    gff = map['gff'];
    fasta = map['fasta'];
    annotation = map['annotation'];
    expression = map['expression'];
  }
}