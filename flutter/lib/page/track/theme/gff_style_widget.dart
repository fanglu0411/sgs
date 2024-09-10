import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/field_item.dart' as f;
import 'package:flutter_smart_genome/components/setting_config_widget.dart';
import 'package:flutter_smart_genome/storage/base_store_provider.dart';

import 'package:flutter_smart_genome/widget/basic/scroll_controller_builder.dart';
import 'package:flutter_smart_genome/widget/basic/simple_form.dart';
import 'package:flutter_smart_genome/widget/split_widget.dart' as sw;
import 'package:flutter_smart_genome/widget/track/base/feature_style_mixin.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/base/track_menu_config.dart';
import 'package:flutter_smart_genome/widget/track/base/track_theme.dart';
import 'package:flutter_smart_genome/widget/track/painter/feature_style_config.dart';
import 'package:flutter_smart_genome/extensions/widget_extensions.dart';
import 'package:get/get.dart';

class GffThemeDetailWidget<T extends FeaturedStyleMixin> extends StatefulWidget {
  final VoidCallback? onClose;
  final T trackStyle;
  final ValueChanged<FeaturedStyleMixin>? onChanged;
  final List<String> featureTypes;
  final TrackType trackType;
  final String? trackThemeName;

  GffThemeDetailWidget({
    Key? key,
    required this.trackStyle,
    this.onChanged,
    this.onClose,
    this.featureTypes = const [],
    this.trackType = TrackType.gff,
    this.trackThemeName,
  }) : super(key: key) {}

  @override
  _GffThemeDetailWidgetState createState() => _GffThemeDetailWidgetState();
}

class _GffThemeDetailWidgetState extends State<GffThemeDetailWidget> {
  String? expandedKey;

  Map<String, bool> expansionMap = {};
  bool _checkAll = true;
  String? _selectedFeatureStyleKey;
  Key _splitKey = Key('split-feature');

