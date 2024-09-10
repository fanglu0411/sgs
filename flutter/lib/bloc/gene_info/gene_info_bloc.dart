import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter_smart_genome/bean/gene.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';
import './bloc.dart';

class GeneInfoBloc extends Bloc<GeneInfoEvent, GeneInfoState> {
  GeneInfoBloc() : super(InitialGeneInfoState());

  @override
  Stream<GeneInfoState> mapEventToState(
    GeneInfoEvent event,
  ) async* {
    if (event is GeneInfoLoadEvent) {
      GeneInfoDetail detail = GeneInfoDetail(
        species: '',
          speciesId: '',
          chrName: '',
          chrId: '',
          range: Range(start: 0, end: 100));
      yield GeneInfoLoadedState(detail);
    }
  }
}