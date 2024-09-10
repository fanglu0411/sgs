import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/navigation_bar.dart';

class SubMenuListWidget extends StatelessWidget {
  final List<NavigationBarItem> menus;

  final ValueChanged<NavigationBarItem>? onTap;

  final BoxConstraints constraints;

  final EdgeInsets padding;
  final dynamic selected;

  const SubMenuListWidget({
    Key? key,
    this.selected,
    required this.menus,
    this.onTap,
    this.constraints = const BoxConstraints.tightFor(width: 200),
    this.padding = const EdgeInsets.symmetric(vertical: 10),
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var children = menus.map((e) {
      bool _selected = selected == e.type;
      return ListTile(
        visualDensity: VisualDensity(horizontal: VisualDensity.minimumDensity, vertical: VisualDensity.minimumDensity),
        onTap: () => onTap?.call(e),
        title: e.title,
        selected: _selected,
        trailing: _selected ? Icon(Icons.check) : null,
      );
    });
    return Container(
      constraints: constraints,
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: ListTile.divideTiles(tiles: children, context: context).toList(),
      ),
    );
  }
}