import 'package:bot_toast/bot_toast.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/cell/data_category.dart';
import 'package:flutter_smart_genome/page/cell/cell_scatter_chart/legend_colors.dart';
import 'package:flutter_smart_genome/page/cell/cell_utils.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:flutter_smart_genome/widget/basic/fast_rich_text.dart';
import 'package:flutter_smart_genome/widget/basic/fixed_color_picker.dart';
import 'package:flutter_smart_genome/widget/track/base/base_painter.dart';
import 'package:get/get.dart';
import 'cell_plot_legend_logic.dart';

class CategoryLegendView extends StatefulWidget {
  final List<DataCategory> legends;
  final ValueChanged<DataCategory?>? onCheckedChange;
  final ValueChanged<DataCategory?>? onSelectionChange;
  final ValueChanged<LegendColor>? onColorSchemaChange;
  final ValueChanged<List<DataCategory>>? onColorChange;
  final bool showColorSchema;
  final List<LegendColor>? legendColors;
  final bool editable;

  CategoryLegendView({
    Key? key,
    required this.legends,
    this.onCheckedChange,
    this.onSelectionChange,
    this.onColorChange,
    this.onColorSchemaChange,
    this.showColorSchema = true,
    this.editable = true,
    this.legendColors,
  }) : super(key: key) {}

  @override
  _CellPlotLegendViewState createState() => _CellPlotLegendViewState();
}

class _CellPlotLegendViewState extends State<CategoryLegendView> {
  final CellPlotLegendLogic logic = Get.put(CellPlotLegendLogic());

  bool _checkAll = true;

  late int _maxCount;
  double minWidth = 120;

