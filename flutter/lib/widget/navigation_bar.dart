import 'package:flutter/material.dart';

typedef ItemTapCallback<I, T> = void Function(I index, T type);

class NavigationBarItem {
  const NavigationBarItem({
    required this.icon,
    this.title,
    Widget? activeIcon,
    this.tooltip,
    required this.type,
    this.builder,
  }) : activeIcon = activeIcon ?? icon;

  NavigationBarItem.spacer({this.builder})
      : activeIcon = null,
        icon = null,
        title = null,
        tooltip = null,
        type = 'space';

  final Widget? icon;
  final String type;

  final WidgetBuilder? builder;

  final Widget? activeIcon;

  final Widget? title;
  final String? tooltip;
}

class CustomNavigationBar extends StatefulWidget {
  final MainAxisAlignment alignment;
  final int index;
  final List<NavigationBarItem> items;
  final ItemTapCallback<int, String>? onTap;
  final EdgeInsetsGeometry? padding;
  final Axis orientation;
  final MainAxisSize mainAxisSize;
  final WidgetBuilder? header;
  final WidgetBuilder? footer;

  const CustomNavigationBar({
    Key? key,
    this.index = -1,
    this.items = const [],
    this.alignment = MainAxisAlignment.center,
    this.onTap,
    this.padding,
    this.orientation = Axis.vertical,
    this.mainAxisSize = MainAxisSize.max,
    this.header,
    this.footer,
  }) : super(key: key);

  @override
  _NavigationBarState createState() => _NavigationBarState();
}

class _NavigationBarState extends State<CustomNavigationBar> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.index;
  }

  @override
  void didUpdateWidget(CustomNavigationBar oldWidget) {
    _index = widget.index;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    var children = [
      if (widget.header != null) widget.header!(context),
      ..._buildItems(),
      if (widget.footer != null) widget.footer!(context),
    ];

    var axisContainer = widget.orientation == Axis.vertical
        ? Column(
            children: children,
            mainAxisSize: widget.mainAxisSize,
            mainAxisAlignment: widget.alignment,
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: widget.mainAxisSize,
            mainAxisAlignment: widget.alignment,
            children: children,
          );
    return axisContainer;
  }

  List<Widget> _buildItems() {
    final List<Widget> tiles = <Widget>[];

    Color primaryColor = Theme.of(context).colorScheme.primary;

    for (int i = 0; i < widget.items.length; i++) {
      var item = widget.items[i];

      if (item.builder != null) {
        tiles.add(item.builder!(context));
        continue;
      }

      if (item.type == 'space') {
        tiles.add(item.builder?.call(context) ?? Spacer());
        continue;
      }

      bool _dark = Theme.of(context).brightness == Brightness.dark;
      bool selected = i == _index;
      var icon = selected
          ? IconTheme(
              data: IconThemeData(color: primaryColor),
              child: item.activeIcon!,
            )
          : item.icon;
      var tile;

      final IconThemeData defaultIconTheme = IconThemeData(color: _dark ? Colors.white : Colors.black87);

      if (item.title != null) {
        tile = TextButton.icon(
          onPressed: () => _onItemTap(i, item.type),
          icon: icon!,
          label: selected
              ? DefaultTextStyle(
                  style: TextStyle(color: primaryColor),
                  child: item.title!,
                )
              : item.title!,
        );
      } else {
        tile = IconButton(
          tooltip: item.tooltip,
          icon: IconTheme(
            data: i == _index ? Theme.of(context).iconTheme : defaultIconTheme,
            child: icon!,
          ),
          onPressed: () => _onItemTap(i, item.type),
        );
      }
      if (widget.padding != null) {
        tile = Padding(
          padding: widget.padding!,
          child: tile,
        );
      }
      tiles.add(tile);
    }
    return tiles;
  }

  void _onItemTap(int index, String type) {
    if (widget.onTap != null) widget.onTap!(index, type);
    setState(() {
      _index = index;
    });
  }
}
