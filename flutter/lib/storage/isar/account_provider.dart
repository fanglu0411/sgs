import 'package:flutter_smart_genome/bean/account_bean.dart';
import 'package:flutter_smart_genome/storage/store.dart';
import 'package:isar/isar.dart';

class AccountProvider {
  static saveAccount(AccountBean account) async {
    Isar isar = await Store.get().isar;
    await isar.writeAsync((isar) async => isar.accountBeans.put(account..id = isar.accountBeans.autoIncrement()));
  }

  static saveAccounts(List<AccountBean> accounts) async {
    Isar isar = await Store.get().isar;
    await isar.writeAsync((isar) async {
      accounts.forEach((e)=> e.id = isar.accountBeans.autoIncrement());
      isar.accountBeans.putAll(accounts);
    });
  }

  static Future<List<AccountBean>> getAccounts() async {
    Isar isar = await Store.get().isar;
    return isar.accountBeans.where().findAll();
  }

  static Future<bool> deleteAccount(AccountBean account) async {
    Isar isar = await Store.get().isar;
    return isar.accountBeans.delete(account.id);
  }

  static Future<List<AccountBean>> findBySite(String url) async {
    Isar isar = await Store.get().isar;
    return isar.accountBeans.where().urlEqualTo(url).findAllAsync();
  }

  static updateAccount(AccountBean account) async {
    Isar isar = await Store.get().isar;
    isar.writeAsync((isar) => isar.accountBeans.put(account));
  }
}
