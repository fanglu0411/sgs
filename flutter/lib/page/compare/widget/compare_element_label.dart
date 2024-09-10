import 'package:bot_toast/bot_toast.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/extensions/widget_extensions.dart';
import 'package:flutter_smart_genome/page/cell/cell_base.dart';
import 'package:flutter_smart_genome/page/cell/cell_page/cell_page_logic.dart';
import 'package:flutter_smart_genome/page/cell/cell_scatter_chart/legend_colors.dart';
import 'package:flutter_smart_genome/page/cell/cell_tool_bar/slider_widget.dart';
import 'package:flutter_smart_genome/page/cell/cell_utils.dart';
import 'package:flutter_smart_genome/page/compare/compare_logic.dart';
import 'package:flutter_smart_genome/util/debouncer.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:flutter_smart_genome/widget/basic/fixed_color_picker.dart';

class CompareElementLabel extends StatefulWidget {
  final CompareElement compareElement;
  final Function? onChange;
  final Function1<String, void>? onConfigChange;
  final bool showMenu;

  final ValueChanged<CompareElement>? onRemove;

  const CompareElementLabel({
    Key? key,
    required this.compareElement,
    this.onChange,
    this.showMenu = false,
    this.onRemove,
    this.onConfigChange,
  }) : super(key: key);

  @override
  _CompareElementLabelState createState() => _CompareElementLabelState();
}

class _CompareElementLabelState extends State<CompareElementLabel> {
  bool _hovered = false;

  late Debounce _debounce;

  CancelFunc? _menuFunc;
  CancelFunc? _subMenuFunc;

  late List<Map> _menus;

  @override
  void initState() {
    super.initState();
    _debounce = Debounce(milliseconds: 2500);
    _initMenu();
  }

  _initMenu() {
    var groups = CellPageLogic.safe()!.groupMap.keys.map((value) {
      return {
        'value': value,
        'label': value,
      };
    }).toList();
    var currGroup = CellPageLogic.safe()!.currentChartLogic.currentGroup;

    var matrixList = CellPageLogic.safe()!.matrixList;
    var curMatrix = CellPageLogic.safe()!.currentChartLogic.state.mod;

    _menus = [
      {
        'key': 'matrix',
        'label': 'Matrix',
        'value': curMatrix!.name,
        'children': matrixList.map((e) => {'label': e.name, 'value': e.id}).toList(),
      },
      {
        'key': 'group',
        'label': 'Group',
        'value': currGroup,
        'children': groups,
      },
    ];
  }