  @override
  void initState() {
    super.initState();
    Map<String, FeatureStyle> features = widget.trackStyle.featureStyles;
    for (String key in features.keys) {
      if (!features[key]!.visible) {
        _checkAll = false;
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody();
    // return Scaffold(
    //   appBar: AppBar(
    //     leading: widget.onClose != null ? CloseButton(onPressed: widget.onClose) : null,
    //     title: Text('${widget.trackStyle.name}'),
    //   ),
    //   body: _buildBody(),
    // );
  }

  Widget _buildBody() {
    Widget _featureListView = _buildFeatureList();
    if (_selectedFeatureStyleKey == null) {
      return _featureListView;
    }
    Widget _currentFeatureStyleView = _buildFeatureStyleWidget();
    return sw.Split(
      key: _splitKey,
      children: [
        _featureListView,
        _currentFeatureStyleView,
      ],
      minSizes: [200, 320],
      initialFractions: [.65, .35],
    );
  }

  Widget _buildFeatureList() {
    List _keys = widget.trackStyle.featureList;
    List<Widget> _children = _keys.map((e) {
      return _buildItem(context, e);
    }).toList();
    return ScrollControllerBuilder(builder: (context, c) {
      return ListView(
        controller: c,
        children: [
          ListTile(
            title: Text('Basic style'),
            horizontalTitleGap: 4,
            minVerticalPadding: 2,
            visualDensity: VisualDensity(horizontal: -2, vertical: -2),
            leading: SizedBox(width: 24, height: 24),
            // Checkbox(value: true, onChanged: null),
            selected: _selectedFeatureStyleKey == 'Basic style',
            trailing: Icon(Icons.keyboard_arrow_right, color: Theme.of(context).colorScheme.primary),
            onTap: () {
              setState(() {
                _selectedFeatureStyleKey = 'Basic style';
              });
            },
          ).withBottomBorder(color: Theme.of(context).dividerColor),
          ..._children,
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                textStyle: TextStyle(color: Colors.white),
              ),
              onPressed: _onAddFeatureStyle,
              icon: Icon(Icons.add),
              label: Text('Add Feature Type'),
            ),
          ),
          if (TrackType.bed == widget.trackType)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Center(
                  child: Text(
                'More feature style, see gff track theme',
                style: Theme.of(context).textTheme.bodySmall,
              )),
            ),
        ],
      );
    });
  }

  void _onAddFeatureStyle() {
    // TextEditingController _controller = TextEditingController();
    var form = SimpleForm(
      inputBorder: OutlineInputBorder(),
      // divider: Divider(height: 1),
      fields: [
        f.FieldItem.name(
          name: 'featureStyleName',
          required: true,
          label: 'Feature Style Name',
          hint: 'input feature style name',
        ),
        f.FieldItem(
          name: 'add-to-all-theme',
          value: false,
          label: 'Add to all theme',
          hint: 'Add feature style to all theme',
          fieldType: f.FieldType.switcher,
        ),
      ],
      resetLabel: 'CANCEL',
      onReset: () {
        Navigator.pop(context);
      },
      onSubmit: (map) {
        Navigator.pop(context);
        _addFeatureStyle(map['featureStyleName'], allTheme: map['add-to-all-theme']);
      },
    );

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Add feature style'),
        content: Container(width: 300, child: form),
      ),
    );
  }

  void _addFeatureStyle(String name, {bool allTheme = true}) async {
    if (name.trim().length == 0) return;
    String id = name.trim().toLowerCase();
    var customFeatureStyle = FeatureStyle(name: name, id: id, color: Colors.green, isCustom: true);
    widget.trackStyle.addFeatureStyle(id, customFeatureStyle);
    setState(() {});

    var _trackThemes = await BaseStoreProvider.get().getAllTrackTheme();
    if (allTheme) {
      _trackThemes.forEach((theme) async {
        await __addFeatureStyleToTrackTheme(theme, customFeatureStyle);
      });
    } else {
      var theme = _trackThemes.firstWhereOrNull((t) => t.name == widget.trackThemeName);
      if (theme != null) {
        await __addFeatureStyleToTrackTheme(theme, customFeatureStyle);
      }
    }
  }

  __addFeatureStyleToTrackTheme(TrackTheme trackTheme, FeatureStyle featureStyle) async {
    FeaturedStyleMixin? trackStyle = trackTheme.getTrackStyle(widget.trackType) as FeaturedStyleMixin?;
    trackStyle?.addFeatureStyle(featureStyle.id, featureStyle);
    trackTheme.setTrackStyle(widget.trackType, trackStyle!);
    await BaseStoreProvider.get().setTrackTheme(trackTheme);
  }

  void _deleteFeatureStyle(FeatureStyle featureStyle) async {
    String id = featureStyle.id;
    widget.trackStyle.deleteFeatureStyle(id);
    _selectedFeatureStyleKey = null;
    setState(() {});
    var _trackThemes = await BaseStoreProvider.get().getAllTrackTheme();
    _trackThemes.forEach((theme) async {
      FeaturedStyleMixin trackStyle = theme.getTrackStyle(widget.trackType) as FeaturedStyleMixin;
      trackStyle.deleteFeatureStyle(id);
      theme.setTrackStyle(widget.trackType, trackStyle);
      await BaseStoreProvider.get().setTrackTheme(theme);
    });
  }

  void _deleteFeatureStyleConfirm(FeatureStyle featureStyle) async {
    var result = await showDialog(
        context: context,
        builder: (c) => AlertDialog(
              title: Text('Delete feature style [${featureStyle.name}] ?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text('No'),
                ),
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text('DELETE'),
                ),
              ],
            ));
    if (result ?? false) {
      _deleteFeatureStyle(featureStyle);
    }
  }

  Widget _buildFeatureStyleWidget() {
    Widget _widget;
    String title;
    if (_selectedFeatureStyleKey == 'Basic style') {
      title = 'Basic style';
      List<SettingItem> settings = TrackMenuConfig.gffTrackBasicStyleSettings;
      widget.trackStyle.registerSettings(settings);
      _widget = SettingListWidget(
        // title: _selectedFeatureStyleKey,
        settings: settings,
        onItemChanged: (p, item) {
          widget.trackStyle.fromSetting(item);
          widget.onChanged?.call(widget.trackStyle);
        },
      );
    } else {
      FeatureStyle _featureStyle = widget.trackStyle.getFeatureStyle(_selectedFeatureStyleKey!);
      title = _featureStyle.name;
      _widget = FeatureStyleWidget(
        featureStyle: _featureStyle,
        onChanged: (featureStyle) {
          setState(() {});
          widget.trackStyle.setFeatureStyle(_selectedFeatureStyleKey!, featureStyle);
          widget.onChanged?.call(widget.trackStyle);
        },
        onDelete: _deleteFeatureStyleConfirm,
      );
    }

    return Material(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            dense: true,
            tileColor: Theme.of(context).colorScheme.primary.withOpacity(.15),
            title: Text(
              '${title}',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            trailing: IconButton(
              icon: Icon(Icons.close),
              padding: EdgeInsets.zero,
              iconSize: 22,
              tooltip: 'Close',
              splashRadius: 18,
              constraints: BoxConstraints.tightFor(width: 30, height: 30),
              onPressed: () {
                setState(() {
                  _selectedFeatureStyleKey = null;
                });
              },
            ),
          ),
          _widget,
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, String featureKey) {
    FeatureStyle _featureStyle = widget.trackStyle.getFeatureStyle(featureKey);
    Widget training = Icon(Icons.keyboard_arrow_right, color: Theme.of(context).colorScheme.primary);
    return ListTile(
      dense: true,
      selected: _selectedFeatureStyleKey == featureKey,
      // selectedTileColor: Theme.of(context).selectedRowColor,
      contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      visualDensity: VisualDensity(horizontal: -2, vertical: -2),
      leading: _previewStyleWidget(_featureStyle),
      // Checkbox(
      //   value: _featureStyle.visible,
      //   onChanged: (value) {
      //     setState(() {
      //       _featureStyle.visible = value;
      //       widget.onChanged?.call(widget.trackStyle);
      //     });
      //   },
      // ),
      title: Text('${_featureStyle.name}', style: TextStyle(fontSize: 16)),
      subtitle: Row(
        children: [
          // Container(
          //   decoration: BoxDecoration(
          //     color: _featureStyle.colorWithAlpha,
          //     border: _featureStyle.hasBorder ? Border.all(color: _featureStyle.borderColor, width: _featureStyle.borderWidth) : null,
          //   ),
          //   width: 16,
          //   height: 16,
          // ),
          // SizedBox(width: 6),
          if (_featureStyle.alpha > 0)
            Text(
              '${_featureStyle.colorWithAlpha.value.toRadixString(16).toUpperCase()}',
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    height: 1.5,
                    color: _featureStyle.colorWithAlpha,
                    fontSize: 12,
                  ),
            ),
          if (_featureStyle.alpha > 0) SizedBox(width: 10),
          if (_featureStyle.borderWidth > 0)
            Text(
              '${_featureStyle.borderColor!.value.toRadixString(16).toUpperCase()}',
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    height: 1.5,
                    color: _featureStyle.borderColor,
                    fontSize: 12,
                  ),
            )
        ],
      ),
      trailing: training,
      onTap: () {
        setState(() {
          _selectedFeatureStyleKey = featureKey;
        });
      },
    ).withBottomBorder(color: Theme.of(context).dividerColor);
  }

  Widget _previewStyleWidget(FeatureStyle _featureStyle) {
    return Container(
      width: 24,
      alignment: Alignment.center,
      child: Container(
        decoration: BoxDecoration(
          color: _featureStyle.colorWithAlpha,
          border: _featureStyle.hasBorder ? Border.all(color: _featureStyle.borderColor!, width: _featureStyle.borderWidth) : null,
          borderRadius: _featureStyle.radius == null ? null : BorderRadius.circular(_featureStyle.radius),
        ),
        width: 24,
        height: 24 * _featureStyle.height,
      ),
    );
  }
}

