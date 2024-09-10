import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:flutter_smart_genome/widget/basic/custom_spin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_genome/bean/account_bean.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/page/admin/token/token_create_widget.dart';
import 'package:flutter_smart_genome/page/admin/token/token_logic.dart';
import 'package:flutter_smart_genome/widget/loading_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:multiavatar/multiavatar.dart';

class TokenListPage extends StatefulWidget {
  final SiteItem site;
  final AccountBean account;

  const TokenListPage({super.key, required this.site, required this.account});

  @override
  State<TokenListPage> createState() => _TokenListPageState();
}

class _TokenListPageState extends State<TokenListPage> {
  final tokenLogic = Get.put(TokenLogic());

  DateFormat dateFormat = DateFormat('y-MM-dd HH:mm:ss');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Token Manager'),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: _showAddTokenDialog,
            icon: Icon(Icons.add_box),
            iconSize: 22,
            tooltip: 'Create token',
          ),
          SizedBox(width: 12),
        ],
      ),
      body: GetBuilder<TokenLogic>(
        init: tokenLogic,
        initState: (c) {
          tokenLogic.setSite(widget.site, widget.account);
          // tokenLogic.setSite(SiteItem(url: 'http://localhost:5001'), widget.account);
        },
        autoRemove: true,
        builder: (c) {
          if (c.loading) {
            return Center(child: CustomSpin(color: Theme.of(context).colorScheme.primary));
          }
          if (c.error != null) {
            return LoadingWidget(
              loadingState: LoadingState.error,
              message: c.error,
              onErrorClick: (e) {
                c.loadTokens();
              },
            );
          }
          return _buildTokenList(c);
        },
      ),
    );
  }

  Widget _itemBuilder(TokenUser t, int index) {
    return ListTile(
      title: Text('${t.name}'),
      subtitle: Text('${t.token}'),
      onTap: () {},
      leading: SvgPicture.string(multiavatar(t.name), width: 36, height: 36),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _role(t.roles),
          SizedBox(width: 20),
          Text('${dateFormat.format(t.createAt)}'),
          SizedBox(width: 50),
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: t.token));
              showToast(text: 'token copied');
            },
            padding: EdgeInsets.zero,
            icon: Icon(Icons.copy),
            color: Theme.of(context).colorScheme.primary,
            iconSize: 16,
            tooltip: 'Copy Token',
            constraints: BoxConstraints.tightFor(width: 36, height: 36),
          ),
          SizedBox(width: 10),
          if (t.isAdmin)
            SizedBox(width: 36)
          else
            IconButton(
              onPressed: () => _deleteTokenConfirm(t),
              padding: EdgeInsets.zero,
              icon: Icon(Icons.delete),
              color: Colors.red,
              iconSize: 18,
              tooltip: 'Delete',
              constraints: BoxConstraints.tightFor(width: 36, height: 36),
            ),
        ],
      ),
    );
  }

  Widget _buildTokenList(TokenLogic logic) {
    return ListView.separated(
      itemCount: logic.tokens!.length,
      itemBuilder: (c, i) => _itemBuilder(logic.tokens![i], i),
      separatorBuilder: (c, i) => Divider(height: 1, thickness: 1),
    );
  }

  Widget _role(List roles) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...roles.map(
          (e) => Tooltip(message: e, child: Icon(roleIconMap[e], size: 16, color: Theme.of(context).colorScheme.primary)),
        ),
      ],
    );
  }

  void _deleteTokenConfirm(TokenUser t) async {
    var dialog = (context) => AlertDialog(
          title: Text('Warning!'),
          content: Text('Are you sure want to delete this token?'),
          actions: [
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text('CANCEL')),
            FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Text('DELETE')),
          ],
        );
    var result = await showDialog(context: context, builder: dialog);
    if (null != result && result) {
      tokenLogic.deleteToken(t.token);
    }
  }

  Map<String, IconData> roleIconMap = {'admin': Icons.admin_panel_settings, 'list': Icons.list_alt, 'add': Icons.add_box, 'delete': Icons.delete};

  _showAddTokenDialog() async {
    var dialog = (c) => AlertDialog(
          // backgroundColor: Theme.of(c).cardColor,
          title: Text('Create New Token'),
          content: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 500, minWidth: 320),
            child: TokenCreateWidget(
              onCancel: () {
                Navigator.of(c).pop();
              },
              onSubmit: (user) {
                Navigator.of(c).pop(user);
              },
            ),
          ),
        );
    Map? result = await showDialog<Map?>(context: context, builder: dialog);
    if (null != result) {
      tokenLogic.createToken(result);
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (Get.isRegistered<TokenLogic>()) {
      Get.delete<TokenLogic>();
    }
  }
}
