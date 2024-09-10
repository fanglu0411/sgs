import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/util/native_window_util/title_bar_wrapper/title_bar_wrapper.dart';

class AppTitleBar extends StatelessWidget {
  final Widget child;
  final List<Widget>? extras;
  final double height;
  final List<Widget>? leading;

  const AppTitleBar({
    Key? key,
    required this.child,
    this.leading,
    this.extras,
    this.height = 36,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
        color: Theme.of(context).colorScheme.onSecondary,
      ),
      child: TitleBarWrapper(
        leading: leading,
        child: child,
        extras: extras,
      ),
    );
  }
}
