import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/cell/data_category.dart';
import 'package:flutter_smart_genome/page/cell/cell_scatter_chart/scatter_label_position.dart';

class CellPlotChartLabelWidget extends StatefulWidget {
  final TransformationController transformationController;
  final Map<String, ScatterLabel> labelMap;
  final Map<String, DataCategory> legendMap;
  final Size size;
  final double labelSize;

  const CellPlotChartLabelWidget({
    Key? key,
    this.labelMap = const {},
    required this.size,
    required this.transformationController,
    required this.legendMap,
    this.labelSize = 14,
  }) : super(key: key);

  @override
  _CellPlotChartLabelWidgetState createState() => _CellPlotChartLabelWidgetState();
}

class _CellPlotChartLabelWidgetState extends State<CellPlotChartLabelWidget> {
  Map<String, Offset> labelCustomOffset = {};

  GlobalKey _stackKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size.width,
      height: widget.size.height,
      child: Transform(
        transform: widget.transformationController.value,
        child: Stack(
          key: _stackKey,
          children: _buildLabels(),
        ),
      ),
    );
  }

  List<Widget> _buildLabels() {
    double _scale = widget.transformationController.value.getMaxScaleOnAxis();
    var dark = Theme.of(context).brightness == Brightness.dark;
    var labelColor = dark ? Colors.white70 : Colors.black87;
    var labelBgColor = dark ? Colors.black87.withOpacity(.75) : Colors.white.withOpacity(.85);
    var shadowColor = dark ? Colors.black : Colors.grey.withAlpha(200);

    Offset offset;
    Color _catColor;
    Color _labelColor;
    Color _borderColor;
    Color _bgColor;

    return widget.labelMap.keys.map((e) {
      var label = widget.labelMap[e]!;
      offset = Offset(label.position.x, label.position.y) + Offset(-'${e}'.length * widget.labelSize * .65, 0);

      _catColor = widget.legendMap[e]?.drawColor ?? labelColor;
      _labelColor = dark ? Colors.white : _catColor;
      _borderColor = dark ? Colors.white70 : _catColor;
      _bgColor = dark ? _catColor.withOpacity(.65) : Colors.white.withOpacity(.85);

      Widget _child = Text('${e}',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: widget.labelSize,
            color: _labelColor,
            fontWeight: FontWeight.w800,
          ));

      _child = Transform.scale(
        scale: 1 / _scale,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: _borderColor, width: 1),
            borderRadius: BorderRadius.circular(4),
            color: _bgColor,
          ),
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: _child,
        ),
      );

      return Positioned(
        child: LongPressDraggable(
          delay: Duration(milliseconds: 300),
          data: e,
          onDragUpdate: (details) {
            var offset = details.delta / _scale;
            label.position += Point(offset.dx, offset.dy);
          },
          onDragEnd: (details) {
            setState(() {});
          },
          onDraggableCanceled: (c, o) {
            // RenderBox? getBox = _stackKey.currentContext!.findRenderObject() as RenderBox?;
            // var position = getBox!.globalToLocal(o);
            // labelCustomOffset[e] = position;
            // setState(() {});
          },
          feedback: Material(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
              side: BorderSide(color: _borderColor),
            ),
            color: _bgColor,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Text(
                '${e}',
                style: TextStyle(color: _labelColor, fontSize: widget.labelSize),
              ),
            ),
          ),
          child: _child,
        ),
        left: offset.dx,
        top: offset.dy,
      );
    }).toList();
  }
}
