import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/page/compare/compare_logic.dart';
import 'package:flutter_smart_genome/page/compare/group/compare_group_wrapper.dart';
import 'package:flutter_smart_genome/page/compare/group/item_plot.dart';

class CompareGroupWidget extends StatefulWidget {
  final CompareElement compareElement;
  final List<Map> features;
  final double width;
  final double? height;
  final bool showLabel;
  final ValueChanged<CompareElement>? onRemove;
  final ScrollController? horScrollController;

  const CompareGroupWidget({
    super.key,
    required this.features,
    required this.compareElement,
    required this.width,
    this.height,
    this.showLabel = true,
    this.onRemove,
    this.horScrollController,
  });

  @override
  State<CompareGroupWidget> createState() => _CompareGroupWidgetState();
}

class _CompareGroupWidgetState extends State<CompareGroupWidget> {
  double _columnWidth = 420;

  @override
  void didUpdateWidget(covariant CompareGroupWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    double h = _columnWidth * .618;
    Widget body = Container(
      height: h,
      child: ListView.separated(
        itemCount: widget.features.length,
        scrollDirection: Axis.horizontal,
        controller: widget.horScrollController,
        separatorBuilder: (c, i) => VerticalDivider(thickness: 1, width: 1),
        itemBuilder: (c, i) {
          var _data = widget.features[i];
          return CompareItemPlot(
            element: widget.compareElement,
            data: _data,
            index: i,
            width: _columnWidth,
            height: h,
          );
        },
      ),
    );
    return Container(
      // height: _columnWidth * .618,
      width: widget.width,
      child: CompareGroupWrapper(
        builder: (c) => body,
        showTitle: widget.showLabel,
        compareElement: widget.compareElement,
        onRemove: widget.onRemove,
        onConfigChange: (s) {
          setState(() {});
        },
      ),
    );
  }
}
