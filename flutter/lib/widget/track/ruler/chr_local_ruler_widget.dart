import 'package:flutter/material.dart';
import 'package:d4_scale/d4_scale.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';
import 'package:flutter_smart_genome/widget/track/ruler/chr_local_ruler_painter.dart';
import 'package:flutter_smart_genome/widget/track/ruler/ruler_style_config.dart';

class LocalChrRulerWidget extends StatefulWidget {
  final Range range;

  // final double width;
  final ScaleLinear<num> scale;

  const LocalChrRulerWidget({
    Key? key,
    required this.range,
    // this.width = 30,
    required this.scale,
  }) : super(key: key);

  @override
  _LocalChrRulerWidgetState createState() => _LocalChrRulerWidgetState();
}

class _LocalChrRulerWidgetState extends State<LocalChrRulerWidget> {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: LocalChrRulerPainter(
        trackData: BaseTrackData(),
        visibleRange: widget.range,
        scale: widget.scale,
        styleConfig: RulerStyleConfig(
          // backgroundColor: Colors.white70,
          tickerColor: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
