import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/page/compare/compare_logic.dart';
import 'package:flutter_smart_genome/page/compare/widget/compare_element_label.dart';

/// wrap compare items a title
class CompareGroupWrapper extends StatefulWidget {
  final Widget? child;
  final bool showTitle;
  final CompareElement compareElement;
  final ValueChanged<String>? onConfigChange;
  final ValueChanged<CompareElement>? onRemove;
  final WidgetBuilder? builder;

  const CompareGroupWrapper({
    super.key,
    this.child,
    this.builder,
    this.showTitle = true,
    required this.compareElement,
    this.onConfigChange,
    this.onRemove,
  });

  @override
  State<CompareGroupWrapper> createState() => _CompareGroupWrapperState();
}

class _CompareGroupWrapperState extends State<CompareGroupWrapper> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(height: 1.5, thickness: 1.5),
        if (widget.showTitle)
          CompareElementLabel(
            compareElement: widget.compareElement,
            onRemove: (e) {
              widget.onRemove?.call(e);
            },
            onConfigChange: (v) {
              if (widget.onConfigChange != null) {
                widget.onConfigChange?.call(v);
              } else {
                setState(() {});
              }
            },
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: widget.child ?? widget.builder!.call(context),
        ),
      ],
    );
  }
}
