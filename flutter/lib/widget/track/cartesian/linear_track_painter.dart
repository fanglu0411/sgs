import 'package:d4_scale/d4_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/track/base/abstract_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/cartesian_data.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/cartesian_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/linear_style_config.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/monotone.dart';
import 'package:flutter_smart_genome/widget/track/cartesian/simple_cartesian_data.dart';

class LinearTrackPainter extends CartesianTrackPainter<SimpleCartesianData, LinearStyleConfig> {
  LinearTrackPainter({
    required super.trackData, // may be data in a range
    required super.styleConfig,
    required super.scale, // the scale by the hole chromosome
    required super.visibleRange,
    super.orientation,
    super.selectedItem,
    super.valueScaleType,
    super.cursor,
    super.customMaxValue,
    super.onItemTap,
    super.height,
    this.isArea = false,
    this.smooth = true,
  }) : super() {
    //
    trackPaint!
      ..color = styleConfig.color
      ..style = isArea ? PaintingStyle.fill : PaintingStyle.stroke;
  }

  bool isArea;
  bool smooth;

  @override
  void initWithSize(Size size) {
    super.initWithSize(size);
  }

  @override
  void onPaint(Canvas canvas, Size size, Rect painterRect) {
    super.onPaint(canvas, size, painterRect);
  }

  @override
  drawHorizontalTrack(Canvas canvas, Rect trackRect, Size size) {
    canvas.drawLine(
      Offset(trackRect.left, trackRect.bottom),
      Offset(trackRect.right, trackRect.bottom),
      trackPaint!..strokeWidth = .8,
    );
    LinearStyleConfig _styleConfig = styleConfig;
    Path path = Path();
    if (isArea) {
      path.moveTo(trackData[0].renderShape!.rect.bottomCenter.dx, trackData[0].renderShape!.rect.bottomCenter.dy);
    }
    List<Offset> points = trackData.map((e) => e.renderShape!.rect.topCenter).toList();

    if (smooth) {
      if (!isArea) path.moveTo(points.first.dx, points.first.dy);
      path = MonotoneX.addCurve(path, points);
    } else {
      path.addPolygon(points, false);
    }

    trackPaint!
      ..color = _styleConfig.color
      ..strokeWidth = _styleConfig.borderWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, trackPaint!);

    if (isArea) {
      path.lineTo(trackData.dataSource!.last.renderShape!.rect.bottomCenter.dx, trackData.dataSource!.last.renderShape!.rect.bottomCenter.dy);
      path.close();

      trackPaint!
        ..color = _styleConfig.color.withOpacity(.2)
        ..style = PaintingStyle.fill
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(path, trackPaint!);
    }
  }

  @override
  drawSelectedItem(Canvas canvas, CartesianDataItem? _selectedItem, Scale<num, num> valueScale) {
    super.drawSelectedItem(canvas, _selectedItem, valueScale);
    // if (_selectedItem == null) return;
    // Rect _rect = rectMap[_selectedItem.index];
    // if (_rect == null) return;
    // canvas.drawCircle(_rect.topCenter, 2, selectedPaint);
    // drawText(
    //   canvas,
    //   text: ' ${_selectedItem.value} ',
    //   style: TextStyle(
    //     color: Colors.white,
    //     fontSize: 14,
    //     backgroundColor: Colors.black87,
    //   ),
    //   offset: Offset(_rect.topCenter.dx - 25, _rect.top - 24),
    //   textAlign: TextAlign.center,
    //   width: 50,
    // );
  }

  @override
  drawVerticalTrack(Canvas canvas, Rect trackRect, Size size) {}

  @override
  bool painterChanged(AbstractTrackPainter painter) {
    return super.painterChanged(painter);
  }

  @override
  bool hitTest(Offset position) {
    int index = findHitItem(position);
//    print('bar painter hit test $position , index $index');
    if (index >= 0) return true;
//    return false; //不能return false， 否则事件没法传递
    return super.hitTest(position);
  }
}
