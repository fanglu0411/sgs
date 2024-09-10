import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/base/ui_config.dart';
import 'package:flutter_smart_genome/bean/account_bean.dart';
import 'package:flutter_smart_genome/bean/datasets.dart';
import 'package:flutter_smart_genome/bean/field_item.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/components/setting_config_widget.dart';
import 'package:flutter_smart_genome/components/window/multi_window_controller.dart';
import 'package:flutter_smart_genome/page/site/site_logic.dart';
import 'package:flutter_smart_genome/routes.dart';
import 'package:flutter_smart_genome/storage/base_store_provider.dart';

import 'package:flutter_smart_genome/util/device_info.dart';
import 'package:flutter_smart_genome/widget/basic/button_group.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:flutter_smart_genome/widget/basic/scroll_controller_builder.dart';
import 'package:flutter_smart_genome/widget/basic/simple_form.dart';
import 'package:flutter_smart_genome/widget/loading_widget.dart';
import 'package:get/get.dart';
import 'package:flutter_smart_genome/service/auth_service.dart' as auth;

class SiteSelectorWidget extends StatefulWidget {
  final ValueChanged<SiteItem>? onChanged;
  final bool asList;
  final SiteItem? site;
  final VoidCallback? onEvent;

  const SiteSelectorWidget({
    Key? key,
    this.onChanged,
    this.site,
    this.asList = false,
    this.onEvent,
  }) : super(key: key);

  @override
  _SiteSelectorWidgetState createState() => _SiteSelectorWidgetState();
}

class _SiteSelectorWidgetState extends State<SiteSelectorWidget> with WidgetsBindingObserver {
  bool editPage = false;

  int? expandedIndex = null;
  SiteItem? _site;

  SiteItem? _expandedSite;

  SiteLogic logic = Get.put(SiteLogic(), tag: 'site-selector');

  @override
  void initState() {
    super.initState();
    _site = widget.site;
    _expandedSite = widget.site;
  }

  @override
  void didUpdateWidget(covariant SiteSelectorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SiteLogic>(
      init: logic,
      builder: (logic) {
        Widget body = logic.loading
            ? LoadingWidget(
                loadingState: LoadingState.loading,
                message: 'Loading',
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text('Server List'),
                    trailing: ElevatedButton.icon(
                      onPressed: () => _editOrAddSite(),
                      icon: Icon(Icons.add, size: 16),
                      label: Text('Connect new server'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ),
                  Divider(thickness: 1, height: 1),
                  Expanded(child: _buildList(context, logic)),
                ],
              );
        return body;
        // return Container(color: Theme.of(context).scaffoldBackgroundColor, child: body);
      },
    );
  }

  Widget _buildList(BuildContext context, SiteLogic logic) {
    List<SiteItem> sites = logic.sites ?? [];
    SiteItem _currentSite = _site ?? logic.currentSite!;

    List<ExpansionPanel> _expansions = sites.map((siteItem) {
      bool siteSelected = siteItem.sid == _currentSite.sid;
      return ExpansionPanel(
        canTapOnHeader: false,
        isExpanded: siteItem.editable && _expandedSite?.sid == siteItem.sid,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        headerBuilder: (context, expanded) {
          return ListTile(
            selected: siteSelected,
            // selectedTileColor: Theme.of(context).selectedRowColor,
            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
            title: Text(
              '${siteItem.nameEmpty ? siteItem.url : siteItem.name}',
              style: siteSelected ? TextStyle(color: Theme.of(context).colorScheme.primary) : null,
            ),
            subtitle: siteItem.nameEmpty
                ? null
                : Text(
                    '${siteItem.url}',
                    style: siteSelected ? TextStyle(color: Theme.of(context).colorScheme.primary) : null,
                  ),
            onTap: () {
              _onSpeciesChange(context, siteItem, null);
            },
          );
        },
        body: _settingBody(context, siteItem),
        // _editForm(context, siteItem),
      );
    }).toList();

    return ScrollControllerBuilder(builder: (c, controller) {
      return SingleChildScrollView(
        controller: controller,
        child: Container(
          color: Theme.of(context).dialogBackgroundColor,
          child: ExpansionPanelList(
            elevation: 1,
            materialGapSize: 10,
            expandedHeaderPadding: EdgeInsets.zero,
            expansionCallback: (idx, expanded) {
              setState(() {
                if (!expanded) {
                  _expandedSite = null;
                } else {
                  _expandedSite = sites[idx];
                }
              });
            },
            children: _expansions,
          ),
        ),
      );
    });
  }

