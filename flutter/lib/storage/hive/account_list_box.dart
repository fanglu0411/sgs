import 'package:flutter_smart_genome/bean/account_bean.dart';
import 'package:hive/hive.dart';

import 'type_ids.dart';

Box<AccountBean> _box() {
  return Hive.box<AccountBean>('accounts');
}

List<AccountBean> getAccounts() {
  return _box().values.toList();
}

Future addAccount(AccountBean account) async {
  await _box().put(account.url, account);
}

Future updateAccount(AccountBean account) async {
  await _box().put(account.url, account);
}

void deleteAccount(AccountBean account) {
  _box().delete(account.url);
}

void deleteAccountByUrl(String url) {
  _box().delete(url);
}

Future<int> clear() => _box().clear();

class AccountAdapter extends TypeAdapter<AccountBean> {
  @override
  AccountBean read(BinaryReader reader) {
    Map map = reader.readMap();
    return AccountBean.fromMap(map);
  }

  @override
  int get typeId => ACCOUNT_LIST_TYPE_ID;

  @override
  void write(BinaryWriter writer, AccountBean obj) {
    writer.writeMap(obj.toJson());
  }
}
