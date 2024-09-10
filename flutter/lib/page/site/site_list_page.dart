import 'package:bot_toast/bot_toast.dart';

import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/base/ui_config.dart';
import 'package:flutter_smart_genome/bean/field_item.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/bean/datasets.dart';
import 'package:flutter_smart_genome/components/setting_config_widget.dart';
import 'package:flutter_smart_genome/page/site/site_logic.dart';
import 'package:flutter_smart_genome/page/species/species_list_widget.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:flutter_smart_genome/widget/basic/simple_form.dart';
import 'package:flutter_smart_genome/widget/loading_widget.dart';
import 'package:flutter_smart_genome/extensions/widget_extensions.dart';
import 'package:get/get.dart';
import 'package:majascan/majascan.dart';

class SiteListPage extends StatefulWidget {
  final ValueChanged<SiteItem>? onChanged;
  final bool asList;

  const SiteListPage({
    Key? key,
    this.onChanged,
    this.asList = false,
  }) : super(key: key);

  @override
  _SiteListPageState createState() => _SiteListPageState();
}

class _SiteListPageState extends State<SiteListPage> {
  bool editPage = false;

  SiteItem? _expandedSite;

  SiteLogic logic = Get.put(SiteLogic(), tag: 'site-list-page');

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SiteLogic>(
      init: logic,
      builder: (logic) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Change Server / Species'),
            centerTitle: widget.asList ? false : null,
            actions: <Widget>[
              IconButton(
                //colorBrightness: Brightness.dark,
//                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//                  iconSize: 26,
                tooltip: 'Connect to new Server',
                icon: Icon(Icons.add_box),
                //label: Text('Add server'),
                onPressed: () => _editOrAddSite(context),
              ),
              if (mobilePlatform())
                IconButton(
                  //colorBrightness: Brightness.dark,
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//                  iconSize: 26,
                  tooltip: 'Scan From QRCode',
                  icon: Icon(MaterialCommunityIcons.qrcode_scan),
                  //label: Text('Add server'),
                  onPressed: _scanQrCode,
                ),
            ],
          ),
          body: _builder(logic),
        );
      },
    );
  }

  Widget _builder(SiteLogic logic) {
    if (logic.loading) {
      return LoadingWidget(
        loadingState: LoadingState.loading,
        message: 'Loading',
      );
    }
    return _buildList(context, logic) ?? _buildSiteForm(context);
  }

  Widget? _buildList(BuildContext context, SiteLogic logic) {
    List<SiteItem> sites = logic.sites;
    if (sites.length == 0) return null;

    if (null == _expandedSite) _expandedSite = logic.currentSite;

    SiteItem? _currentSite = logic.currentSite;
    String? selectedSpeciesId = _currentSite?.currentSpeciesId;

    return ListView.builder(
      itemCount: sites.length,
      itemBuilder: (c, index) {
        SiteItem siteItem = sites[index];
        bool siteSelected = siteItem.sid == _currentSite?.sid;
        return ListTile(
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
          selected: siteSelected,
          leading: Builder(builder: (context) {
            return IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: siteItem.editable ? () => _showSiteMenu(context, siteItem) : null,
            );
          }),
          onTap: () => _showSpeciesListModel(context, siteItem, selectedSpeciesId!),
        ).withBottomBorder(color: Theme.of(context).dividerColor);
      },
    );

//    return SingleChildScrollView(
//      child: Column(
//        children: sites.map((siteItem) {
//          bool siteSelected = siteItem.id == _currentSite?.id;
//          var spsList = SpeciesListWidget(
//              site: siteItem,
//              selectedSpecies: selectedSpeciesId,
//              onItemTap: (sps) {
//                _onSpeciesChange(context, siteItem, sps);
//                if (Navigator.of(context).canPop()) {
//                  Navigator.of(context).pop(siteItem);
//                } else {
//                  Navigator.of(context).pushReplacementNamed(RoutePath.home, arguments: siteItem);
//                }
//              });
//          return Card(
//            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//            child: Column(
//              mainAxisSize: MainAxisSize.min,
//              crossAxisAlignment: CrossAxisAlignment.start,
//              children: [
//                ListTile(
//                  title: Text(
//                    '${siteItem.name}',
//                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w300),
//                  ),
//                  subtitle: Text('${siteItem.url}'),
//                  selected: siteSelected,
////                  leading: siteSelected
////                      ? IconButton(
////                          icon: Icon(Icons.mode_edit),
////                          onPressed: () => _editOrAddSite(context, siteItem),
////                        )
////                      : null,
////              onLongPress: () => _editOrAddSite(context, siteItem),
//                ),
//                Padding(
//                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//                  child: Text(
//                    'Species list of this Server. To get started, you need to select a species first!',
//                    style: Theme.of(context).textTheme.caption.copyWith(fontWeight: FontWeight.w300, fontSize: 16),
//                  ),
//                ),
//                spsList,
//              ],
//            ),
//          );
//        }).toList(),
//      ),
//    );