  _onSpeciesChange(BuildContext context, SiteItem siteItem, Species? species) {
    if (species != null) {
      siteItem.currentSpecies = species.name;
      siteItem.currentSpeciesId = '${species.id}';
    }
    setState(() {
      _site = siteItem;
    });
    widget.onChanged?.call(siteItem);
    //BlocProvider.of<SiteBloc>(context).add(SpeciesChangeEvent(siteItem, species));
  }

  _showSiteMenu(BuildContext context, SiteItem site) async {
    showAttachedWidget(
        preferDirection: PreferDirection.bottomRight,
        targetContext: context,
        attachedBuilder: (cancel) {
          return Material(
            shape: modelShape(),
            // clipBehavior: Clip.antiAlias,
            color: Theme.of(context).dialogBackgroundColor,
            elevation: 6,
            child: Container(
              constraints: BoxConstraints.tightFor(width: 300),
              padding: EdgeInsets.all(6),
              child: SettingListWidget(
                settings: [
//                  SettingItem.button(title: 'Edit Server', key: 'edit', prefix: Icon(Icons.edit)),
                  SettingItem.button(title: 'Data Manager', key: 'admin', prefix: Icon(MaterialCommunityIcons.database_settings)),
                  SettingItem.button(title: 'Delete (Record only)', key: 'delete', prefix: Icon(Icons.delete)),
                ],
                onItemTap: (item, ctx) {
                  cancel();
                  if (item.key == 'edit') {
                    _editOrAddSite(site);
                  } else if (item.key == 'delete') {
                    _deleteSite(context, site);
                  } else if (item.key == 'admin') {
                    _toDataManage(site);
                  } else {}
                },
              ),
            ),
          );
        });
  }

  _toDataManage(SiteItem site) async {
    widget.onEvent?.call();
    var _accounts = (await BaseStoreProvider.get().getAccounts()) ?? [];
    var loginUser = _accounts.firstWhereOrNull((a) => a.url == site.url && a.token != null);
    if (loginUser != null) {
      bool valid = await _checkLogin(loginUser);
      if (valid) {
        _toUserCenter(loginUser);
      } else {
        BaseStoreProvider.get().deleteAccount(loginUser);
        _login(site);
      }
    } else {
      _login(site);
    }
  }

  void _login(SiteItem site) async {
    var result = await Get.toNamed(RoutePath.login, arguments: site);
    // var result = await Navigator.of(context).pushNamed(RoutePath.login, arguments: site);
    if (null != result) {
      AccountBean account = result;
      _toUserCenter(account);
    }
  }

  void _toUserCenter(AccountBean account) async {
    if (DeviceOS.isDesktop) {
      multiWindowController.openDataManager(account: account);
    } else {
      Get.toNamed(RoutePath.user_center, arguments: account);
      // Navigator.of(context).pushNamed(RoutePath.user_center, arguments: account);
    }
  }

  Future<bool> _checkLogin(AccountBean account) async {
    var loading = BotToast.showLoading();
    var resp = await auth.validateToken(host: account.url, token: account.token!);
    var body = resp.body;
    loading.call();
    return resp.success && body['data'] != null;
  }

