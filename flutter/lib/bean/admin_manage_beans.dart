import 'package:flutter_smart_genome/mixin/selectable_mixin.dart';

import 'package:flutter_smart_genome/extensions/time_extension.dart';

class UserBean with SelectableMixin {
  late String id;
  late String username;
  String? nick;
  late double usedStorage;
  DateTime? lastLoginTime;
  DateTime? createTime;

  UserBean({required this.id, required this.usedStorage, required this.username, this.nick, this.lastLoginTime, this.createTime});

  UserBean.from(Map map) {
    id = map['id'];
    username = map['username'];
    nick = map['nick'];
    usedStorage = map['usedStorage'];
    lastLoginTime = DateTime.fromMillisecondsSinceEpoch(map['lastLoginTime']);
    createTime = DateTime.fromMillisecondsSinceEpoch(map['createTime']);
  }

  String? get lastLoginTimeStr => lastLoginTime?.show();

  String? get createTimeStr => createTime?.show();
}

class FileBean with SelectableMixin {
  late int id;
  late String name;
  late String type;
  String? description;
  DateTime? uploadTime;
  FileBean({required this.id, required this.name, required this.type, this.description, this.uploadTime});

  FileBean.fromMap(Map map) {
    id = map['id'];
    name = map['type'];
    description = map['description'];
    uploadTime = DateTime.fromMillisecondsSinceEpoch(map['uploadTime']);
  }

  String? get uploadTimeStr => uploadTime?.show();
}