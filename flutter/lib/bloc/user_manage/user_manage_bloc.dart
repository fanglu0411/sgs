import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter_smart_genome/bean/admin_manage_beans.dart';
import 'package:flutter_smart_genome/bloc/request/bloc.dart';

class UserManageBloc extends Bloc<RequestEvent, RequestState> {
  UserManageBloc() : super(RequestDefault());

  @override
  Stream<RequestState> mapEventToState(RequestEvent event) async* {
    if (event is Fetch) {
      await Future.delayed(Duration(milliseconds: 300));

      List<UserBean> list = List.generate(
          35,
          (index) => UserBean(
            id: '${index}',
                username: 'jack hahalfdf fsdf ${index}',
                usedStorage: 3000,
                lastLoginTime: DateTime.now(),
                createTime: DateTime.now(),
              ));

      yield DataLoaded<UserBean>(list: list);
    }
  }
}