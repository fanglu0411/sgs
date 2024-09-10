import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/account_bean.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/routes.dart';
import 'package:flutter_smart_genome/service/sgs_app_service.dart';
import 'package:flutter_smart_genome/storage/base_store_provider.dart';

import 'package:flutter_smart_genome/extensions/widget_extensions.dart';

class AccountInfoWidget extends StatefulWidget {
  final ValueChanged? onTap;
  final BuildContext? context;

  const AccountInfoWidget({
    this.context,
    Key? key,
    this.onTap,
  }) : super(key: key);

  @override
  _AccountInfoWidgetState createState() => _AccountInfoWidgetState();
}

class _AccountInfoWidgetState extends State<AccountInfoWidget> {
  List<AccountBean> _accounts = [];

  @override
  void initState() {
    super.initState();
    _loadAccount();
  }

  _loadAccount() async {
    _accounts = (await BaseStoreProvider.get().getAccounts());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Card(
            elevation: 4,
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: ListTile(
              horizontalTitleGap: 4,
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              leading: Icon(Icons.account_circle, size: 36),
              title: Text('Login to new Server'),
              trailing: Icon(Icons.login),
              onTap: _login,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(left: BorderSide(width: 4, color: Theme.of(context).colorScheme.primary)),
            ),
            margin: EdgeInsets.only(left: 14, top: 4),
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Text('Logged in Server history:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300)),
          ),
          Card(
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.0),
              borderRadius: BorderRadius.circular(6),
            ),
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: _buildLastLoginSite(),
          ),
        ],
      ),
    );
  }

  Widget _buildLastLoginSite() {
    if (_accounts.isEmpty) {
      return ListTile(
        enabled: false,
        isThreeLine: false,
        // dense: true,
        title: Text('No server Logged in'),
      );
    }
    SiteItem site = SgsAppService.get()!.site!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _accounts.map((e) {
        Widget tile = ListTile(
          horizontalTitleGap: 4,
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          selected: site.url == e.url,
          onTap: () => _toUserCenter(e),
          leading: Icon(Icons.sd_storage_rounded),
          title: Text('${e.url}'),
          trailing: IconButton(
            splashRadius: 18,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints.tightFor(width: 32, height: 32),
            icon: Icon(Icons.logout, size: 20),
            onPressed: () => _logout(e),
            tooltip: 'Quit',
          ),
        ).withBottomBorder(color: Theme.of(context).dividerColor);
        if (site.url == e.url) {
          tile = ClipRRect(
            child: Banner(
              message: 'Current',
              location: BannerLocation.topStart,
              child: tile,
            ),
          );
        }
        return tile;
      }).toList(),
    );
  }

  void _logout(AccountBean account) async {
    _accounts.remove(account);
    BaseStoreProvider.get().deleteAccount(account);
    // await BaseStoreProvider.get().setAccounts(_accounts);
    setState(() {});
  }

  void _toUserCenter(AccountBean account) async {
    // List<SiteItem> sites = await BaseStoreProvider.get().getSiteList();
    // SiteItem site = sites.firstWhere((s) => s.url == account.url, orElse: () => null);
    // if(site == null){
    //   return;
    // }
    Navigator.of(widget.context ?? context).pushNamed(RoutePath.user_center, arguments: account);
  }

  void _login() async {
    AccountBean? result = await Navigator.of(widget.context ?? context).pushNamed<AccountBean>(RoutePath.login);
    if (null != result) {
      // await Future.delayed(Duration(milliseconds: 300));
      _toUserCenter(result);
    }
  }
}
