import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/util/logger.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';

class ScaleControlWidget extends StatefulWidget {
  final Range? range;
  final double sliderWidth;

  final double progress;

  const ScaleControlWidget({
    Key? key,
    this.range,
    this.progress = .5,
    this.sliderWidth = 200,
  }) : super(key: key);

  @override
  _ScaleControlWidgetState createState() => _ScaleControlWidgetState();
}

class _ScaleControlWidgetState extends State<ScaleControlWidget> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.progress;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.zoom_out),
            onPressed: () {},
          ),
          ConstrainedBox(
            constraints: BoxConstraints.tightFor(width: widget.sliderWidth),
            child: SliderTheme(
              data: Theme.of(context).sliderTheme.copyWith(
                    trackHeight: 1,
                    activeTrackColor: Colors.white,
                    inactiveTrackColor: Colors.white.withAlpha(80),
                    thumbColor: Colors.white,
                  ),
              child: Slider(
                value: _value,
//                divisions: 10,
                min: 0,
                max: 100000,
                label: '$_value',
                onChanged: (value) {
                  logger.d('value : $value , ${value * widget.range!.size / 100000}');
                  setState(() {
                    _value = value;
                  });
                },
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.zoom_in),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}