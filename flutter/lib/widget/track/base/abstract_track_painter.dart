import 'dart:ui' as ui;
import 'package:d4_scale/d4_scale.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/page/track/track_ui_config_bean.dart';
import 'package:flutter_smart_genome/widget/track/base/base_painter.dart';
import 'package:flutter_smart_genome/widget/track/base/style_config.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';
import 'package:intl/intl.dart';

abstract class AbstractTrackPainter<T extends TrackData, C extends StyleConfig> extends BasePainter {
  T trackData;
  C styleConfig;

  Axis? orientation;
  ScaleLinear<num> scale;
  Range visibleRange;
  Offset? panOrigin;
  Offset translate = Offset.zero;
  late Size size;
  late Rect rect;
  late Rect painterRect;

//  String _viewType;
  int minSize = 12;
  Track? track;
  bool? showSubFeature;

  dynamic selectedItem;

  double? maxHeight;
  double? minHeight = 120;
  double? rowHeight;
  double? rowSpace;

  Offset? cursor;
  late Paint cursorPaint;

  ValueChanged<dynamic>? onItemTap;

  TrackCollapseMode collapseMode;
  bool scaling;

  NumberFormat numberFormatter = NumberFormat.decimalPattern();

  dynamic _rootItem;

  dynamic get rootItem => _rootItem;

  set rootItem(dynamic root) => _rootItem = root;

  dynamic _hitItem;

  dynamic get hitItem => _hitItem;

  set hitItem(dynamic item) {
    _hitItem = item;
  }

  Rect? hitRect;

  AbstractTrackPainter({
    required this.trackData,
    required this.styleConfig,
    this.panOrigin,
    required this.scale,
    required this.visibleRange,
    this.track,
    this.orientation = Axis.horizontal,
    this.selectedItem,
    this.showSubFeature = false,
    this.rowHeight = 10,
    this.rowSpace = 20,
    this.cursor,
    this.onItemTap,
    this.collapseMode = TrackCollapseMode.expand,
    this.maxHeight,
    this.scaling = false,
  }) {
    cursorPaint = Paint()
      ..strokeWidth = 1
      ..isAntiAlias = true
      ..color = Colors.red[800]!;
    maxHeight ??= track?.defaultTrackHeight ?? 60;
    size = Size.zero;
  }

  bool inVisibleRange(Feature feature) {
    if (orientation == Axis.horizontal) {
      return !(feature.range.end < visibleRange.start || feature.range.start > visibleRange.end);
    }
    return !(feature.range.end < visibleRange.start || feature.range.start > visibleRange.end);
  }

  void initWithSize(Size size) {
    rect = Rect.fromLTWH(0, 0, size.width, size.height);
//    if (styleConfig?.padding != null) rect = styleConfig.padding.deflateRect(rect);
    painterRect = styleConfig.padding != null ? styleConfig.padding!.deflateRect(rect) : rect;
//    if (this.trackData?.track?.trackViewTypeOfScale != null && this.trackData.track.trackViewTypeOfScale.length > 0) {
//      _viewType = findScaleViewType(size);
//    }
  }

  double get verFeatureWidth => styleConfig.featureWidth < 1 ? size.width * styleConfig.featureWidth : styleConfig.featureWidth;

  double get horFeatureWidth => styleConfig.featureWidth < 1 ? size.height * styleConfig.featureWidth : styleConfig.featureWidth;

  /// 二分法查找缩放值对应的索引值
  double findTargetScale(double scale, List<double> scales) {
    final int size = scales.length;
    int min = 0;
    int max = size - 1;
    int mid = (min + max) >> 1;
    while (!(scale >= scales[mid] && scale < scales[mid - 1])) {
      if (scale >= scales[mid - 1]) {
        // 因为值往小区，index往大取，所以不能为mid -1
        max = mid;
      } else {
        min = mid + 1;
      }
      mid = (min + max) >> 1;
      if (min >= max) {
        break;
      }
      if (mid == 0) {
        break;
      }
    }
    return scales[mid];
  }

  @override
  void paint(Canvas canvas, Size size) {
    initWithSize(size);
    this.size = size;

    if (trackData.isEmpty) {
      if (onEmptyPaint(canvas, size)) return;
    }

    onPaint(canvas, size, painterRect);
    if (null != cursor) drawCursor(canvas);

//    if (null != track) drawLabel(canvas, track.trackName);
  }

  void drawCursor(Canvas canvas) {
    canvas.drawLine(Offset(cursor!.dx, 0), Offset(cursor!.dx, size.height), cursorPaint);
  }

