import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';
import 'package:flutter_smart_genome/widget/track/painter/feature_style_config.dart';

class RangeFeatureWidget extends StatefulWidget {
  final RangeFeature feature;
  final FeatureStyleConfig styleConfig;
  const RangeFeatureWidget({
    Key? key,
    required this.feature,
    required this.styleConfig,
  }) : super(key: key);
  @override
  _RangeFeatureWidgetState createState() => _RangeFeatureWidgetState();
}

class _RangeFeatureWidgetState extends State<RangeFeatureWidget> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class RangeFeaturePainter extends CustomPainter {
  late RangeFeature feature;
  late FeatureStyleConfig styleConfig;
  late Paint _paint;

  double? _featureHeight;
  double? _scale;

  RangeFeaturePainter(this.feature, this.styleConfig) {
    _paint = Paint();
  }

  @override
  void paint(Canvas canvas, Size size) {
    Range _range = feature.range;
    if (_featureHeight == null) {
      _featureHeight = size.height * .6;
    }
    if (_scale == null) {
      _scale = size.width / _range.size;
    }
    if (!feature.hasSubFeature) {
      _drawSingleFeature(canvas, size, feature);
    } else {
      feature.subFeatures!.forEach((feature) => _drawSingleFeature(canvas, size, feature));
    }
  }

  void _drawSingleFeature(Canvas canvas, Size size, RangeFeature feature) {
    FeatureStyle _featureStyle = styleConfig[feature.type];
    double _left = (feature.range.start - this.feature.range.start) * _scale!;
    double _width = feature.range.size * _scale!;
    double _height = _featureHeight! * _featureStyle.height;

    Rect _featureRect = Rect.fromLTWH(_left, (size.height - _height) / 2, _width, _height);

    Radius? _radius = _featureStyle.hasRadius ? Radius.circular(_featureStyle.radius) : null;
    drawRect(
        canvas,
        _paint
          ..style = PaintingStyle.stroke
          ..color = _featureStyle.color!,
        _featureRect,
        _radius);
    if (_featureStyle.borderWidth > 0) {
      drawRect(
          canvas,
          _paint
            ..style = PaintingStyle.stroke
            ..color = _featureStyle.borderColor!
            ..strokeWidth = _featureStyle.borderWidth,
          _featureRect,
          _radius);
    }
  }

  void drawRect(Canvas canvas, Paint paint, Rect rect, [Radius? radius = null]) {
    if (radius != null) {
      canvas.drawRRect(RRect.fromRectAndRadius(rect, radius), paint);
    } else {
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant RangeFeaturePainter oldDelegate) {
    return feature != oldDelegate.feature;
  }
}