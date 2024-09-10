import 'package:flutter_smart_genome/bean/gene.dart';
import 'package:meta/meta.dart';

@immutable
abstract class GeneInfoEvent {}

class GeneInfoLoadEvent extends GeneInfoEvent {
  final GeneInfo geneInfo;

  GeneInfoLoadEvent(this.geneInfo);
}
