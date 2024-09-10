import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/base/ui_config.dart';
import 'package:flutter_smart_genome/components/setting_config_widget.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:flutter_smart_genome/widget/basic/fixed_color_picker.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/base/track_menu_config.dart';

const double TRACK_TITLE_HEIGHT = 22;

class TrackTitleWidget extends StatefulWidget {
  final Track track;
  final ValueChanged<SettingItem>? onItemTap;
  final ValueChanged<BuildContext>? onSettingTap;
  final bool loading;
  final Color? trackColor;
  final bool? showLabel;
  final TrackViewType? viewType;

  const TrackTitleWidget({
    Key? key,
    this.loading = false,
    required this.track,
    this.onSettingTap,
    this.onItemTap,
    this.trackColor,
    this.showLabel,
    this.viewType,
  }) : super(key: key);

  @override
  TrackTitleWidgetState createState() => TrackTitleWidgetState();
}

class TrackTitleWidgetState extends State<TrackTitleWidget> {
  late SettingItem _colorItem;
  late SettingItem _labelItem;

  late bool _loading;

  @override
  void didUpdateWidget(TrackTitleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _colorItem.value = widget.trackColor;
    _labelItem.value = widget.showLabel ?? false;
    _loading = widget.loading;
  }

  @override
  void initState() {
    super.initState();
    _loading = widget.loading;
    _colorItem = SettingItem.color(key: TrackContextMenuKey.track_color, value: widget.trackColor);
    _labelItem = SettingItem.toggle(key: TrackContextMenuKey.show_label, value: widget.showLabel ?? false);
  }

  void set loading(bool loading) {
    _loading = loading;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    bool _dark = Theme.of(context).brightness == Brightness.dark;
    bool _mobile = isMobile(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
//          Text('Track Height:'),
//          NumberFieldWidget(
//            value: 10,
//            width: 36,
//          ),
//          VerticalDivider(width: 1),
//          SizedBox(width: 10),
        if (!_mobile && widget.viewType == TrackViewType.cartesian)
          IconButton(
            tooltip: 'Track Color',
            padding: EdgeInsets.all(0),
            icon: Icon(Icons.lens),
            color: _colorItem.value!,
            onPressed: () => _showColorPicker(context, _colorItem),
          ),
//          VerticalDivider(width: 1),
//          IconButton(
//            padding: EdgeInsets.symmetric(horizontal: 0),
//            iconSize: 16,
//            icon: Icon(MaterialCommunityIcons.format_line_style),
//            tooltip: '',
//            onPressed: () {},
//          ),
        if (widget.viewType != TrackViewType.cartesian) VerticalDivider(width: 1),
        if (widget.viewType != TrackViewType.cartesian)
          TextButton.icon(
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 4),
              textStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
            onPressed: () {
              setState(() {
                _labelItem..value = !_labelItem.value;
                widget.onItemTap?.call(_labelItem);
              });
            },
            icon: Icon(_labelItem.value ? Icons.check_box : Icons.check_box_outline_blank),
            label: Text('Label'),
          ),
//        SizedBox(width: 10),
        VerticalDivider(width: 1),
//          SizedBox(width: 10),
        IconButton(
          padding: EdgeInsets.symmetric(horizontal: 0),
          iconSize: 20,
          onPressed: () {
            widget.onItemTap?.call(SettingItem.button(key: TrackContextMenuKey.track_theme));
          },
          icon: Icon(MaterialCommunityIcons.format_line_style),
          tooltip: 'Feature Theme',
        ),
//          SizedBox(width: 10),
        VerticalDivider(width: 1),
        Builder(builder: (context) {
          return IconButton(
            padding: EdgeInsets.symmetric(horizontal: 0),
            iconSize: 20,
            icon: Icon(Icons.settings),
            tooltip: 'More settings',
            onPressed: () => widget.onSettingTap?.call(context),
          );
        }),
      ],
    );
  }

  void _showColorPicker(BuildContext context, SettingItem item) {
    var colorPicker = FixedColorPicker(
      colorPickerWidth: 200,
      showLabel: true,
      pickerColor: item.value,
      onColorChanged: (color) {
        item.value = color;
        setState(() {});
        widget.onItemTap?.call(item);
      },
    );
    showAttachedWidget(
      targetContext: context,
      preferDirection: PreferDirection.bottomRight,
      attachedBuilder: (cancel) {
        return Container(
          constraints: BoxConstraints.tightFor(width: 300),
          //decoration: defaultContainerDecoration(context),
          child: Material(
            elevation: 8,
//              color: Colors.grey[200],
            shape: modelShape(context: context),
            child: colorPicker,
          ),
        );
      },
    );
  }
}
