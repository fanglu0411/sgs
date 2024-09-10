import 'dart:convert';
import 'dart:math';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/components/setting_config_widget.dart';
import 'package:flutter_smart_genome/storage/base_store_provider.dart';

import 'package:flutter_smart_genome/util/file_util.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:flutter_smart_genome/widget/track/base/track_theme.dart';
import 'package:pretty_json/pretty_json.dart';

class TrackThemeListWidget extends StatefulWidget {
//  final Map<String, FeatureStyle> baseFeatures;

  final int? currentFeatureTheme;
  final ValueChanged<TrackTheme>? onMore;
  final ValueChanged<TrackTheme>? onThemeChange;
  final bool smallSize;

  TrackThemeListWidget({
    Key? key,
    this.currentFeatureTheme,
    this.onMore,
//    this.baseFeatures = const {},
    this.onThemeChange,
    this.smallSize = false,
  }) : super(key: key);

  @override
  _TrackThemeListWidgetState createState() => _TrackThemeListWidgetState();
}

class _TrackThemeListWidgetState extends State<TrackThemeListWidget> {
  int? _currentThemeHash;

  List<TrackTheme> _trackThemes = [];

  @override
  void initState() {
    super.initState();
    _currentThemeHash = widget.currentFeatureTheme;
    _loadFeatureThemes();
  }

  void _loadFeatureThemes() async {
    _currentThemeHash = (await BaseStoreProvider.get().getCurrentTrackTheme())?.name.hashCode;
    _trackThemes = await BaseStoreProvider.get().getAllTrackTheme();
    _trackThemes.forEach((t) => t.brightness = Theme.of(context).brightness);
    _trackThemes.sort((a, b) => a.name.compareTo(b.name));
    if (_currentThemeHash == null && _trackThemes.length > 0) {
      _currentThemeHash = _trackThemes.first.name.hashCode;
    }
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant TrackThemeListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _trackThemes.forEach((t) => t.brightness = Theme.of(context).brightness);
  }

  // todo
  void _createTheme() async {
    String name = 'Theme ${Random().nextInt(9999)}';
    TrackTheme themeBeanLight = TrackTheme.defaultTheme(name, Theme.of(context).brightness);
    BaseStoreProvider.get().addTrackTheme(themeBeanLight);
    setState(() {
      _trackThemes.add(themeBeanLight);
      _currentThemeHash = themeBeanLight.name.hashCode;
    });

    widget.onThemeChange?.call(themeBeanLight);
  }

  _parseThemeFile(String path, content) async {
    try {
      String name = path.substring(path.lastIndexOf('/') + 1);
      name = name.split('.').first;
      TrackTheme theme = TrackTheme(name, json.decode(content), Theme.of(context).brightness);
      _trackThemes.add(theme);
      await BaseStoreProvider.get().addTrackTheme(theme);
      showSuccessNotification(title: Text('Import theme finish'));
      setState(() {});
    } catch (e) {
      showErrorNotification(title: Text('Import theme error'), subtitle: Text('${e}'));
    }
  }

  void _importTheme() async {
    FileUtil.readFile(callback: _parseThemeFile);
  }

  void _deleteThemes(TrackTheme themeBean) async {
    await BaseStoreProvider.get().deleteTrackTheme(themeBean);
    _trackThemes.removeWhere((element) => element.name == themeBean.name);
    setState(() {});
  }

  void _changeTheme(TrackTheme themeBean) {
    widget.onThemeChange?.call(themeBean);
    setState(() {
      _currentThemeHash = themeBean.name.hashCode;
    });
  }

