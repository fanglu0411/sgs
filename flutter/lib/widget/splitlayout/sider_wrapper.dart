import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/basic/simple_widget_builder.dart';
import 'package:flutter_smart_genome/widget/splitlayout/layout_icon.dart';
import 'package:flutter_smart_genome/widget/splitlayout/side_tab_item.dart';
import 'package:get/get.dart';

class SidePanelWrapper extends StatefulWidget {
  final TabItem tabItem;
  final Widget child;
  final Function2<TabItem, PanelPosition, void>? onChangePosition;
  final ValueChanged<TabItem>? onHide;
  final VoidCallback? onMaxize;

  const SidePanelWrapper({
    Key? key,
    required this.tabItem,
    required this.child,
    this.onChangePosition,
    this.onHide,
    this.onMaxize,
  }) : super(key: key);

  @override
  _SidePanelWrapperState createState() => _SidePanelWrapperState();
}

class _SidePanelWrapperState extends State<SidePanelWrapper> with SingleTickerProviderStateMixin {
  Map<PanelPosition, IconData> _collapseIconTurns = {
    PanelPosition.right: Icons.keyboard_arrow_right_rounded,
    PanelPosition.bottom: Icons.keyboard_arrow_down_rounded,
    PanelPosition.left: Icons.keyboard_arrow_left_rounded,
    PanelPosition.top: Icons.keyboard_arrow_up_rounded,
  };

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //bool _dark = Brightness.dark == Theme.of(context).brightness;
    Widget? extra = widget.tabItem.extraBuilder?.call(widget.tabItem, context);
    Widget hideButton = IconButton(
      constraints: BoxConstraints.tightFor(width: 28, height: 28),
      splashRadius: 15,
      padding: EdgeInsets.zero,
      splashColor: Theme.of(context).colorScheme.primary.withAlpha(100),
      icon: Icon(_collapseIconTurns[widget.tabItem.panelPosition]),
      iconSize: 24,
      onPressed: _onCollapseSide,
      tooltip: 'Collapse side',
    );
    // Widget maxizeButton = IconButton(
    //   constraints: BoxConstraints.tightFor(width: 28, height: 28),
    //   splashRadius: 15,
    //   padding: EdgeInsets.zero,
    //   splashColor: Theme.of(context).colorScheme.primary.withAlpha(100),
    //   icon: Icon(Icons.maximize),
    //   iconSize: 24,
    //   onPressed: () {
    //     _onCollapseSide();
    //     widget.onMaxize?.call();
    //   },
    //   tooltip: 'Maximize',
    // );

    List<PanelPosition> pos = PanelPosition.values.where((p) => p != PanelPosition.top && p != PanelPosition.center).toList();

    // var layoutBtn = Tooltip(
    //     message: 'Change layout',
    //     child: DropdownButtonHideUnderline(
    //       child: DropdownButton<PanelPosition>(
    //         icon: SizedBox(),
    //         isDense: true,
    //         items: pos.map((e) {
    //           return DropdownMenuItem<PanelPosition>(child: LayoutIcon(position: e), value: e);
    //         }).toList(),
    //         selectedItemBuilder: (c) {
    //           return pos.map((e) {
    //             return DropdownMenuItem<PanelPosition>(child: LayoutIcon(position: e), value: e);
    //           }).toList();
    //         },
    //         onChanged: _changeLayout,
    //         value: widget.tabItem.panelPosition,
    //       ),
    //     ));
    var layoutBtn = SimpleDropdownButton<PanelPosition>(
      items: pos,
      tooltip: 'Change Position',
      initialValue: widget.tabItem.panelPosition,
      borderSide: BorderSide.none,
      minimumSize: Size(38, 36),
      itemWidth: 90,
      childBuilder: (p) => LayoutIcon(position: p!),
      itemBuilder: (p) => (LayoutIcon(position: p), SizedBox(width: 1)),
      onSelectedChange: _changeLayout,
    );

    List<Widget> _children = [
      widget.tabItem.titleBuilder?.call(widget.tabItem, context) ??
          Text(
            widget.tabItem.title,
            style: Theme.of(context).textTheme.titleSmall,
          ),
      Spacer(),
      if (extra != null) extra,
      SizedBox(width: 12),
      layoutBtn,
    ];

    if (widget.tabItem.panelPosition == PanelPosition.right) {
      _children.insert(0, hideButton);
    } else {
      _children.add(hideButton);
    }

    return Column(
      children: [
        Material(
          color: Theme.of(context).appBarTheme.backgroundColor,
          child: Padding(
            padding: EdgeInsets.only(top: 4.0, left: 4, bottom: 4),
            child: Row(children: _children),
          ),
        ),
        Divider(height: 1),
        Expanded(child: widget.child),
      ],
    );
  }

  void _maxize() {}

  Widget _buildItemButton(TabItem e) {
    bool _dark = Brightness.dark == Theme.of(context).brightness;
    Color color = Theme.of(context).colorScheme.primary;
    return Tooltip(
      message: e.title,
      child: Container(
        // constraints: BoxConstraints.tightFor(height: 30),
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
        decoration: BoxDecoration(
          color: e.selected ? color : null,
          // border: e.selected ? Border.all(color: color) : null,
          borderRadius: BorderRadius.only(topRight: Radius.circular(4), topLeft: Radius.circular(4)),
        ),
        child: Text(
          e.title,
          style: TextStyle(color: e.selected || _dark ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  void _onCollapseSide() {
    widget.tabItem.selected = false;
    setState(() {});
    widget.onHide?.call(widget.tabItem);
  }

  void _changeLayout(PanelPosition position) {
    PanelPosition previous = widget.tabItem.panelPosition;
    widget.tabItem.panelPosition = position;
    widget.tabItem.tabPosition = position;
    widget.onChangePosition?.call(widget.tabItem, previous);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
