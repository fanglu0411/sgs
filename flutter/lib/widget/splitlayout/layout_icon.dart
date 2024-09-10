import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/splitlayout/side_tab_item.dart';

///
///
///
///
class LayoutIcon extends StatefulWidget {
  final PanelPosition position;
  final Size size;
  final Color? color;

  const LayoutIcon({
    Key? key,
    required this.position,
    this.color,
    this.size = const Size(18, 14),
  }) : super(key: key);

  @override
  State<LayoutIcon> createState() => _LayoutIconState();
}

class _LayoutIconState extends State<LayoutIcon> {
  @override
  Widget build(BuildContext context) {
    Color color = widget.color ?? Theme.of(context).iconTheme.color!;
    return Container(
      child: CustomPaint(
        size: widget.size,
        painter: LayoutIconPainter(widget.position, color),
      ),
    );
  }
}

class LayoutIconPainter extends CustomPainter {
  late PanelPosition position;
  late Color color;

  LayoutIconPainter(this.position, this.color) {
    _paint = Paint()
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..color = color;
  }

  late Paint _paint;

  @override
  void paint(Canvas canvas, Size size) {
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);

    canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(2)), _paint..style = PaintingStyle.stroke);

    double sideWidth = position == PanelPosition.left || position == PanelPosition.right ? size.width * .35 : size.width * .35;
    double bottomHeight = position == PanelPosition.bottom ? size.width * .45 : size.width * .35;

    // Rect _topRect = Rect.fromLTWH(0, 0, size.width, sideWidth);
    Rect _leftRect = Rect.fromLTWH(0, 0, sideWidth, size.height);
    Rect _rightRect = Rect.fromLTWH(size.width - sideWidth, 0, sideWidth, size.height);
    Rect _bottomRect = Rect.fromLTWH(0, size.height - bottomHeight, size.width, bottomHeight);

    // _drawSide(canvas, _topRect, EdgeLayoutPosition.top);
    // _drawSide(canvas, _leftRect, EdgeLayoutPosition.left);
    // _drawSide(canvas, _rightRect, EdgeLayoutPosition.right);
    // _drawSide(canvas, _bottomRect, EdgeLayoutPosition.bottom);

    switch (position) {
      case PanelPosition.left:
        _drawSide(canvas, _leftRect, PanelPosition.left);
        _drawSide(canvas, _bottomRect, PanelPosition.bottom);
        break;
      case PanelPosition.top:
        break;
      case PanelPosition.center:
        break;
      case PanelPosition.right:
        _drawSide(canvas, _rightRect, PanelPosition.right);
        _drawSide(canvas, _bottomRect, PanelPosition.bottom);
        break;
      case PanelPosition.bottom:
        _drawSide(canvas, _bottomRect, PanelPosition.bottom);
        break;
    }
  }

  void _drawSide(Canvas canvas, Rect rect, PanelPosition position) {
    _paint..style = this.position == position ? PaintingStyle.fill : PaintingStyle.stroke;
    canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(2)), _paint);
  }

  @override
  bool shouldRepaint(covariant LayoutIconPainter oldDelegate) {
    return oldDelegate.position != position;
  }
}
