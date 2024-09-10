import 'package:flutter_smart_genome/bean/gene.dart';
import 'package:meta/meta.dart';

@immutable
abstract class GeneInfoState {}

class InitialGeneInfoState extends GeneInfoState {}

class GeneInfoLoadedState extends GeneInfoState {
  final GeneInfo geneInfo;

  GeneInfoLoadedState(this.geneInfo);
}

class GeneInfoErrorState extends GeneInfoState {
  final String message;

  GeneInfoErrorState(this.message);
}