  bool onEmptyPaint(Canvas canvas, Size size) {
    if (trackData.message != null)
      drawText(
        canvas,
        text: trackData.message!,
        offset: Offset(0, 20),
        style: TextStyle(color: styleConfig.brightness == Brightness.dark ? Colors.white70 : Colors.black87),
        width: size.width,
        textAlign: TextAlign.center,
      );
    return true;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    if (oldDelegate is AbstractTrackPainter) {
      return painterChanged(oldDelegate);
    }
    return false;
  }

  void onPaint(Canvas canvas, Size size, Rect painterRect);

  void drawTextBackground(double) {}

  void drawLabel(Canvas canvas, String label) {
    drawText(
      canvas,
      text: label,
      style: TextStyle(fontSize: 12.0, color: Colors.brown, backgroundColor: Colors.grey),
      offset: Offset(0.0, 0.0),
      width: size.width,
      textAlign: TextAlign.left,
    );
  }

  double get viewSize => orientation == Axis.horizontal ? size.width : size.height;

  bool painterChanged(AbstractTrackPainter painter) {
    return size != painter.size ||
            translate != painter.translate ||
            scale != painter.scale ||
            trackData != painter.trackData ||
            styleConfig != painter.styleConfig || // fff
            selectedItem != painter.selectedItem //
        ;
  }

  void drawRect(Canvas canvas, Rect rect, Paint paint, [Radius? radius = null]) {
    if (rect.width < 1.5) {
      canvas.drawLine(rect.topCenter, rect.bottomCenter, paint..strokeWidth = 1.5);
      return;
    }
    Radius? _radius = radius;
    if (_radius != null) {
      canvas.drawRRect(RRect.fromRectAndRadius(rect, _radius), paint);
    } else {
      canvas.drawRect(rect, paint);
    }
  }

  dynamic findHitItem(Offset position) {}

  @override
  bool hitTest(Offset position) {
//    print('track painter hit $position');
    return super.hitTest(position) ?? false;
//    return false;
  }

  Future<Uint8List?> getPng() async {
    var recorder = new ui.PictureRecorder();
    var origin = new Offset(0.0, 0.0);
    var paintBounds = new Rect.fromPoints(size.topLeft(origin), size.bottomRight(origin));
    var canvas = new Canvas(recorder, paintBounds);
    var picture = recorder.endRecording();
    ui.Image image = await picture.toImage(size.width.round(), size.height.round());
    ByteData? byteData = null;
    if (kIsWeb) {
    } else {
      byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    }

    Uint8List? pngBytes = byteData?.buffer.asUint8List();
    // var bs64 = base64Encode(pngBytes);
    return pngBytes;
  }

  void drawTooltip(Canvas canvas, String _text, Offset offset, Paint painter) {
    double width = 220;
    double _height = 30;
    TextStyle _style = TextStyle(
      fontSize: 13,
      color: styleConfig.isDark ? Colors.white70 : Colors.black87,
      fontFamily: MONOSPACED_FONT,
      fontFamilyFallback: MONOSPACED_FONT_BACK,
    );
    TextPainter textPainter = TextPainter(
      text: TextSpan(text: _text, style: _style),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    width = textPainter.width;
    _height = textPainter.height;

    var _tooltipRect = Rect.fromLTWH(offset.dx, offset.dy, width + 4, _height + 4);
    if (_tooltipRect.right > rect.right) {
      _tooltipRect = _tooltipRect.translate(rect.right - _tooltipRect.right, 0);
    }
    if (_tooltipRect.left < rect.left) {
      _tooltipRect = _tooltipRect.translate(rect.left - _tooltipRect.left, 0);
    }

    if (_tooltipRect.bottom >= painterRect.bottom) {
      _tooltipRect = _tooltipRect.translate(0, painterRect.bottom - _tooltipRect.bottom);
    }

    Color _defBgColor = styleConfig.isDark ? Colors.grey[800]! : Colors.grey[200]!;
    painter
      ..style = PaintingStyle.fill
      ..color = _defBgColor;
    var __tooltipRect = RRect.fromRectAndRadius(_tooltipRect.inflate(4), Radius.circular(5));
    if (!kIsWeb) canvas.drawShadow(Path()..addRRect(__tooltipRect), painter.color, 3, true);
    canvas.drawRRect(__tooltipRect, painter);
    // canvas.drawRRect(
    //     __tooltipRect,
    //     _bgPaint
    //       ..style = PaintingStyle.stroke
    //       ..strokeWidth = 1
    //       ..color = styleConfig.primaryColor);

    drawText(
      canvas,
      text: _text,
      style: _style,
      width: width,
      textAlign: TextAlign.start,
      offset: _tooltipRect.topLeft,
    );
  }
}
