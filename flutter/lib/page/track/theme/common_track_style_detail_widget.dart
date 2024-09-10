import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/components/setting_config_widget.dart';
import 'package:flutter_smart_genome/widget/track/base/track_menu_config.dart';
import 'package:flutter_smart_genome/widget/track/base/track_style.dart';

class CommonTrackStyleDetailWidget extends StatefulWidget {
  final VoidCallback? onClose;
  final TrackStyle trackStyle;
  final ValueChanged<TrackStyle>? onChanged;
  final List<String> featureTypes;

  const CommonTrackStyleDetailWidget({
    Key? key,
    required this.trackStyle,
    this.onChanged,
    this.onClose,
    this.featureTypes = const [],
  }) : super(key: key);

  @override
  _CommonTrackStyleDetailWidgetState createState() => _CommonTrackStyleDetailWidgetState();
}

class _CommonTrackStyleDetailWidgetState extends State<CommonTrackStyleDetailWidget> {
  // List<SettingItem> settingItems;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CommonTrackStyleDetailWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    widget.trackStyle.brightness = Theme.of(context).brightness;
    List<SettingItem> settings = widget.trackStyle.toSettingList()..removeWhere((s) => s.key == TrackContextMenuKey.color_map);
    bool hasColorMap = widget.trackStyle.hasColorMap;

    var commonSettings = SettingListWidget(
      // title: _selectedFeatureStyleKey,
      settings: settings,
      scroll: !hasColorMap,
      onItemChanged: (p, item) {
        widget.trackStyle.fromSetting(item);
        widget.onChanged?.call(widget.trackStyle);
      },
    );

    if (widget.trackStyle.hasColorMap) {
      // Map<String, Color> colorMap = widget.trackStyle.colorMap ?? {};
      var colorMapListKeys = widget.trackStyle.colorMapListKeys;
      // List<SettingItem> colorSettings = colorMap.keys.map((e) => SettingItem.color(title: e, key: '$e', value: colorMap[e])).toList();
      return SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            commonSettings,
            Divider(height: 1),
            SizedBox(height: 10),

            for (var ck in colorMapListKeys) ...[
              Container(
                child: Text('${ck}'),
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withAlpha(10),
                  border: Border(
                    left: BorderSide(width: 4, color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ),
              SettingListWidget(
                scroll: false,
                settings: widget.trackStyle.getColorMap(ck)!.map((k, v) => MapEntry(k, SettingItem.color(title: '$k', key: '${ck}.${k}', value: v))).values.toList(),
                onItemChanged: (p, item) {
                  widget.trackStyle.setColor(item.key, item.value);
                  // widget.trackStyle.setColorMapEntry(item.key, item.value); //[item.key] = item.value;
                  widget.onChanged?.call(widget.trackStyle);
                },
              )
            ],

            // Container(
            //   child: Text('Color Map'),
            //   padding: EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            //   decoration: BoxDecoration(
            //     color: Theme.of(context).selectedRowColor,
            //     border: Border(
            //       left: BorderSide(width: 4, color: Theme.of(context).colorScheme.primary.withOpacity(.5)),
            //     ),
            //   ),
            // ),
            // SettingListWidget(
            //   scroll: false,
            //   settings: colorSettings,
            //   onItemChanged: (item) {
            //     widget.trackStyle.setColorMapEntry(item.key, item.value); //[item.key] = item.value;
            //     widget.onChanged?.call(widget.trackStyle);
            //   },
            // )
          ],
        ),
      );
    }
    return commonSettings;
  }
}
