import 'package:flutter/foundation.dart';
import 'package:flutter_smart_genome/bean/account_bean.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/widget/track/base/track_session.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

class Store {
  static final Store _store = Store._init();

  static Store get() => _store;

  late Future<Isar> _isar;

  factory Store() {
    return _store;
  }

  init() async {
    String dir = kIsWeb ? Isar.sqliteInMemory : join((await getApplicationDocumentsDirectory()).path, 'sgs');
    _isar = Isar.openAsync(schemas: [
      AccountBeanSchema,
      SiteItemSchema,
      TrackSessionSchema,
    ], directory: dir, name: 'isar-sgs');
  }

  Store._init() {}

  Future<Isar> get isar => _isar; //Isar.get(schemas: [], name: 'isar-sgs');
}