class FeatureStyleWidget extends StatefulWidget {
  final FeatureStyle featureStyle;
  final ValueChanged<FeatureStyle>? onDelete;
  final ValueChanged<FeatureStyle>? onChanged;

  const FeatureStyleWidget({
    Key? key,
    required this.featureStyle,
    this.onChanged,
    this.onDelete,
  }) : super(key: key);

  @override
  _FeatureStyleWidgetState createState() => _FeatureStyleWidgetState();
}

class _FeatureStyleWidgetState extends State<FeatureStyleWidget> {
  @override
  Widget build(BuildContext context) {
    FeatureStyle featureStyle = widget.featureStyle;
    Color _color = Theme.of(context).brightness == Brightness.dark ? Colors.grey[900]! : Colors.grey[50]!;
    return Material(
      color: _color,
      child: SettingListWidget(
        settings: [
          SettingItem.toggle(title: 'Enable', key: 'enable', value: featureStyle.visible),
          SettingItem.color(title: 'Color', key: 'color', value: featureStyle.color),
          SettingItem.range(title: 'Height Percent', key: 'height', value: featureStyle.height, step: .1, min: 0.1, max: 1.0),
          SettingItem.range(title: 'Radius', key: 'radius', value: featureStyle.radius, step: 1.0, min: 0.0, max: 20.0),
          SettingItem.color(title: 'Border Color', key: 'borderColor', value: featureStyle.borderColor),
          SettingItem.range(title: 'Border Width', key: 'borderWidth', value: featureStyle.borderWidth, step: 1.0, min: 0.0, max: 10.0),
          if (featureStyle.isCustom) SettingItem.button(title: 'Delete', key: 'delete', suffix: Icon(Icons.delete)),
        ],
        onItemTap: (item, rect) {
          widget.onDelete?.call(featureStyle);
        },
        onItemChanged: (p, item) {
          //logger.d('${item.key} => ${item.value}');
          switch (item.key) {
            case 'color':
              featureStyle.color = item.value;
              featureStyle.alpha = featureStyle.color!.alpha;
              break;
            case 'height':
              featureStyle.height = item.value;
              break;
            case 'radius':
              featureStyle.radius = item.value;
              break;
            case 'borderColor':
              featureStyle.borderColor = item.value;
              break;
            case 'borderWidth':
              featureStyle.borderWidth = item.value;
              break;
            case 'enable':
              featureStyle.visible = item.value;
              break;
          }
          widget.onChanged?.call(featureStyle);
        },
      ),
    );
  }
}
