import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/bean/account_bean.dart';
import 'package:flutter_smart_genome/bean/field_item.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/components/sgs_logo.dart';
import 'package:flutter_smart_genome/mixin/scaffold_key_mixin.dart';
import 'package:flutter_smart_genome/mixin/view_size_mixin.dart';
import 'package:flutter_smart_genome/storage/base_store_provider.dart';
import 'package:flutter_smart_genome/storage/isar/site_provider.dart';

import 'package:flutter_smart_genome/util/device_info.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:flutter_smart_genome/widget/basic/fast_rich_text.dart';
import 'package:flutter_smart_genome/widget/basic/simple_form.dart';

import 'package:flutter_smart_genome/service/auth_service.dart' as auth;

class LoginPage extends StatefulWidget {
  final AccountBean? account;
  final bool isRegister;
  final ValueChanged<AccountBean>? onLogin;
  final SiteItem? site;

  const LoginPage({
    Key? key,
    this.account,
    this.isRegister = false,
    this.onLogin,
    this.site,
  }) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with ViewSizeMixin, ScaffoldKeyMixin {
  AccountBean? _account;

  String? _serverUrl;

  List<FieldItem>? _fieldItems;

  late TextEditingController _serverTextController;

  List<FieldItem> _initFields() {
    return [
      FieldItem.name(
        name: 'token',
        label: 'Token',
        hint: 'input token',
        required: true,
        value: '',
        minLines: 2,
        maxLines: 2,
      ),
      // FieldItem.name(
      //   name: 'username',
      //   label: 'Name',
      //   hint: 'user name',
      //   required: true,
      //   value: 'leeoadmin',
      // ),
      // FieldItem.name(
      //   name: 'password',
      //   label: 'Password',
      //   hint: 'password',
      //   required: true,
      //   value: '123456',
      // ),
      FieldItem.builder(
        widgetBuilder: (c) {
          return Container(
              alignment: Alignment.centerLeft,
              child: Builder(builder: (context) {
                return TextButton(
                  onPressed: () {
                    _showTokenHelp(context);
                  },
                  child: Text('Where is my token?'),
                );
              }));
        },
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _fieldItems = _initFields();
    _account = widget.account;
    _serverTextController = TextEditingController();
    if (widget.site != null) {
      _serverTextController.text = widget.site!.url;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool _isMobile = isMobile();
    bool _dark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    bool showClose = !DeviceOS.isMobile;
    return Scaffold(
      key: scaffoldKey,
      appBar: _isMobile
          ? AppBar(
              leading: IconButton(
                tooltip: 'Back',
                icon: Icon(Icons.arrow_back_ios, color: _dark ? Colors.white : Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
              backgroundColor: Colors.transparent,
            )
          : null,
      // PreferredSize(
      //         child: AppTitleBar(
      //           child: Container(child: Center(child: Text('Login')), constraints: BoxConstraints.expand(),),
      //         ),
      //         preferredSize: Size.fromHeight(36)),
      body: Stack(
        children: [
          Container(
//        color: _isMobile ? Colors.white : Colors.black87,
            constraints: BoxConstraints.expand(),
            alignment: Alignment.center,
            child: _fitSize(_isMobile, size),
          ),
          // AppTitleBar(),
          // Container(
          //   height: ui_config.HORIZONTAL_TOOL_BAR_HEIGHT,
          //   child: AppBar(
          //     automaticallyImplyLeading: showLeading,
          //     toolbarHeight: ui_config.HORIZONTAL_TOOL_BAR_HEIGHT,
          //     backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          //     title: AppTitleBar(
          //       child: Row(),
          //     ),
          //   ),
          // ),
          if (showClose)
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: IconButton(
                  tooltip: 'Close',
                  color: _dark ? Colors.white70 : null,
                  iconSize: 30,
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  _fitSize(bool isMobile, Size size) {
    if (!isMobile) {
      return Container(
        constraints: BoxConstraints.tightFor(width: 1200),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(width: 20),
            Expanded(child: _buildBodyLeft(), flex: 2),
            SizedBox(width: 20),
            Expanded(
              flex: 3,
              child: Container(
                alignment: Alignment.center,
                constraints: BoxConstraints.expand(),
                child: _formContent(isMobile),
              ),
            ),
            Expanded(child: SizedBox(), flex: 1),
          ],
        ),
      );
    } else {
      final size = MediaQuery.of(context).size;
      final width = size.width * .8;
      return Container(
        padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 30),
//        constraints: BoxConstraints.tightFor(width: math.min(math.max(width, 500), 500)),
        decoration: BoxDecoration(
//          color: Colors.white,
//          borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
        child: _formContent(isMobile),
      );
    }
  }

  Widget _buildBodyLeft() {
    return Container(
//      margin: EdgeInsets.all(30),
      constraints: BoxConstraints.tightFor(width: 300),
      // decoration: BoxDecoration(
      //   image: DecorationImage(
      //     image: AssetImage(R.drawable.app_icon_512),
      //     fit: BoxFit.contain,
      //   ),
      // ),
      child: Center(
        child: SgsLogo(
            fontSize: 60,
            color: Theme.of(context).colorScheme.primary,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(40),
              bottomLeft: Radius.circular(40),
              topLeft: Radius.circular(3),
              bottomRight: Radius.circular(3),
            )),
      ),
    );
  }

  Widget _formContent(bool isMobile) {
    Widget _content = Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          'Smart Genome DB System',
          style: TextStyle(fontWeight: FontWeight.w300, fontSize: 30),
        ),
        SizedBox(height: 30.0),
        Text(
          'Sign In',
          style: TextStyle(fontWeight: FontWeight.w400, fontSize: 24),
        ),
        SizedBox(height: 30.0),
        TextField(
          controller: _serverTextController,
          decoration: InputDecoration(
            labelText: 'Server',
            hintText: 'http://domain:port',
            border: inputBorder(),
            suffixIcon: Builder(
              builder: (context) {
                return IconButton(
                  icon: Icon(Icons.keyboard_arrow_down),
                  onPressed: () => _showServerListMenu(context),
                  tooltip: 'Choose Server',
                );
              },
            ),
          ),
        ),
        SizedBox(height: 16),
        SimpleForm(
          fields: _fieldItems!,
          submitLabel: widget.isRegister ? 'REGISTER' : 'LOGIN',
          onSubmit: _handleSubmit,
//          inputBorder: OutlineInputBorder(),
          inputBorder: inputBorder(),
//          resetLabel: 'CANCEL',
          textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w400, fontSize: 14),
          buttonExpand: true,
          buttonGroupPadding: EdgeInsets.only(bottom: 20),
//          reset: false,
//           buttonShape: buttonShape(),
        ),
      ],
    );
    return _content;
  }

  void _handleSubmit(Map formValues) async {
    if (_serverTextController.text.isEmpty) {
      showToast(text: 'Please select server address!');
      return;
    }

    var loading = BotToast.showLoading();
    var resp = await auth.validateToken(host: _serverTextController.text, token: formValues['token']);

    loading.call();
    var body = resp.body;
    if (resp.success && body['data'] != null) {
      var data = body['data'];
      showToast(text: 'Login success');
      _account = AccountBean.fromMap({...data, 'url': _serverTextController.text});

      List<SiteItem> sites = await BaseStoreProvider.get().getSiteList();
      if (sites.indexWhere((s) => s.url == _account!.url) < 0) {
        await BaseStoreProvider.get().addSite(SiteItem(url: _account!.url));
      }
      await BaseStoreProvider.get().addAccount(_account!);

      if (widget.onLogin != null) {
        widget.onLogin?.call(_account!);
      } else {
        Navigator.of(context).maybePop<AccountBean>(_account);
        // Navigator.of(context).popAndPushNamed(RoutePath.user_center, arguments: _account);
      }
    } else {
      var error = body?['error'] ?? resp.error!.message ?? 'Token valid fail';
      showToast(text: error);
    }
  }

  Widget _siteField() {
    // var sites = (await BaseStoreProvider.get().getSiteList()) ?? [];
    return Builder(
      builder: (context) {
        return OutlinedButton.icon(
          icon: Icon(Icons.keyboard_arrow_down),
          onPressed: () => _showServerListMenu(context),
          label: Text('Choose Server'),
        );
      },
    );
  }

  void _showServerListMenu(BuildContext context) async {
    var sites = await BaseStoreProvider.get().getSiteList();
    showAttachedWidget(
        targetContext: context,
        preferDirection: PreferDirection.bottomRight,
        offset: Offset(0, 8),
        attachedBuilder: (cancel) {
          return Material(
//            color: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: 400, maxWidth: 430, maxHeight: 400),
              child: ListView(
                shrinkWrap: true,
                children: ListTile.divideTiles(
                        tiles: sites.where((element) => element.isSgs).map((e) {
                          return ListTile(
                            title: e.nameEmpty ? Text(e.url) : Text(e.name!),
                            subtitle: e.nameEmpty ? null : Text(e.url),
                            trailing: e.url == _serverTextController.text ? Icon(Icons.check) : null,
                            selected: e.url == _serverTextController.text,
                            onTap: () {
                              cancel();
                              _serverUrl = e.url;
                              _serverTextController.text = e.url;
                            },
                          );
                        }),
                        context: context)
                    .toList(),
              ),
            ),
          );
        });
  }

  void _showTokenHelp(BuildContext context) {
    var help = '''
##### 1. ssh to your sgs server, and run command:

> curl http://localhost:6102/api/token/admin

##### 2. Ask project manager.
''';

    showAttachedWidget(
        targetContext: context,
        preferDirection: PreferDirection.bottomLeft,
        offset: Offset(0, 4),
        attachedBuilder: (c) {
          return Material(
            borderRadius: BorderRadius.circular(10),
            elevation: 6,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: 200, maxWidth: 430),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('1. ssh to your sgs server, and run command:'),
                    SizedBox(height: 10),
                    Container(
                        padding: EdgeInsets.only(left: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Theme.of(context).colorScheme.primaryContainer,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SelectableText('curl http://localhost:API_PORT/api/token/admin', style: TextStyle(fontFamily: MONOSPACED_FONT, fontFamilyFallback: MONOSPACED_FONT_BACK)),
                            IconButton(
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: 'curl http://localhost:6102/api/token/admin'));
                                c.call();
                              },
                              icon: Icon(Icons.copy),
                              iconSize: 16,
                              tooltip: 'Copy command',
                              constraints: BoxConstraints.tightFor(width: 30, height: 30),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        )),
                    SizedBox(height: 10),
                    FastRichText(
                      children: [
                        TextSpan(text: 'API_PORT', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                        TextSpan(text: ' is your sgs api port, default is 6102', style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text('2. Ask for project manager.'),
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  void dispose() {
    super.dispose();
    _serverTextController.dispose();
  }
}
