import 'package:flutter/material.dart';

class SMenuItem {
  String? label;
  String? type;
  Widget? icon;
  WidgetBuilder? builder;

  SMenuItem({
    required this.label,
    required this.type,
    this.icon = null,
    this.builder = null,
  });

  SMenuItem.divider() {
    type = 'divider';
    builder = (context) {
      return Container(height: 1.0, color: Colors.grey[300]);
    };
  }
}

class MenuListWidget extends StatelessWidget {
  final List<SMenuItem> items;
  final ValueChanged<SMenuItem>? onChange;

  const MenuListWidget({Key? key, required this.items, this.onChange}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      constraints: BoxConstraints.tightFor(width: 200),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: items.map((item) => _buildMenuItem(context, item)).toList(),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, SMenuItem item) {
    if (item.builder != null) {
      return item.builder!(context);
    }
    return InkWell(
      onTap: () => _onItemTap(item),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (item.icon != null) item.icon!,
            Text('${item.label}', style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  void _onItemTap(SMenuItem item) {
    if (onChange != null) onChange!(item);
  }
}