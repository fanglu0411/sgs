import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:graphic/graphic.dart';

class AnnotationBuilder {
  List types;
  List<Color> colors;
  Alignment align;
  TextStyle textStyle;
  Axis direction;
  double width;
  EdgeInsets padding;
  late double _itemWidth;

  int columnCount = 1;
  int rows = 1;
  double rowHeight = 16;

  AnnotationBuilder({
    required this.colors,
    required this.types,
    required this.textStyle,
    required this.width,
    this.padding = EdgeInsets.zero,
    this.direction = Axis.horizontal,
    this.align = Alignment.topCenter,
  }) {
    _itemWidth = types.maxBy((e) => e.length)!.length * textStyle.fontSize! * .55 + 20;
  }

  (double height, List<Annotation>? annotations) build() {
    if (direction == Axis.horizontal) {
      columnCount = (width / _itemWidth).floor();
      rows = (types.length / columnCount).ceil();
    } else {
      columnCount = 1;
      rows = types.length;
    }
    int i = 0;
    List<Annotation> as = [];
    for (String type in types) {
      as.addAll(_buildItem(i++, type));
    }
    return (rows * rowHeight, as);
  }

  List<Annotation> _buildItem(int index, group) {
    return [
      CustomAnnotation(
        renderer: (_, size) => [
          CircleElement(
            center: _itemPosition(size, index),
            radius: 5,
            style: PaintStyle(fillColor: (colors)[index]),
          ),
        ],
        anchor: (p0) => Offset(0, 0),
      ),
      TagAnnotation(
        label: Label(
          '$group',
          LabelStyle(textStyle: Defaults.textStyle, align: Alignment.centerRight),
        ),
        anchor: (size) => _itemPosition(size, index) + Offset(10, 0),
      )
    ];
  }

  Offset _itemPosition(Size size, int index) {
    int row = direction == Axis.horizontal ? index ~/ columnCount : index;
    int col = direction == Axis.horizontal ? index % columnCount : 0;

    double totalHeight = rows * rowHeight;
    double top = align.y == 0 ? (size.height - totalHeight) / 2 : size.height / 2 + align.y * (size.height / 2);

    var offset = Offset(size.width / 2 + size.width / 2 * align.x + _itemWidth * col, top + rowHeight * row).translate(padding.left, padding.top);
    // print('offset: ${offset}, row: ${row}, col: ${col}, index: $index');
    return offset;
  }
}