  TextStyle get _labelStyle => Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 14, fontFamily: MONOSPACED_FONT, fontFamilyFallback: MONOSPACED_FONT_BACK);

  @override
  void initState() {
    super.initState();
    _checkAll = widget.legends.every((e) => e.checked);
    _maxCount = widget.legends.maxBy((e) => e.count!)?.count ?? 1;
  }

  @override
  void didUpdateWidget(covariant CategoryLegendView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checkAll = widget.legends.every((e) => e.checked);
  }

  void _toggleSelectionAll() {
    _checkAll = !_checkAll;
    widget.legends.forEach((e) => e.checked = _checkAll);
    setState(() {});
    widget.onCheckedChange?.call(null);
  }

  void _reset() {
    widget.legends.forEach((e) {
      // e.checked = true;
      e.focused = false;
    });
    // _checkAll = true;
    setState(() {});
    widget.onSelectionChange?.call(null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.editable)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton.icon(
                onPressed: _toggleSelectionAll,
                icon: Icon(_checkAll ? Fontisto.checkbox_active : Fontisto.checkbox_passive, size: 14),
                label: Text('All'),
                style: TextButton.styleFrom(
                  minimumSize: Size(50, 30),
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                ),
              ),
              SizedBox(width: 10),
              IconButton(
                onPressed: _reset,
                icon: Icon(Icons.clear_all),
                style: TextButton.styleFrom(),
                constraints: BoxConstraints.tightFor(width: 32, height: 32),
                iconSize: 18,
                color: Theme.of(context).colorScheme.primary,
                padding: EdgeInsets.zero,
                tooltip: 'clear selections',
              ),
              SizedBox(width: 10),
              if (widget.showColorSchema)
                Builder(
                  builder: (c) => IconButton(
                    icon: Icon(Icons.format_color_fill),
                    padding: EdgeInsets.zero,
                    iconSize: 16,
                    color: Theme.of(context).colorScheme.primary,
                    constraints: BoxConstraints.tightFor(width: 32, height: 32),
                    splashRadius: 20,
                    // style: TextButton.styleFrom(
                    //   padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    //   minimumSize: Size(50, 30),
                    // ),
                    onPressed: () => showColorSchemaDialog(c, legendColors: widget.legendColors ?? legendColors, onColorSchemaChange: widget.onColorSchemaChange),
                    tooltip: 'Color schema',
                    // child: Text('Colors'),
                  ),
                ),
            ],
          ),
        ...(widget.legends).map(_legendItem),
      ],
    );
  }

  Widget _legendItem(DataCategory item) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 4),
        Checkbox(
          value: item.checked,
          splashRadius: 10,
          visualDensity: VisualDensity(vertical: -4, horizontal: -4),
          // shape: RoundedRectangleBorder(),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onChanged: (v) {
            item.checked = v!;
            _checkAll = widget.legends.every((e) => e.checked);
            setState(() {});
            widget.onCheckedChange?.call(item);
          },
        ),
        Builder(
          builder: (context) => InkWell(
            onTap: (widget.editable && item.checked) ? () => _showColorPicker(context, item) : null,
            child: Icon(Icons.square_rounded, size: 20, color: item.color),
          ),
        ),
        InkWell(
          radius: 5,
          borderRadius: BorderRadius.circular(5),
          // hoverColor: Theme.of(context).colorScheme.primary.withOpacity(.5),
          splashColor: Theme.of(context).colorScheme.primary,
          // onTap: widget.editable
          //     ? () {
          //         item.checked = !item.checked;
          //         _checkAll = widget.legends.every((e) => e.checked);
          //         setState(() {});
          //         widget.onCheckedChange?.call(item);
          //       }
          //     : null,
          onDoubleTap: widget.editable
              ? () {
                  item.focused = !item.focused;
                  // _checkAll = widget.legends.every((e) => e.focused);
                  setState(() {});
                  widget.onSelectionChange?.call(item);
                }
              : null,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: item.focused ? Theme.of(context).focusColor : null,
            ),
            child: _buildLabel(item),
          ),
          // CustomPaint(
          //   // child: Text(' ${item.name} (${item.count}) ', style: TextStyle(fontSize: 12, color: Colors.white)),
          //   painter: SimpleBarPainter(
          //     barWidth: 100 * item.count / _maxCount,
          //     barColor: item.color,
          //     // label: '${item.name}',
          //     count: item.count,
          //     backgroundColor: Colors.grey[300],
          //   ),
          //   size: Size(_labelWidth, 16),
          // ),
        ),
      ],
    );
  }

  Widget _buildLabel(DataCategory item) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FastRichText(
          children: [
            TextSpan(text: ' ${item.name}', style: _labelStyle),
            TextSpan(text: ' (${item.count ?? '-'})', style: _labelStyle),
          ],
        ),
        // CustomPaint(
        //   painter: SimpleBarPainter(
        //     // count: item.count,
        //     barWidth: 100 * (item.count ?? 0) / _maxCount,
        //     barColor: item.color,
        //     // label: '${item.count}',
        //     backgroundColor: Colors.grey[200],
        //   ),
        //   size: Size(50, 2),
        // ),
        // Container(
        //   color: item.color,
        //   width: 100 * item.count / _maxCount,
        //   height: 16,
        //   child: Text('${item.count}', style: TextStyle(color: Colors.white70)),
        // ),
      ],
    );
  }

  void _showColorPicker(BuildContext context, DataCategory item) {
    var width = 240.0;
    var colorPicker = FixedColorPicker(
      colorPickerWidth: width,
      showLabel: true,
      pickerColor: item.color,
      pickerAreaHeightPercent: .618,
      onColorChanged: (color) {
        item.color = color;
        setState(() {});
        widget.onColorChange?.call(widget.legends);
      },
    );

    showAttachedWidget(
      targetContext: context,
      preferDirection: PreferDirection.bottomRight,
      attachedBuilder: (cancel) {
        return Container(
          constraints: BoxConstraints.tightFor(width: width),
          //decoration: defaultContainerDecoration(context),
          child: Material(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8))),
            child: colorPicker,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    Get.delete<CellPlotLegendLogic>();
    super.dispose();
  }
}

class SimpleBarPainter extends BasePainter {
  double barWidth;
  Color? backgroundColor;
  Color barColor;
  String? label;
  int? count;
  late Paint _paint;

  SimpleBarPainter({
    required this.barWidth,
    this.label,
    required this.barColor,
    this.backgroundColor,
    this.count,
  }) {
    _paint = Paint()..style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (backgroundColor != null) {
      _paint..color = backgroundColor!;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), _paint);
    }

    _paint..color = barColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, barWidth, size.height), _paint);

    if (label != null) {
      drawText(
        canvas,
        text: label!,
        offset: Offset(4, (size.height - 14) / 2),
        style: TextStyle(color: Color.alphaBlend(Colors.white70, backgroundColor!), fontSize: 12),
        textAlign: TextAlign.start,
        width: size.width,
      );
    }
    if (count != null) {
      drawText(
        canvas,
        text: '$count',
        offset: Offset(-4, (size.height - 14) / 2),
        style: TextStyle(color: Color.alphaBlend(Colors.black54, backgroundColor!), fontSize: 12),
        textAlign: TextAlign.end,
        width: size.width,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SimpleBarPainter oldDelegate) {
    return barWidth != oldDelegate.barWidth || barColor != oldDelegate.barColor || backgroundColor != oldDelegate.backgroundColor;
  }
}
