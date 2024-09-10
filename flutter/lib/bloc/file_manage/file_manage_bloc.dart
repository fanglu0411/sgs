import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter_smart_genome/bean/admin_manage_beans.dart';
import 'package:flutter_smart_genome/bloc/request/bloc.dart';

class FileManageBloc extends Bloc<RequestEvent, RequestState> {
  FileManageBloc() : super(RequestDefault());

  @override
  Stream<RequestState> mapEventToState(
    RequestEvent event,
  ) async* {
    if (event is Fetch) {
      await Future.delayed(Duration(milliseconds: 300));

      List<FileBean> list = List.generate(
          39,
          (index) => FileBean(
                id: index,
                name: 'jack $index',
                type: 'gff',
                description: 'this is a long description',
                uploadTime: DateTime.now(),
              ));

      yield DataLoaded<FileBean>(list: list);
    }
  }
}