  _deleteSite(BuildContext context, SiteItem item) async {
    Get.defaultDialog(
      title: 'Delete record: ${item.url} ?',
      content: Text(
        'your data on server is ok, just delete record on sgs client!',
        textAlign: TextAlign.start,
        style: TextStyle(fontSize: 14),
      ),
      titlePadding: EdgeInsets.fromLTRB(20, 30, 20, 0),
      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      cancel: OutlinedButton(
          onPressed: () {
            Get.back();
          },
          child: Text('CANCEL')),
      confirm: ElevatedButton(
        onPressed: () {
          Get.back(result: true);
          logic.deleteSite(item);
        },
        style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.red),
        child: Text('DELETE'),
      ),
      radius: 10,
      onConfirm: () {
        logic.deleteSite(item);
      },
    );
  }

  Widget _settingBody(BuildContext context, SiteItem site) {
    return Container(
      color: Theme.of(context).colorScheme.primary.withOpacity(.05),
      padding: const EdgeInsets.only(bottom: 12.0, left: 10, right: 10, top: 10),
      child: ButtonGroup(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          border: Border.fromBorderSide(BorderSide.none),
          divider: SizedBox(
            height: 20,
            child: VerticalDivider(
              width: 1,
              thickness: 1,
            ),
          ),
          children: [
            TextButton.icon(
              icon: Icon(Icons.admin_panel_settings, size: 20),
              onPressed: () => _toDataManage(site),
              label: Text('Manage'),
            ),
            TextButton.icon(
              icon: Icon(Icons.edit_note),
              onPressed: () => _editOrAddSite(site),
              label: Text('Edit'),
            ),
            TextButton.icon(
              icon: Icon(Icons.delete, size: 18),
              onPressed: () => _deleteSite(context, site),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              label: Text('Delete'),
            ),
          ]),
    );
  }

  Widget _editForm(BuildContext context, [SiteItem? siteItem]) {
    GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    SiteItem _siteItem = siteItem ?? SiteItem(url: '');

    void _save(SiteItem? __siteItem) {
      bool isEdit = siteItem != null;
      if (__siteItem != null) {
        isEdit ? logic.editSite(__siteItem) : logic.addSite(__siteItem);
      }
    }

    Widget _form = Container(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Text(null == siteItem ? 'Add new server' : 'Edit server'),
            TextFormField(
              decoration: InputDecoration(
                hintText: 'http://www.sgs.com:8080',
                labelText: 'Server Url *',
                alignLabelWithHint: true,
                helperText: 'url is required',
              ),
              initialValue: _siteItem.url ?? '',
              validator: (value) {
                if (value!.length == 0) return 'url is empty';
                var regexp = RegExp('(https?|ftp|file)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]');
                bool match = regexp.hasMatch(value);
                return match ? null : 'url is not valid';
              },
              onSaved: (value) {
                _siteItem.url = value!.trim();
              },
              maxLines: 1,
            ),
            SizedBox(height: 10),
            TextFormField(
              decoration: InputDecoration(
                hintText: 'name your server',
                labelText: 'Server Name (Optional)',
              ),
              initialValue: _siteItem.name ?? '',
              onSaved: (value) {
                _siteItem.name = value ?? '';
              },
              maxLines: 1,
            ),
          ],
        ),
      ),
    );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _form,
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(Get.context!);
                },
                child: Text('CANCEL'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                ),
                onPressed: () {
                  if (!_formKey.currentState!.validate()) return;
                  _formKey.currentState!.save();
                  // _save(_siteItem);
                  Navigator.pop<SiteItem?>(Get.context!, _siteItem);
                },
                child: Text(null == siteItem ? 'ADD' : 'SAVE'),
              ),
            ],
          )
        ],
      ),
    );
  }

  void _editOrAddSite([SiteItem? siteItem]) async {
    // GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    SiteItem _siteItem = siteItem ?? SiteItem(url: '');
    var dialog = AlertDialog(
      title: Text(siteItem != null ? 'Edit server' : 'Add new server'),
      content: Container(
        width: 400,
        child: _editForm(context, _siteItem),
      ),
    );
    SiteItem? __siteItem = await showDialog<SiteItem>(context: Get.context!, builder: (context) => dialog);
    bool isEdit = siteItem != null;

    if (__siteItem != null) {
      isEdit ? logic.editSite(__siteItem) : logic.addSite(__siteItem);
//      BotToast.showSimpleNotification(title: isEdit ? 'Site Updated!' : 'Site Saved!', duration: Duration(milliseconds: 3000));
    }
  }

  Widget _buildSiteForm(BuildContext context) {
    var _form = SimpleForm(
      fields: [
        FieldItem.name(name: 'name', label: 'Server name', hint: 'Give your server a name', required: true),
        FieldItem.name(name: 'url', label: 'Server address', hint: 'your server url like: http://000.000.000.000:0000', required: true),
      ],
      inputBorder: inputBorder(),
      onSubmit: (values) => _onSubmit(context, values),
    );

    bool _portrait = portrait(context);

    Widget widget = Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'Connect to server first!',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w300),
            ),
          ),
          _form,
        ],
      ),
    );

    if (_portrait) return widget;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: widget,
    );
  }

  void _onSubmit(BuildContext context, Map values) {
    var site = SiteItem.fromMap(values);
    logic.addSite(site);
  }

  @override
  void dispose() {
    Get.delete<SiteLogic>(tag: 'site-selector');
    super.dispose();
  }
}
