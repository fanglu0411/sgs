import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/extensions/common_extensions.dart';

class ButtonGroup extends StatelessWidget {
  final Axis axis;
  final List<Widget> children;
  final BorderRadius? borderRadius;
  final Border? border;
  final Widget? divider;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  const ButtonGroup({
    Key? key,
    this.axis = Axis.horizontal,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.min,
    this.borderRadius,
    this.border,
    this.divider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> _children = divider != null ? children.divideBy<Widget>(divider!).toList() : children;
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(3),
        border: border ?? Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(.5), width: 1.0),
      ),
      child: axis == Axis.horizontal
          ? Row(
              children: _children,
              mainAxisSize: mainAxisSize,
              mainAxisAlignment: mainAxisAlignment,
            )
          : Column(
              children: _children,
              mainAxisAlignment: mainAxisAlignment,
              mainAxisSize: mainAxisSize,
            ),
    );
  }
}
