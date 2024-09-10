import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/page/cell/cell_scatter_chart/legend_colors.dart';

class LinearColorLegendView extends StatefulWidget {
  final LegendColor legendColor;
  final int? count;

  const LinearColorLegendView({
    Key? key,
    required this.legendColor,
    this.count,
  }) : super(key: key);

  @override
  _LinearColorLegendViewState createState() => _LinearColorLegendViewState();
}

class _LinearColorLegendViewState extends State<LinearColorLegendView> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: BoxConstraints.tightFor(width: 18.0, height: 18.0 * (widget.count ?? 10)),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [widget.legendColor.start, widget.legendColor.end],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }
}