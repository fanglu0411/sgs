import 'package:flutter/material.dart';
import 'dart:math' show pi;


class GridSplitter extends StatelessWidget {
  const GridSplitter({required this.isHorizontal});

  static const double iconSize = 18.0;
  static const double splitterWidth = 4.0;

  final bool isHorizontal;

  @override
  Widget build(BuildContext context) {
    bool _dark = Theme.of(context).brightness == Brightness.dark;
    Color _color = _dark ? Theme.of(context).colorScheme.outline.withOpacity(.1) : Colors.grey[300]!;
    return Container(
      decoration: BoxDecoration(
        color: _color,
      ),
      constraints: isHorizontal ? BoxConstraints.expand(width: splitterWidth) : BoxConstraints.expand(height: splitterWidth),
      child: OverflowBox(
        minWidth: 22,
        minHeight: 22,
        maxWidth: 24,
        maxHeight: 24,
        child: Transform.rotate(
          angle: isHorizontal ? degToRad(90.0) : degToRad(0.0),
          child: Icon(
            Icons.drag_handle,
            size: 20,
            color: _dark ? Colors.white54 : Colors.grey[500],
          ),
        ),
      ),
    );
  }
}

double degToRad(num deg) => deg * (pi / 180.0);
