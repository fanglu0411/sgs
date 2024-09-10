import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_smart_genome/bean/account_bean.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:get/get.dart';
import 'package:flutter_smart_genome/service/auth_service.dart' as auth;

class TokenUser {
  late String token;
  late String name;
  late List roles;
  late DateTime createAt;

  TokenUser({required this.token, required this.name, required this.roles, required this.createAt});

  bool get isAdmin => name == 'Admin' && roles.contains('admin');
}

class TokenLogic extends GetxController {
  bool loading = true;
  String? error = null;
  List<TokenUser>? tokens;

  SiteItem? _site;
  AccountBean? _account;

  void setSite(SiteItem site, AccountBean account) {
    _site = site;
    _account = account;

    // loadTokens();
  }

  @override
  void onReady() {
    super.onReady();
    Future.delayed(Duration(milliseconds: 100)).then((value) => loadTokens());
  }

  deleteToken(String token) async {
    var c = BotToast.showLoading();
    // todo delete token
    var resp = await auth.deleteToken(host: _site!.url, token: _account!.token!, targetToken: token);
    c.call();
    var body = resp.body;
    if (resp.success && body['data'] != null) {
      tokens = _format(body['data']);
      update();
    } else {
      var error = body?['error'] ?? resp.error?.message ?? 'Delete token error';
      showToast(text: error);
    }
  }

  createToken(Map user) async {
    var c = BotToast.showLoading();
    var resp = await auth.createToken(host: _site!.url, token: _account!.token!, data: user);
    c.call();

    var body = resp.body;
    if (resp.success && body['data'] != null) {
      tokens = _format(body['data']);
      update();
    } else {
      var error = body?['error'] ?? resp.error?.message ?? 'Create token error';
      showToast(text: error);
    }
  }

  loadTokens() async {
    loading = true;
    error = null;
    var resp = await auth.loadTokens(host: _site!.url, token: _account!.token!);

    loading = false;
    var body = resp.body;
    if (resp.success && body['data'] != null) {
      tokens = _format(body['data']);
    } else {
      error = body?['error'] ?? resp.error?.message ?? 'Load token error';
    }
    update();
  }

  List<TokenUser> _format(List json) {
    return json.map((e) => TokenUser(token: e['token']!, name: e!["username"]! as String, roles: e!["roles"]! as List, createAt: DateTime.fromMillisecondsSinceEpoch(e!["createAt"]! as int))).toList();
  }
}
