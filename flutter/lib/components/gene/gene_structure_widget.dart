import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/bloc/sgs_context/sgs_browse_logic.dart';
import 'package:d4_scale/d4_scale.dart';
import 'package:flutter_smart_genome/d3/d3_mixin.dart';
import 'package:flutter_smart_genome/page/track/theme/gff_style.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/painter/feature_style_config.dart';
import 'package:flutter_smart_genome/extensions/rect_extension.dart';

class GeneStructureWidget extends StatefulWidget {
  final RangeFeature feature;

  const GeneStructureWidget({Key? key, required this.feature}) : super(key: key);

  @override
  _GeneStructureWidgetState createState() => _GeneStructureWidgetState();
}

class _GeneStructureWidgetState extends State<GeneStructureWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: CustomPaint(
        painter: GeneStructurePainter(widget.feature),
      ),
    );
  }
}

class GeneStructurePainter extends CustomPainter {
  RangeFeature feature;
  late GffStyle _gffStyle;

  GeneStructurePainter(this.feature) {
    _paint = Paint();

    _gffStyle = SgsBrowseLogic.safe()!.trackTheme!.getTrackStyle(TrackType.gff) as GffStyle;
  }

  Paint? _paint;

  double _featureHeight = 18;

  Scale<num, num>? _scale;

  Map<String, FeatureStyle>? _featureStyles;

  @override
  void paint(Canvas canvas, Size size) {
    _scale = ScaleLinear.number(domain: [feature.range.start, feature.range.end], range: [0, size.width]);
    _featureStyles = _gffStyle.featureStyles;

    double _totalHeight = _featureHeight * feature.children!.length;

    drawRect(canvas, Rect.fromLTWH(0, 0, size.width, _totalHeight), _paint!..color = Colors.green.withOpacity(.1), Radius.circular(3));
    // print(json.encode(_gffStyle.json));
    double top = 0;
    feature.children!.forEach((_feature) {
      drawFeature(canvas, _feature, Offset(0, top));
      top += _featureHeight;
    });
  }

  void drawFeature(Canvas canvas, RangeFeature feature, Offset offset) {
    feature.subFeatures!.forEach((f) {
      FeatureStyle _featureStyle = _featureStyles![f.type] ?? _featureStyles!['others'] ?? FeatureStyle.basic();

      var rect = Rect.fromLTRB(_scale!.scale(f.range.start)!.toDouble(), offset.dy, _scale!.scale(f.range.end)!.toDouble(), offset.dy + _featureHeight);
      rect = rect.deflateXY(0, 4);

      if (_featureStyle.height < 1.0) {
        rect = rect.deflateXY(0, (1 - _featureStyle.height) * rect.height / 2);
      }

      Radius? _radius = _featureStyle.hasRadius ? Radius.circular(_featureStyle.radius) : null;

      _paint!
        ..color = _featureStyle.colorWithAlpha
        ..style = PaintingStyle.fill;
      drawRect(canvas, rect, _paint!, _radius);
    });
  }

  void drawRect(Canvas canvas, Rect rect, Paint paint, [Radius? radius = null]) {
    Radius? _radius = radius;
    if (_radius != null) {
      canvas.drawRRect(RRect.fromRectAndRadius(rect, _radius), paint);
    } else {
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant GeneStructurePainter oldDelegate) {
    return oldDelegate.feature != feature;
  }
}
