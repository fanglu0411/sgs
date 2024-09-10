import 'package:bot_toast/bot_toast.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/base/ui_config.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:flutter_smart_genome/widget/basic/fixed_color_picker.dart';
import 'package:flutter_smart_genome/extensions/string_extensions.dart';
import 'package:flutter_smart_genome/widget/basic/number_field_widget.dart';
import 'package:flutter_smart_genome/widget/toggle_button_group.dart';

enum FieldType {
  number,
  input,
  check_group,
  selection,
  button,
  toggle,
  color,
  row,
  row_color,
  hover,
}

class OptionItem {
  String title;
  dynamic value;
  Widget? prefix;

  OptionItem(this.title, this.value, [this.prefix]);
}

enum OptionListType {
  expanded,
  collapse,
  row,
}

typedef SettingValueBuilder = Widget Function(dynamic value);

class SettingItem {
  String? title;
  dynamic key;
  dynamic value;
  bool? enabled;
  double? max;
  double? min;
  double? step;
  late FieldType fieldType;
  List<OptionItem>? options;
  OptionListType optionListType = OptionListType.expanded;
  Widget? suffix;
  Widget? prefix;

  SettingValueBuilder? valueBuilder;

  List<SettingItem>? children;

  SettingItem.range({
    this.title,
    this.key,
    this.min = double.infinity,
    this.max = double.infinity,
    this.value,
    this.step,
    this.prefix,
    this.valueBuilder,
    this.enabled,
  }) : fieldType = FieldType.number;

  SettingItem.toggle({
    this.title,
    this.key,
    this.value,
    this.prefix,
    this.valueBuilder,
  }) : fieldType = FieldType.toggle;

  SettingItem.row({
    this.children,
    this.title,
    this.key,
  }) {
    fieldType = FieldType.row;
  }

  SettingItem.checkGroup({
    this.title,
    this.key,
    this.value,
    this.options,
    this.optionListType = OptionListType.expanded,
    this.prefix,
    this.valueBuilder,
  }) : fieldType = FieldType.check_group;

  SettingItem.selection({
    this.title,
    this.key,
    this.value,
    this.options,
    this.optionListType = OptionListType.expanded,
    this.prefix,
    this.valueBuilder,
  }) : fieldType = FieldType.selection;

  SettingItem.input({
    this.title,
    this.key,
    this.value,
    this.prefix,
    this.valueBuilder,
  }) : fieldType = FieldType.input;

  SettingItem.color({
    this.title,
    this.key,
    this.value,
    this.prefix,
    this.valueBuilder,
    this.fieldType = FieldType.color,
  });

  SettingItem({
    this.title,
    this.key,
    this.value,
    this.max,
    this.min,
    this.step = 1.0,
    this.prefix,
    this.valueBuilder,
    this.fieldType = FieldType.button,
  });

  SettingItem.button({
    this.title,
    this.key,
    this.value,
    this.prefix,
    this.suffix,
    this.valueBuilder,
  }) : fieldType = FieldType.button;

  SettingItem.hover({
    this.title,
    this.key,
    this.value,
    this.prefix,
    this.suffix,
    this.valueBuilder,
  }) : fieldType = FieldType.hover;

  @override
  String toString() {
    return 'SettingItem{title: $title, key: $key, value: $value, enabled: $enabled, max: $max, min: $min, fieldType: $fieldType}';
  }
}

typedef void OnMenuItemChanged(SettingItem? parentItem, SettingItem item);

class SettingListWidget extends StatefulWidget {
  final List<SettingItem> settings;
  final String? title;

  final Function2<SettingItem, Rect, void>? onItemTap;
  final OnMenuItemChanged? onItemChanged;
  final Function3<SettingItem, bool, Rect?, void>? onItemHover;
  final ValueChanged<List<SettingItem>>? onSaved;
  final dynamic currentKey;
  final bool scroll;

  SettingListWidget({
    Key? key,
    this.title,
    this.currentKey,
    this.settings = const <SettingItem>[],
    this.onItemTap,
    this.onItemChanged,
    this.onItemHover,
    this.onSaved,
    this.scroll = true,
  }) : super(key: key);

  @override
  _SettingListWidgetState createState() => _SettingListWidgetState();
}

class _SettingListWidgetState extends State<SettingListWidget> {
  Widget _builder(BuildContext context, BoxConstraints constraints) {
    var children = widget.settings.mapIndexed((i, e) => _buildSettingItem(null, e, context, i));
    Widget body = Column(
      mainAxisSize: MainAxisSize.min,
      children: ListTile.divideTiles(tiles: children, context: context).toList(),
    );
    if (widget.scroll) {
      body = SingleChildScrollView(child: body);
    }

    if (widget.title != null) {
      body = Scaffold(
        appBar: AppBar(
          title: Text(widget.title!),
        ),
        body: body,
      );
    }
    return body;
  }