  void _themeMoreMenu(BuildContext context, TrackTheme themeBean) {
    showAttachedWidget(
      targetContext: context,
      preferDirection: PreferDirection.bottomRight,
      attachedBuilder: (cancel) {
        final settings = [
          SettingItem.button(key: 'k-rename', title: 'Rename Theme', suffix: Icon(Icons.edit_note, size: 18)),
          SettingItem.button(key: 'k-reset', title: 'Reset Theme', suffix: Icon(Icons.replay, size: 19)),
          SettingItem.button(key: 'k-export', title: 'Export Theme', suffix: Icon(MaterialCommunityIcons.export, size: 18)),
          SettingItem.button(key: 'k-delete', title: 'Delete Theme', suffix: Icon(Icons.delete, color: Colors.red)),
        ];
        return Material(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: BoxConstraints.tightFor(width: 250),
            child: SettingListWidget(
              settings: settings,
              onItemTap: (item, c) {
                cancel();
                _themeControl(context, item, themeBean);
              },
            ),
          ),
        );
      },
    );
  }

  void _themeControl(BuildContext context, SettingItem item, TrackTheme themeBean) {
    switch (item.key) {
      case 'k-rename':
        _renameThemeDialog(context, themeBean);
        break;
      case 'k-reset':
        _resetTheme(themeBean);
        break;
      case 'k-export':
        //_exportTheme(themeBean);
        _saveThemeFile(themeBean);
        break;
      case 'k-delete':
        _deleteThemes(themeBean);
        break;
    }
  }

  void _renameThemeDialog(BuildContext context, TrackTheme themeBean) {
    TextEditingController _controller = TextEditingController(text: themeBean.name.replaceAll('-Dark', '').replaceAll('-Light', ''));
    showAttachedWidget(
      targetContext: context,
      preferDirection: PreferDirection.bottomCenter,
      attachedBuilder: (cancel) {
        return Material(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Container(
            constraints: BoxConstraints.tightFor(width: 300),
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text('Rename Theme', style: Theme.of(context).textTheme.bodyLarge),
                ),
                TextField(
                  controller: _controller,
                ),
                ButtonBar(
                  children: [
                    TextButton(
                      onPressed: cancel,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Text('CANCEL'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: () {
                        cancel();
                        _renameTheme(themeBean, _controller.text);
                      },
                      child: Text('OK'),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _renameTheme(TrackTheme trackTheme, String name) async {
    if ((name).trim().length == 0) return;
    await BaseStoreProvider.get().deleteTrackTheme(trackTheme);
    trackTheme.name = name;
    await BaseStoreProvider.get().addTrackTheme(trackTheme);
    setState(() {});
  }

  void _resetTheme(TrackTheme trackTheme) async {
    trackTheme.resetDefault();
    await BaseStoreProvider.get().setTrackTheme(trackTheme);
    _loadFeatureThemes();
    //widget.onThemeChange(themeBean);
  }

  void _exportTheme(TrackTheme themeBean) async {
    Map<String, dynamic> map = themeBean.persistJson;
    Widget contentBuilder(BuildContext context, [cancel]) {
      var size = MediaQuery.of(context).size;
      return Material(
        shape: modelShape(context: context),
        child: Container(
          constraints: BoxConstraints.tightFor(width: size.width * .5, height: size.height * .8),
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text('${themeBean.name}', style: Theme.of(context).textTheme.titleLarge),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.file_download),
                    tooltip: 'save to file',
                    onPressed: () => _saveThemeFile(themeBean),
                  ),
                  IconButton(
                    icon: Icon(Icons.content_copy),
                    tooltip: 'Copy to clipboard',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: prettyJson(map)));
                      showToast(text: 'Theme data copied');
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: cancel,
                    tooltip: 'Close',
                  ),
                ],
              ),
              Expanded(child: SingleChildScrollView(child: SelectableText(prettyJson(map)))),
            ],
          ),
        ),
      );
    }

    //await showDialog(context: context, builder: contentBuilder, barrierDismissible: true);

    BotToast.showCustomLoading(
      toastBuilder: (cancel) => contentBuilder(context, cancel),
      clickClose: true,
      backgroundColor: Colors.black54,
    );
  }

  void _saveThemeFile(TrackTheme trackTheme) async {
    String content = json.encode(trackTheme.persistJson);
    FileUtil.saveFile('${trackTheme.name}.json', content).then((value) {
      showSuccessNotification(title: Text('Export theme success!'), subtitle: Text('save file to ${trackTheme.name}.json'));
    });
  }

  void _deleteThemeDialog(BuildContext context, TrackTheme themeBean) {
    showAttachedWidget(
      targetContext: context,
      preferDirection: PreferDirection.bottomCenter,
      attachedBuilder: (cancel) {
        return Card(
          child: Container(
            constraints: BoxConstraints.tightFor(width: 300),
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text('Delete Theme?', style: Theme.of(context).textTheme.titleLarge),
                ),
                Text('Are you sure want to delete theme ${themeBean.name} ?', style: Theme.of(context).textTheme.bodyLarge),
                ButtonBar(
                  children: [
                    TextButton(
                      onPressed: cancel,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Text('CANCEL'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: () => _deleteThemes(themeBean),
                      child: Text('DELETE'),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var _children = _trackThemes.map((e) {
      bool enabled = true;
      return Builder(
        builder: (context) {
          bool _selected = _currentThemeHash == e.name.hashCode;
          return ListTile(
            horizontalTitleGap: 6,
            selected: _selected,
            selectedTileColor: Theme.of(context).colorScheme.primary.withAlpha(10),
            enabled: enabled,
            contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            leading: Checkbox(
              value: _selected,
              onChanged: enabled ? (v) => _changeTheme(e) : null,
            ),
            onTap: enabled ? () {} : null,
            title: Text(e.name, style: _selected ? TextStyle(color: Theme.of(context).colorScheme.primary) : null),
            trailing: _selected
                ? IconButton(
                    icon: Icon(Icons.color_lens),
                    tooltip: 'Edit Theme',
                    onPressed: enabled ? () => widget.onMore?.call(e) : null,
                  )
                : IconButton(
                    icon: Icon(Icons.more_vert),
                    onPressed: enabled ? () => _themeMoreMenu(context, e) : null,
                  ),
//            onLongPress: _selected ? null : () => _renameThemeDialog(context, e),
          );
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: widget.smallSize ? null : Text('Track Theme'),
        // backgroundColor: widget.smallSize ? Colors.transparent : null,
        toolbarHeight: widget.smallSize ? 30 : null,
        automaticallyImplyLeading: !widget.smallSize,
        actions: [
          IconButton(
            icon: Icon(MaterialCommunityIcons.file_import),
            iconSize: widget.smallSize ? 18 : 20,
            padding: EdgeInsets.zero,
            tooltip: 'Import Theme',
            onPressed: _importTheme,
          ),
          IconButton(
            icon: Icon(Icons.add),
            padding: EdgeInsets.zero,
            iconSize: widget.smallSize ? 18 : 20,
            tooltip: 'Create Theme',
            onPressed: _createTheme,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...ListTile.divideTiles(tiles: _children, context: context).toList(),
            if (!widget.smallSize)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
//                color: Theme.of(context).colorScheme.primary,
                  onPressed: _createTheme,
                  icon: Icon(Icons.add),
                  label: Text('Create Theme'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