  void _autoDismissMenu() {
    _debounce.dispose();
    _debounce.run(() {
      _menuFunc?.call();
      _subMenuFunc?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MouseRegion(
          onEnter: (e) {
            _hovered = true;
            // setState(() {});
            if (widget.showMenu) {
              _showContextMenu(context);
              _autoDismissMenu();
            }
          },
          onExit: (e) {
            _hovered = false;
            // setState(() {});
          },
          onHover: (e) {},
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(_hovered ? .25 : .05),
              borderRadius: BorderRadius.only(bottomRight: Radius.elliptical(24, 24)),
              // border: Border.all(color: Theme.of(context).dividerColor),
            ),
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon(Icons.settings, size: 16, color: Colors.white),
                Tooltip(
                  message: 'Plot:${widget.compareElement.plotType}, Group: ${widget.compareElement.category}',
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                    child: Text(
                      '${widget.compareElement.type.name}',
                      style: TextStyle(
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        // color: Colors.white,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  constraints: BoxConstraints.tightFor(width: 32, height: 32),
                  padding: EdgeInsets.zero,
                  splashRadius: 16,
                  iconSize: 18,
                  // color: Colors.white,
                  onPressed: () {
                    widget.onRemove?.call(widget.compareElement);
                  },
                  icon: Icon(Icons.close),
                  tooltip: 'Remove',
                ),
                // Icon(Icons.arrow_drop_down_outlined, color: Colors.white),
              ],
            ),
          ),
        ),
        if (widget.compareElement.type == SCViewType.heatmap || widget.compareElement.type == SCViewType.dotplot) ...[
          IconButton(
            onPressed: () {
              widget.compareElement.transposed = !widget.compareElement.transposed;
              setState(() {});
              widget.onConfigChange?.call('transposed');
            },
            tooltip: 'Transpose Cord',
            iconSize: 18,
            isSelected: widget.compareElement.transposed,
            icon: Icon(CupertinoIcons.rotate_right_fill),
            selectedIcon: Icon(CupertinoIcons.rotate_left_fill),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints.tightFor(width: 36, height: 36),
          ),
        ],
        if (widget.compareElement.type == SCViewType.scatter || widget.compareElement.type == SCViewType.heatmap || widget.compareElement.type == SCViewType.dotplot) ...[
          SizedBox(width: 10),
          Builder(builder: (context) {
            return IconButton(
              padding: EdgeInsets.zero,
              onPressed: () => showColorSchemaDialog(context, legendColors: expressionLegendColors, onColorSchemaChange: (l) {
                widget.compareElement.legendColor = l;
                widget.onConfigChange?.call('color');
              }),
              iconSize: 18,
              constraints: BoxConstraints.tightFor(width: 36, height: 32),
              icon: Icon(Icons.color_lens, size: 16),
              tooltip: 'color',
            );
          }),
        ],
        if (widget.compareElement.type == SCViewType.scatter) ...[
          SizedBox(width: 6),
          Builder(builder: (context) {
            return IconButton(
              padding: EdgeInsets.zero,
              constraints: BoxConstraints.tightFor(width: 36, height: 32),
              onPressed: () => _showPointSizeSlider(context),
              iconSize: 18,
              icon: Icon(Icons.scatter_plot),
              tooltip: 'point size',
            );
          }),
          SizedBox(width: 6),
          Builder(builder: (context) {
            return IconButton(
              padding: EdgeInsets.zero,
              constraints: BoxConstraints.tightFor(width: 36, height: 32),
              onPressed: () => _showPointOpacitySlider(context),
              iconSize: 18,
              icon: Icon(Icons.opacity),
              tooltip: 'point opacity',
            );
          }),
        ],
      ],
    );
  }

  void _showContextMenu(BuildContext context) {
    _debounce.dispose();
    if (_menuFunc != null) return;

    RenderBox render = context.findRenderObject() as RenderBox;
    Offset offset = render.localToGlobal(Offset.zero);

    _menuFunc = showAttachedWidget(
      // targetContext: context,
      target: offset,
      preferDirection: PreferDirection.rightTop,
      backgroundColor: Colors.transparent,
      onClose: () {
        _menuFunc = null;
      },
      attachedBuilder: (c) {
        return Material(
          borderRadius: BorderRadius.circular(2),
          // color: Theme.of(context).colorScheme.primary.withOpacity(.85),
          child: Container(
            padding: EdgeInsets.only(left: 8, bottom: 8),
            constraints: BoxConstraints(minWidth: 100),
            color: Theme.of(context).colorScheme.primary.withOpacity(.45),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.settings, color: Colors.white70, size: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      child: Text(
                        '${widget.compareElement.type}'.split('.').last,
                        style: TextStyle(
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
                ..._buildOptions(),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSubContextMenu(BuildContext context, Map menu) {
    _subMenuFunc?.call();
    _subMenuFunc = showAttachedWidget(
      targetContext: context,
      preferDirection: PreferDirection.rightTop,
      onClose: () {},
      backgroundColor: Colors.transparent,
      attachedBuilder: (c) {
        return Material(
          borderRadius: BorderRadius.circular(2),
          child: Container(
            constraints: BoxConstraints(minWidth: 120),
            child: _buildSecondaryOption(menu),
          ),
        );
      },
    );
  }

  Widget _buildSecondaryOption(Map menu) {
    var style = TextButton.styleFrom(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      minimumSize: Size(160, 24),
      alignment: Alignment.centerLeft,
    );
    List _children = menu['children'];
    var _checkedValue = menu['value'];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _children.map((e) {
        return MouseRegion(
          onEnter: (e) {
            _autoDismissMenu();
          },
          child: TextButton(
            onPressed: () {
              _subMenuFunc?.call();
              _menuFunc?.call();
              menu['value'] = e['label'];
              widget.onChange?.call(menu, e);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_checkedValue == e['value']) Icon(Icons.check, size: 18),
                if (_checkedValue != e['value']) SizedBox(width: 18, height: 20),
                SizedBox(width: 4),
                Text('${e['label']}'),
              ],
            ),
            style: style,
          ),
        );
      }).toList(),
    );
  }

  List<Widget> _buildOptions() {
    var style = TextButton.styleFrom(
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      minimumSize: Size(120, 24),
      alignment: Alignment.centerLeft,
    );

    return _menus.map<Widget>((menu) {
      return Builder(builder: (context) {
        return MouseRegion(
          onEnter: (e) {
            _showSubContextMenu(context, menu);
            _autoDismissMenu();
          },
          child: TextButton(
            onPressed: () {},
            child: Text('${menu['label']}: ${menu['value']}'),
            style: style,
          ),
        );
      });
    }).toList();
  }

  void _showPointSizeSlider(BuildContext context) {
    showAttachedWidget(
      targetContext: context,
      preferDirection: PreferDirection.bottomLeft,
      attachedBuilder: (c) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 360, maxHeight: 60),
          child: Material(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SliderWidget(
                value: widget.compareElement.pointSize,
                label: 'Point Size',
                divisions: 9,
                onChanged: (v) {
                  widget.compareElement.pointSize = v;
                  widget.onConfigChange?.call('pointSize');
                },
                min: 1.0,
                max: 10.0,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showPointOpacitySlider(BuildContext context) {
    showAttachedWidget(
      targetContext: context,
      preferDirection: PreferDirection.bottomLeft,
      attachedBuilder: (c) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 360, maxHeight: 60),
          child: Material(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SliderWidget(
                value: widget.compareElement.opacity,
                label: 'Point Opacity',
                divisions: 9,
                onChanged: (v) {
                  widget.compareElement.opacity = v;
                  widget.onConfigChange?.call('opacity');
                },
                min: 0.1,
                max: 1.0,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showColorPicker(BuildContext context) {
    showAttachedWidget(
      targetContext: context,
      preferDirection: PreferDirection.rightTop,
      attachedBuilder: (c) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 300),
          child: Material(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8))),
            child: FixedColorPicker(
              pickerColor: widget.compareElement.color,
              displayThumbColor: true,
              pickerAreaHeightPercent: .618,
              // pickerAreaBorderRadius: BorderRadius.circular(8),
              onColorChanged: (c) {
                widget.compareElement.color = c;
                widget.onConfigChange?.call('color');
              },
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _debounce.dispose();
  }
}