  Widget _buildSettingItem(SettingItem? parentItem, SettingItem item, BuildContext context, int index) {
    if (FieldType.row_color == item.fieldType) {
      return Builder(
        builder: (context) {
          String title = '${item.title}';
          return Tooltip(
            message: title,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1)),
                padding: EdgeInsets.symmetric(horizontal: 2, vertical: 0),
                backgroundColor: item.value,
                minimumSize: Size(30, 24),
                maximumSize: Size(50, 24),
              ),
              onPressed: () => _showColorPicker(context, parentItem, item),
              child: Text(
                title.cut(5),
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: MONOSPACED_FONT,
                  fontWeight: FontWeight.w300,
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      );
    }

    Widget? title = item.title != null ? Text('${item.title}', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14)) : null;

    if (item.fieldType == FieldType.row) {
      List<Widget> children = item.children!.map((e) => _buildSettingItem(item, e, context, index)).toList();
      if (children.length >= 6) {
        children = [
          if (title != null) title,
          Expanded(
            child: Wrap(
              children: children,
              alignment: WrapAlignment.end,
            ),
          ),
        ];
      } else {
        children = title == null ? children : [title, Spacer(), ...children];
      }
      return ListTile(
        visualDensity: VisualDensity(horizontal: 0, vertical: -4),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: children,
        ),
      );
    }

    Widget? trailing;
    Widget? leading = item.prefix;
    var onTap = null;
    if (item.fieldType == FieldType.button) {
      trailing = item.suffix ?? item.valueBuilder?.call(item.value);
      onTap = () {
        Rect targetRect = Rect.zero;
        RenderObject? renderObject = context.findRenderObject();
        if (renderObject is RenderBox) {
          final position = renderObject.localToGlobal(Offset.zero);
          targetRect = Rect.fromLTWH(position.dx, position.dy, renderObject.size.width, renderObject.size.height);
        }
        widget.onItemTap?.call(item, targetRect);
      };
    } else if (item.fieldType == FieldType.hover) {
      trailing = item.suffix ?? item.valueBuilder?.call(item.value);
      onTap = () {};
    } else if (item.fieldType == FieldType.color) {
      onTap = () {};
      Color _borderColor = Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black26;
      trailing = Builder(
        builder: (context) {
          return MaterialButton(
            elevation: 0,
            minWidth: 30,
            hoverElevation: 0,
            padding: EdgeInsets.symmetric(horizontal: 0),
            color: item.value,
            shape: CircleBorder(side: BorderSide(width: 1.0, color: _borderColor)),
            onPressed: () => _showColorPicker(context, parentItem, item),
          );

//          return IconButton(
//            icon: Icon(Icons.lens, color: item.value, size: 32),
//            onPressed: () => _showColorPicker(context, item),
//          );
        },
      );
    } else if (item.fieldType == FieldType.number) {
      trailing = NumberFieldWidget(
        value: item.value ?? 0,
        min: item.min!,
        max: item.max!,
        step: item.step,
        enabled: item.enabled,
        onChanged: (value) {
          widget.onItemChanged?.call(parentItem, item..value = value);
        },
      );
      if (item.enabled != null) {
        trailing = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              splashRadius: 20,
              visualDensity: VisualDensity.compact,
              value: item.enabled,
              onChanged: (v) {
                item.enabled = v;
                widget.onItemChanged?.call(parentItem, item);
                setState(() {});
              },
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            trailing,
          ],
        );
      }
    } else if (item.value is bool) {
      onTap = () {
        setState(() {
          item.value = !item.value;
        });
        widget.onItemChanged?.call(parentItem, item);
      };
      trailing = SizedBox(
        height: 30,
        width: 48,
        child: Switch.adaptive(
          value: item.value,
          activeColor: Theme.of(context).colorScheme.primary,
//        activeTrackColor: Theme.of(context).colorScheme.primary.withAlpha(130),
          onChanged: (v) {
            setState(() {
              item.value = v;
            });
            widget.onItemChanged?.call(parentItem, item);
          },
        ),
      );
    } else if (item.fieldType == FieldType.check_group) {
      if (item.optionListType == OptionListType.row) {
        var child = ToggleButtonGroup(
          selectedColor: Theme.of(context).colorScheme.primary,
          fillColor: Theme.of(context).colorScheme.primary.withAlpha(50),
          highlightColor: Theme.of(context).colorScheme.primary.withAlpha(100),
          borderRadius: BorderRadius.circular(5),
          constraints: BoxConstraints.tightFor(height: 24),
          selectedIndex: item.options!.indexWhere((e) => item.value == e.value),
          children: item.options!
              .map((e) => Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: e.prefix != null ? e.prefix : Text('${e.title}'),
                  ))
              .toList(),
          onChange: (i) {
            item.value = item.options![i].value;
            widget.onItemChanged?.call(parentItem, item);
          },
        );
        return ListTile(
          visualDensity: VisualDensity(horizontal: 0, vertical: -4),
          leading: item.prefix,
          horizontalTitleGap: 2,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[if (title != null) title, if (title != null) Spacer(), child],
          ),
        );
      } else {
        var _children = item.options!.map((e) {
          return MouseRegion(
            onEnter: (e) {
              widget.onItemHover?.call(item, true, null);
            },
            child: ListTile(
              visualDensity: VisualDensity(horizontal: 0, vertical: -4),
              title: item.valueBuilder?.call(e.value) ?? Text(e.title),
              contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 0),
              leading: e.prefix,
              selected: e.value == item.value,
              trailing: e.value == item.value
                  ? IconButton(
                      icon: Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary, size: 18),
                      onPressed: null,
                    )
                  : null,
              onTap: () {
                item.value = e.value;
                setState(() {});
                widget.onItemChanged?.call(parentItem, item);
              },
            ),
          );
        });
        if (item.optionListType == OptionListType.expanded) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: ListTile.divideTiles(tiles: _children, context: context).toList(),
          );
        } else {
          return ExpansionTile(
            title: Text(item.title!),
            children: ListTile.divideTiles(tiles: _children, context: context).toList(),
          );
        }
      }
    } else if (item.fieldType == FieldType.input) {
      title = InputItemWidget(
        settingItem: item,
        onChanged: (item) {
          widget.onItemChanged?.call(parentItem, item);
        },
      );
    }
    Widget menu = ListTile(
//      dense: true,
      leading: leading,
      visualDensity: VisualDensity(horizontal: 0, vertical: VisualDensity.minimumDensity),
      horizontalTitleGap: 2,
      title: title,
      onTap: onTap,
      trailing: trailing,
      selected: widget.currentKey != null && item.key == widget.currentKey,
    );
    if (widget.onItemHover != null) {
      // menu = Builder(builder: (context) {
      menu = MouseRegion(
        child: menu,
        onEnter: (d) {
          Rect targetRect = Rect.zero;
          RenderObject? renderObject = context.findRenderObject();
          if (renderObject is RenderBox) {
            final position = renderObject.localToGlobal(Offset(0, index * 30.0));
            targetRect = Rect.fromLTWH(position.dx, position.dy, renderObject.size.width, position.dy + 30);
          }
          widget.onItemHover?.call(item, true, targetRect);
        },
        onExit: (d) {
          widget.onItemHover?.call(item, false, null);
        },
        onHover: (d) {},
      );
      // });
    }
    return menu;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: _builder);
  }

  void _showColorPicker(BuildContext context, SettingItem? parentItem, SettingItem item) {
    double width = isMobile(context) ? 200 : 300;

    var colorPicker = FixedColorPicker(
      showLabel: true,
      pickerAreaHeightPercent: .618,
      pickerColor: item.value,
      onColorChanged: (color) {
        item.value = color;
        setState(() {});
        widget.onItemChanged?.call(parentItem, item);
      },
    );

    showAttachedWidget(
      targetContext: context,
      preferDirection: PreferDirection.bottomLeft,
      backgroundColor: Colors.transparent,
      attachedBuilder: (cancel) {
        return Material(
          elevation: 8,
          shape: modelShape(),
          color: Theme.of(context).dialogBackgroundColor,
          child: Container(constraints: BoxConstraints.tightFor(width: width), child: colorPicker),
        );
      },
    );
  }
}

class InputItemWidget extends StatefulWidget {
  final SettingItem settingItem;

  final ValueChanged<SettingItem>? onChanged;

  const InputItemWidget({Key? key, required this.settingItem, this.onChanged}) : super(key: key);

  @override
  _InputItemState createState() => _InputItemState();
}

class _InputItemState extends State<InputItemWidget> {
  TextEditingController? _controller;
  bool _edited = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.settingItem.value}');
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SettingItem item = widget.settingItem;

    return TextField(
      autofocus: false,
      controller: _controller,
      onChanged: (value) {
        setState(() {
          _edited = true;
        });
      },
      decoration: InputDecoration(
        prefix: Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Text('${item.title}:', style: Theme.of(context).textTheme.bodySmall),
        ),
        suffixIcon: _edited && _controller!.text.length > 0
            ? IconButton(
                icon: Icon(Icons.check_circle),
                onPressed: () {
                  //String _value = _controller.text;
                  widget.onChanged?.call(item..value = _controller!.text);
                },
              )
            : null,
        prefixStyle: TextStyle(color: Colors.black87),
      ),
    );
  }
}