//    return SingleChildScrollView(
//      child: Container(
//        child: ExpansionPanelList(
//          key: Key('${state.hashCode}'),
//          children: sites.map<ExpansionPanel>(_buildPanel).toList(),
//          expansionCallback: (index, isExpanded) {
//            setState(() {
//              if (isExpanded) {
//                _expandedSite = null;
//              } else {
//                _expandedSite = sites[index];
//              }
//            });
//          },
//        ),
//      ),
//    );
  }

  _onSpeciesChange(BuildContext context, SiteItem siteItem, Species species) {
    siteItem.currentSpecies = species.name;
    siteItem.currentSpeciesId = '${species.id}';
    logic.changeSpecies(siteItem, species: species);
  }

  _showSpeciesListModel(BuildContext context, SiteItem site, String selectedId) async {
    var result = await showModalBottomSheet(
      context: context,
//      isScrollControlled: true,
      builder: (c) => DataSetListWidget(
        asPage: true,
        site: site,
        selectedSpecies: selectedId,
        onItemTap: (sps) {
          Navigator.of(context).pop(sps);
        },
      ),
    );
    if (null != result) {
      _onSpeciesChange(context, site, result);
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(site);
      }
//      else {
//        Navigator.of(context).pushReplacementNamed(RoutePath.home, arguments: siteItem);
//      }
    }
  }

  void _editOrAddSite(BuildContext context, [SiteItem? siteItem]) async {
    GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    SiteItem _siteItem = siteItem ?? SiteItem(url: '');
    var dialog = AlertDialog(
      title: Text(siteItem != null ? 'Edit server' : 'Add new server'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('CANCEL'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            padding: EdgeInsets.symmetric(horizontal: 20),
          ),
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            _formKey.currentState!.save();
            Navigator.of(context).pop(_siteItem);
          },
          child: Text(null == siteItem ? 'ADD' : 'SAVE'),
        ),
        SizedBox(width: 10),
      ],
      content: Container(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'http://www.sgs.com:8080',
                  labelText: 'Server Url *',
                  alignLabelWithHint: true,
                  helperText: 'url is required',
//                border: inputBorder(),
                ),
                initialValue: _siteItem.url ?? '',
                validator: (value) {
                  if (value!.length == 0) return 'url is empty';
                  var regexp = RegExp('(https?|ftp|file)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]');
                  bool match = regexp.hasMatch(value);
                  return match ? null : 'url is not valid';
                },
                onSaved: (value) {
                  _siteItem.url = value!;
                },
                maxLines: 1,
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'name your server',
                  labelText: 'Server Name (Optional)',
//                border: inputBorder(),
                ),
                initialValue: _siteItem.name ?? '',
//              validator: (value) {
//                if (value.isEmpty) return 'Name is empty';
//                return null;
//              },
                onSaved: (value) {
                  _siteItem.name = value ?? '';
                },
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
    SiteItem? __siteItem = await showDialog<SiteItem>(context: context, builder: (context) => dialog);
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

  _showSiteMenu(BuildContext context, SiteItem site) async {
    showAttachedWidget(
        preferDirection: PreferDirection.rightTop,
        targetContext: context,
        attachedBuilder: (cancel) {
          return Material(
            elevation: 6,
            color: Theme.of(context).dialogBackgroundColor,
            shape: modelShape(),
            child: Container(
              constraints: BoxConstraints.tightFor(width: 200),
              child: SettingListWidget(
                settings: [
                  SettingItem.button(title: 'Edit Server', key: 'edit', prefix: Icon(Icons.edit)),
                  SettingItem.button(title: 'Delete Server', key: 'delete', prefix: Icon(Icons.delete)),
                ],
                onItemTap: (item, ctx) {
                  if (item.key == 'edit') {
                    _editOrAddSite(context, site);
                  } else {
                    cancel();
                    logic.deleteSite(site);
                  }
                },
              ),
            ),
          );
        });
  }

  _deleteConfirm(BuildContext context, SiteItem site) async {
    var dialog = AlertDialog(
      title: Text('Delete Server?'),
      content: Text("Are you sure wan't to delete server { ${site.name} } ?"),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: Text('CANCEL'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: Text('DELETE'),
        ),
        SizedBox(width: 10),
      ],
    );
    var result = await showDialog(context: context, builder: (context) => dialog);
    if (result) {
      logic.deleteSite(site);
    }
  }

  _scanQrCode() async {
    String? qrResult = await MajaScan.startScan(
      title: 'QRCode scanner',
      barColor: Theme.of(context).colorScheme.primary,
      titleColor: Colors.white,
      qRCornerColor: Colors.blue,
      qRScannerColor: Colors.deepPurple,
      flashlightEnable: true,
    );
    showToast(text: '$qrResult');
  }

  @override
  void dispose() {
    super.dispose();
  }
}
